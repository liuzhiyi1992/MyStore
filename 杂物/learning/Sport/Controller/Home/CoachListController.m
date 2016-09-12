//
//  CoachListController.m
//  Sport
//
//  Created by qiuhaodong on 15/7/15.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CoachListController.h"
#import "CoachCell.h"
#import "Coach.h"
#import "CoachService.h"
#import "UIScrollView+SportRefresh.h"
#import "SportPopupView.h"
#import "SportProgressView.h"
#import "SportFilterListView.h"
#import "BusinessCategoryManager.h"
#import "BusinessCategory.h"
#import "CoachOrderController.h"
#import "CoachHomeMoreView.h"
#import "CoachIntroductionController.h"
#import "ConversationListViewController.h"
#import "CoachOrderListController.h"
#import "LoginController.h"
#import "UserManager.h"
#import "TipNumberManager.h"
#import "RongService.h"
#import "CityManager.h"
#import "BaseConfigManager.h"
#import "GoSportUrlAnalysis.h"
#import "UIView+Utils.h"
#import "CoachBriefCell.h"
#import "UIColor+HexColor.h"
#import "CoachFilterController.h"
#import "SportWebController.h"


@interface CoachListController ()<UITableViewDataSource, UITableViewDelegate, CoachServiceDelegate, SportFilterListViewDelegate, CoachCellDelegate, CoachHomeMoreViewDelegate, UIAlertViewDelegate, UIWebViewDelegate, CoachFilterControllerDelegate>

@property (strong, nonatomic) NSArray *coachCategoryList;
@property (strong, nonatomic) NSMutableArray *dataList;
@property (copy, nonatomic) NSString *gender;
@property (copy, nonatomic) NSString *categoryName;
@property (copy, nonatomic) NSString *sort;
@property (assign, nonatomic) NSUInteger finishPage;
@property (weak, nonatomic) IBOutlet UITableView *dataTableView;
@property (weak, nonatomic) IBOutlet UIButton *categoryFilterButton;
@property (weak, nonatomic) IBOutlet UIButton *genderFilterButton;
@property (weak, nonatomic) IBOutlet UIButton *sortFilterButton;

@property (weak, nonatomic) IBOutlet UIWebView *myWebView;
@property (copy, nonatomic) NSString *urlString;
@property (assign, nonatomic) BOOL isLoadWebSuccess;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *slideBarConstraintX;

@property (strong, nonatomic) UISwipeGestureRecognizer *toLeftSwipeGestureRecognizer;
@property (strong, nonatomic) UISwipeGestureRecognizer *toRightSwipeGestureRecognizer;

@end

@implementation CoachListController
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTIFICATION_NAME_DID_CHANGE_CITY
                                                  object:nil];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didChangeCity)
                                                     name:NOTIFICATION_NAME_DID_CHANGE_CITY
                                                   object:nil];
    }
    return self;
}

#define TITLE_CATEGORY_NO_LIMIT @"不限"
- (NSString *)categoryIdWithCategoryName:(NSString *)categoryName
{
    for (BusinessCategory *category in self.coachCategoryList) {
        if ([categoryName isEqualToString:category.name]) {
            return category.businessCategoryId;
        }
    }
    return nil;
}

- (NSArray *)genderList
{
    return @[TITLE_GENDER_NO_LIMIT, TITLE_GENDER_MALE, TITLE_GENDER_FEMALE];
}

- (NSString *)genderTypeWithTitle:(NSString *)title
{
    NSDictionary *dic = @{TITLE_GENDER_NO_LIMIT : @"",
                          TITLE_GENDER_MALE : @"m",
                          TITLE_GENDER_FEMALE : @"f"};
    return [dic objectForKey:title];
}

- (NSArray *)sortList
{
    return @[TITLE_SORT_DISTANCE, TITLE_SORT_RATING, TITLE_SORT_POPULAR];
}

- (NSString *)sortTypeWithTitle:(NSString *)title
{
    NSDictionary *dic = @{TITLE_SORT_DISTANCE : @"1",
                          TITLE_SORT_RATING : @"2",
                          TITLE_SORT_POPULAR : @"3"};
    return [dic objectForKey:title];
}

#define COLOR_NORMAL    [UIColor colorWithRed:147.0/255.0 green:147.0/255.0 blue:147.0/255.0 alpha:1]
#define COLOR_SELECTED  [SportColor defaultColor]
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"约练";
    
    //tableview没有线条
    self.dataTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.categoryName = TITLE_CATEGORY_NO_LIMIT;
    self.gender = TITLE_GENDER_NO_LIMIT;
    
    //默认按人气排序
    self.sort = TITLE_SORT_POPULAR;
    
    [self updateFilterButtons];
    
    [self.categoryFilterButton setBackgroundImage:[SportImage listFilterButtonImage] forState:UIControlStateNormal];
   
    [self.categoryFilterButton setBackgroundImage:[SportImage listFilterButtonSelectedImage] forState:UIControlStateSelected];
    
    [self.categoryFilterButton setTitleColor:COLOR_NORMAL forState:UIControlStateNormal];
    [self.categoryFilterButton setTitleColor:COLOR_SELECTED forState:UIControlStateSelected];
     self.categoryFilterButton.highlighted=NO;
    [self.categoryFilterButton setAdjustsImageWhenHighlighted:NO];

    [self.genderFilterButton setBackgroundImage:[SportImage listFilterButtonImage] forState:UIControlStateNormal];
    [self.genderFilterButton setBackgroundImage:[SportImage listFilterButtonSelectedImage] forState:UIControlStateSelected];
    
    [self.genderFilterButton setTitleColor:COLOR_NORMAL forState:UIControlStateNormal];
    [self.genderFilterButton setTitleColor:COLOR_SELECTED forState:UIControlStateSelected];

    self.genderFilterButton.highlighted=NO;
    [self.genderFilterButton setAdjustsImageWhenHighlighted:NO];
    
    [self.sortFilterButton setBackgroundImage:[SportImage listFilterButtonImage] forState:UIControlStateNormal];
    [self.sortFilterButton setBackgroundImage:[SportImage listFilterButtonSelectedImage] forState:UIControlStateSelected];
    [self.sortFilterButton setTitleColor:COLOR_NORMAL forState:UIControlStateNormal];
    [self.sortFilterButton setTitleColor:COLOR_SELECTED forState:UIControlStateSelected];
    
    [self.sortFilterButton setAdjustsImageWhenHighlighted:NO];
    
    [CoachService getCoachCategory:self];
    
    [self.dataTableView addPullDownReloadWithTarget:self action:@selector(loadNewData)];
    [self.dataTableView addPullUpLoadMoreWithTarget:self action:@selector(loadMoreData)];
    [self.dataTableView beginReload];
    
    //上边筛选栏适配iphone4
    if ([UIScreen mainScreen].bounds.size.height <= 480) {
        self.topHolerViewHeightConstraint.constant = 0.9 * self.topHolerViewHeightConstraint.constant;
    }
}

- (BOOL)isOpenCity
{
    for (NSString *cityId in [[BaseConfigManager defaultManager] coachOpenCityIdList]) {
        if ([cityId isEqualToString:[CityManager readCurrentCityId]]) {
            return YES;
        }
    }
    return NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BOOL isShowWebView = NO;
    if ([BaseConfigManager currentVersionIsInReView]) { //在审核版本
        isShowWebView = YES;
         self.urlString = [[BaseConfigManager defaultManager] coachInReviewUrl];
        [self cleanRightTopButton];
    } else if (![self isOpenCity]) { //未开通城市
        isShowWebView = YES;
        self.urlString = [[BaseConfigManager defaultManager] coachRecruitUrl];
        [self cleanRightTopButton];
    } else {
        isShowWebView = NO;
    }
    
    if (isShowWebView) { //显示招募网页
        self.myWebView.hidden = NO;
        if (!self.isLoadWebSuccess) {
            [self loadWebView];
        }
    } else {
        self.myWebView.hidden = YES;
        [self createRightTopButton:@"筛选"];
    }
}

- (void)didgetCoachCategory:(NSArray *)categoryList status:(NSString *)status msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        self.coachCategoryList = categoryList;
    }
}

- (void)updateFilterButtons
{
    [self.categoryFilterButton setTitle:self.categoryName forState:UIControlStateNormal];
    [self.genderFilterButton setTitle:self.gender forState:UIControlStateNormal];
    [self.sortFilterButton setTitle:self.sort forState:UIControlStateNormal];
}

- (void)initTheGestureRecognizer {
    _toLeftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToLeft)];
    _toLeftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.dataTableView addGestureRecognizer:_toLeftSwipeGestureRecognizer];
    
    _toRightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToRight)];
    _toRightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.dataTableView addGestureRecognizer:_toRightSwipeGestureRecognizer];
    
    self.dataTableView.userInteractionEnabled = YES;
}

- (void)swipeToLeft {
    if(self.headerLeftButton.selected) {
        [self clickheaderRightButton:self.headerRightButton];
    }
}

- (void)swipeToRight {
    if(self.headerRightButton.selected) {
        [self clickHeaderLeftButton:self.headerLeftButton];
    }
}

- (IBAction)clickHeaderLeftButton:(id)sender {

    if( ! self.headerLeftButton.selected) {//本来没选中，才做操作
        
        self.headerLeftButton.selected = YES;
        self.headerRightButton.selected = NO;
        
        [UIView animateWithDuration:0.2 animations:^{
            self.slideBarConstraintX.constant = (self.headerLeftButton.frame.size.width - self.slideBar.frame.size.width) / 2;
            [self.slideBar updateCenterX:self.headerLeftButton.center.x];
        }];
        
        self.sort = TITLE_SORT_POPULAR;
        [self.dataTableView beginReload];
    }
}

- (IBAction)clickheaderRightButton:(id)sender {
    if( ! self.headerRightButton.selected) {//本来没选中，才做操作
        
        self.headerLeftButton.selected = NO;
        self.headerRightButton.selected = YES;
        
        [UIView animateWithDuration:0.2 animations:^{
            self.slideBarConstraintX.constant = self.headerLeftButton.frame.size.width + (self.headerLeftButton.frame.size.width - self.slideBar.frame.size.width) / 2;
            [self.slideBar updateCenterX:self.headerRightButton.center.x];
        }];
        
        self.sort = TITLE_SORT_DISTANCE;
        
        //没开启定位功能则不显示内容
        if(self.headerRightButton.selected && [[UserManager defaultManager] readUserLocation] == nil) {
            [self showNoDataViewWithType:NoDataTypeLocationError frame:self.tableView.frame tips:@"您没有开启手机定位功能"];
        }else{
            [self.dataTableView beginReload];
        }
    }
}

#define TAG_CATEGORY    2015071801
#define TAG_GENDER      2015071802
#define TAG_SORT        2015071803
- (IBAction)clickCategoryFilterButton:(id)sender {
    
    //如果已展开，则收起
    if ([SportFilterListView hideInView:self.view tag:TAG_CATEGORY]) {
        return;
    }
    
    //设置待选项目列表
    int selectedRow = 0;
    int index = 0;
    NSMutableArray *nameArray = [NSMutableArray array];
    NSMutableArray *imageUrlArray = [NSMutableArray array];
    NSMutableArray *selectedImageUrlArray = [NSMutableArray array];
    for (BusinessCategory *category in self.coachCategoryList) {
        if ([_categoryName isEqualToString:category.name]) {
            selectedRow = index;
        }
        [nameArray addObject:category.name];
        [imageUrlArray addObject:category.imageUrl];
        [selectedImageUrlArray addObject:category.activeImageUrl];
        index ++;
    }
    
    //显示
    [SportFilterListView showInView:self.view
                                  y:45
                                tag:TAG_CATEGORY
                           dataList:nameArray
                        selectedRow:selectedRow
                           delegate:self
                       holderButton:_categoryFilterButton
                       imageUrlList:imageUrlArray
               selectedImageUrlList:selectedImageUrlArray];
  

}

//下个版本删除
- (IBAction)clickGenderFilterButton:(id)sender {
   
    //如果已展开，则收起
    if ([SportFilterListView hideInView:self.view tag:TAG_GENDER]) {
        return;
    }
    
    //设置待选列表
    NSArray *genderList = [self genderList];
    int selectedRow = 0;
    int index = 0;
    for (NSString *one in genderList) {
        if ([_gender isEqualToString:one]) {
            selectedRow = index;
        }
        index ++;
    }
    
    //显示
    [SportFilterListView showInView:self.view
                                  y:45
                                tag:TAG_GENDER
                           dataList:genderList
                        selectedRow:selectedRow
                           delegate:self
                       holderButton:_genderFilterButton
                       imageUrlList:nil
               selectedImageUrlList:nil];
}

- (IBAction)clickSortFilterButton:(id)sender {
    //如果已展开，则收起
    if ([SportFilterListView hideInView:self.view tag:TAG_SORT]) {
        return;
    }
    
    //设置待选项目列表
    NSArray *sortList = [self sortList];
    int selectedRow = 0;
    int index = 0;
    for (NSString *one in sortList) {
        if ([_sort isEqualToString:one]) {
            selectedRow = index;
        }
        index ++;
    }
    
    //显示
    [SportFilterListView showInView:self.view
                                  y:45
                                tag:TAG_SORT
                           dataList:sortList
                        selectedRow:selectedRow
                           delegate:self
                       holderButton:_sortFilterButton
                       imageUrlList:nil
               selectedImageUrlList:nil];
}

- (void)didSelectSportFilterListView:(SportFilterListView *)sportFilterListView indexPath:(NSIndexPath *)indexPath
{
    if (sportFilterListView.tag == TAG_CATEGORY) {
        BusinessCategory *category = [self.coachCategoryList objectAtIndex:indexPath.row];
        self.categoryName = category.name;
        
        [MobClickUtils event:umeng_event_click_coach_list_categories label:category.name];
        
    } else if (sportFilterListView.tag == TAG_GENDER) {
        self.gender = [[self genderList] objectAtIndex:indexPath.row];
        
        [MobClickUtils event:umeng_event_click_coach_list_sex label:self.gender];
        
    } else if (sportFilterListView.tag == TAG_SORT) {
        NSString *selectedSort = [[self sortList] objectAtIndex:indexPath.row];
        
        [MobClickUtils event:umeng_event_click_coach_list_sort label:selectedSort];
        
        if ([selectedSort isEqualToString:TITLE_SORT_DISTANCE]
            && [[UserManager defaultManager] readUserLocation] == nil) {
            [SportPopupView popupWithMessage:@"暂时无法获取您的位置，请检查是否已开启定位服务"];
            return;
        } else {
            self.sort = selectedSort;
        }
    }
    [self updateFilterButtons];
    [self.dataTableView beginReload];
}

- (void)clickRightTopButton:(id)sender {
    
    CoachFilterController *filterController;
    if(0 != self.coachCategoryList.count) {//有请求到项目列表
        if(self.categoryName.length != 0 && self.gender.length != 0 ) {
            filterController = [[CoachFilterController alloc] initWithItem:_categoryName gender:_gender categoryList:self.coachCategoryList];
        }else {
            filterController = [[CoachFilterController alloc] initWithCategoryList:self.coachCategoryList];
        }
    }else {
        //重新获取项目列表
        [SportPopupView popupWithMessage:@"没有请求到项目列表，请重试"];
        [CoachService getCoachCategory:self];
    }
    
    filterController.delegate = self;
    [self.navigationController pushViewController:filterController animated:YES];
}

- (void)didClickCoachHomeMoreViewMessageButton
{
    [MobClickUtils event:umeng_event_click_coach_list_more label:@"消息"];
    if ([self isLoginAndShowLoginIfNot]) {
        if ([[RongService defaultService] checkRongReady]) {
            ConversationListViewController *controller = [[ConversationListViewController alloc]init];
            controller.title = @"消息";
            [self.navigationController pushViewController:controller animated:YES];

        } else {
            //[controller setDisplayConversationTypes:nil];
            [SportPopupView popupWithMessage:@"聊天还没准备好，请稍候"];
        }
    }
}

- (void)didClickCoachHomeMoreViewMyOrderButton
{
    [MobClickUtils event:umeng_event_click_coach_list_more label:@"我的约练"];
    if ([self isLoginAndShowLoginIfNot]) {
        CoachOrderListController *controller = [[CoachOrderListController alloc]init];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [CoachHomeMoreView removeFromView:self.view];
}

- (void)didChangeCity
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.dataTableView beginReload];
    });
}

- (void)loadNewData
{
    self.finishPage = 0;
    [self queryData];
}

- (void)loadMoreData
{
    [self queryData];
}

#define COUNT_ONE_PAGE  20
- (void)queryData
{
    CLLocation *location = [[UserManager defaultManager] readUserLocation];
    [CoachService getCoachList:self
                        cityId:[CityManager readCurrentCityId]
                    categoryId:[self categoryIdWithCategoryName:_categoryName]
                        gender:[self genderTypeWithTitle:_gender]
                          sort:[self sortTypeWithTitle:_sort]
                          page:_finishPage + 1
                         count:COUNT_ONE_PAGE
                      latitude:location.coordinate.latitude
                     longitude:location.coordinate.longitude];
}

- (void)didGetCoachList:(NSArray *)coachList status:(NSString *)status msg:(NSString *)msg page:(NSUInteger)page
{
    
    [self.dataTableView endLoad];
    if ([status isEqualToString:STATUS_SUCCESS]) {
        
        self.finishPage = page;
        if (page == 1) {
            self.dataList = [NSMutableArray arrayWithArray:coachList];
        } else {
            [self.dataList addObjectsFromArray:coachList];
        }
        
        [self.dataTableView reloadData];
        
        if ([coachList count] < COUNT_ONE_PAGE) {
            [self.dataTableView canNotLoadMore];
        } else {
            [self.dataTableView canLoadMore];
        }
        [SportProgressView dismiss];
    } else {
        [SportProgressView dismissWithError:msg];
    }
    
    if (self.dataList.count == 0) {
        CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64 - 49);
        if ([status isEqualToString:STATUS_SUCCESS]) {
            [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"没有相关数据"];
        } else {
            [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:msg];
        }
    } else {
        [self removeNoDataView];
    }
    
    //如果显示了招募页，则不显示没数据的view
    if (!self.myWebView.hidden) {
        [self removeNoDataView];
    }
}

- (void)didClickNoDataViewRefreshButton
{
    [SportProgressView showWithStatus:@"加载中"];
    [self queryData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - tableviewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSUInteger count = [_dataList count];
//    if (count % 2 == 1) {
//        return count / 2 + 1;
//    } else {
//        return count / 2;
//    }
    
    return [_dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *indetifier = [CoachBriefCell getCellIdentifier];
    
    CoachBriefCell *cell = [tableView dequeueReusableCellWithIdentifier:indetifier];
    
    if(nil == cell) {
        cell = [CoachBriefCell createCell];
    }
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell updateCellWithCoach:self.dataList[indexPath.row]];
    
    //初始化cell布局
    //[cell initLayout];
    return cell;
}

#pragma mark tableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([UIScreen mainScreen].bounds.size.height <= 480) {
        return [CoachBriefCell getCellHeight] * 0.9;
    }
    return [CoachBriefCell getCellHeight];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Coach *coach = self.dataList[indexPath.row];
    CoachIntroductionController *controller = [[CoachIntroductionController alloc] initWithCoachId:coach.coachId];
    [self.navigationController pushViewController:controller animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)didClickCoachCell:(Coach *)coach
{
    [MobClickUtils event:umeng_event_click_coach_list_caoch_introduce];
    CoachIntroductionController *controller = [[CoachIntroductionController alloc] initWithCoachId:coach.coachId];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - coachFilterDelegate
- (void)didSelectedItem:(NSString *)item gender:(NSString *)gender {
    self.categoryName = item;
    self.gender = gender;
    

    [self.dataTableView beginReload];
}

#pragma mark - 以下是处理招募页
- (void)loadWebView
{
    NSURL *url = [NSURL URLWithString:_urlString];
    if (url != nil) {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.myWebView loadRequest:request];
    } else{
        [SportPopupView popupWithMessage:@"无法打开网页"];
    }
}

#pragma mark -
#pragma UIWebViewDelegate methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([GoSportUrlAnalysis isGoSportScheme:request.URL]) {
        [GoSportUrlAnalysis pushControllerWithUrl:request.URL NavigationController:self.navigationController];
        return NO;
    } else {
        return YES;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.isLoadWebSuccess = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

@end
