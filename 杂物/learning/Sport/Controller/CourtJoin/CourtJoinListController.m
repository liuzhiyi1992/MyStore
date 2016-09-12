//
//  CourtJoinListController.m
//  Sport
//
//  Created by xiaoyang on 16/5/20.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "CourtJoinListController.h"
#import "CourtJoinDateListView.h"
#import "CourtJoinListCell.h"
#import "UIScrollView+SportRefresh.h"
#import "SportFilterListView.h"
#import "CircleProjectManager.h"
#import "UserManager.h"
#import "ActivityService.h"
#import "SportProgressView.h"
#import "SportWebController.h"
#import "CourtJoinService.h"
#import "CourtJoin.h"
#import "UIButton+WebCache.h"
#import "Business.h"
#import "UserManager.h"
#import "UIViewController+SportNavigationItem.h"
#import "BusinessCategory.h"
#import "PriceUtil.h"
#import "CourtJoinDetailController.h"
#import "BaseConfigManager.h"
#import "UIImageView+WebCache.h"



@interface CourtJoinListController ()<CourtJoinDateListViewDelegate,CourtJoinListCellDelegate,SportFilterListViewDelegate,ActivityServiceDelegate,CourtJoinServiceDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *dataHeaderScrollView;
@property (weak, nonatomic) IBOutlet UITableView *courtJoinListTableView;
@property (strong, nonatomic) NSArray *dateList;
@property (strong, nonatomic) NSDate *selectedDate;
@property (assign, nonatomic) BOOL isFirstTimeViewDidAppear;
@property (strong, nonatomic) NSMutableArray *courtJoinList;
@property (assign,nonatomic) int page;
@property (strong, nonatomic) IBOutlet UIView *navigationTitleView;
@property (weak, nonatomic) IBOutlet UIButton *categoryFilterButton;
@property (assign, nonatomic) CGFloat downy;
@property (copy, nonatomic) NSString *currentSelectedCategoryId;    //运动项目id
@property (assign, nonatomic) int finishPage;
@property (strong, nonatomic) NSMutableArray *activityList;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (strong, nonatomic) NSArray *courtJoinCategoriesList;
@property (strong, nonnull) CourtJoinDateListView *courtJoinDateListView;

@end

@implementation CourtJoinListController

#define PAGE_START  1
#define COUNT_ONE_PAGE  20

- (id)initWithCourtJoinListControllerWithDate:(NSDate *)date{
    
    self = [super init];
    if (self){
        self.selectedDate = nil;
        self.currentSelectedCategoryId = nil;
        [self initData];
    }
    
    return self;
}

-(void)initData{
    
    self.isFirstTimeViewDidAppear = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"球局列表";
    
    //反向更改公共的右上button
    [super createRightTopButton:@"什么是球局?"];
    UIBarButtonItem *buttonItem = self.navigationItem.rightBarButtonItem;
    UIButton *button = buttonItem.customView;
    button.titleLabel.font = [UIFont systemFontOfSize:12];

    [self.courtJoinListTableView addPullDownReloadWithTarget:self action:@selector(loadNewData)];
    [self.courtJoinListTableView addPullUpLoadMoreWithTarget:self action:@selector(loadMoreData)];

    //一开始就下拉刷新
    [self.courtJoinListTableView beginReload];
    
    [MobClickUtils event:umeng_event_visit_court_join_list];
}

-(void)loadNewData {
    self.page = PAGE_START;
    self.finishPage = 0;
    [self queryData];
}

-(void)loadMoreData {
    self.page ++;
    [self queryData];
}

- (void)queryData{
    
    [SportProgressView showWithStatus:@"正在加载..."];
    double currentLatitude = [[UserManager defaultManager] readUserLocation].coordinate.latitude;
    double currentLongitude = [[UserManager defaultManager] readUserLocation].coordinate.longitude;
    [CourtJoinService getCourtJoinList:self latitude:currentLatitude longitude:currentLongitude count:COUNT_ONE_PAGE page:_page categoryId:_currentSelectedCategoryId userId:[[UserManager defaultManager] readCurrentUser].userId bookDate:self.selectedDate];
}

-(void)updateAllViews{
    [self initDataScrollView];
    [self updateDateHeaderScrollView];
    [self.courtJoinListTableView reloadData];
}

#define BASIC_DATE_TAG  100
-(void)initDataScrollView{
    
    for(UIView *subView in self.dataHeaderScrollView.subviews){
        if([subView isKindOfClass:[CourtJoinDateListView class]]){
            [subView removeFromSuperview];
        }
        
    }
    int selectedIndex = 0;
    int index = 0;
    CGFloat space = 0;
    for (NSDate *date in _dateList) {
        
        if ([date isEqualToDate:_selectedDate]) {
            selectedIndex = index;
        }

        self.courtJoinDateListView = [CourtJoinDateListView createCourtJoinDateListViewWithHoldViewWidth:[UIScreen mainScreen].bounds.size.width];
        self.courtJoinDateListView.tag = BASIC_DATE_TAG + index;
        self.courtJoinDateListView.delegate = self;
        [self.courtJoinDateListView updatView:date isSelected:NO index:index];
        [self.courtJoinDateListView updateOriginX:space + index * (space + self.courtJoinDateListView.frame.size.width)];
        [self.dataHeaderScrollView addSubview:self.courtJoinDateListView];
        index ++;
    }
    
    [self.dataHeaderScrollView setContentSize:CGSizeMake(space + index * (space + [CourtJoinDateListView defaultSize].width), _dataHeaderScrollView.frame.size.height)];
    self.dataHeaderScrollView.showsHorizontalScrollIndicator = NO;
    
    if (selectedIndex > 3 && _dataHeaderScrollView.contentSize.width > _dataHeaderScrollView.frame.size.width) {
        CGFloat oneWidth = space + [CourtJoinDateListView defaultSize].width;
        CGFloat xOffset = MIN(MAX(selectedIndex * oneWidth - 0.5 * oneWidth, 0),  _dataHeaderScrollView.contentSize.width - [UIScreen mainScreen].bounds.size.width);
        [self.dataHeaderScrollView setContentOffset:CGPointMake(xOffset, 0) animated:NO];
    }
}

- (void)updateDateHeaderScrollView
{
    NSArray *subViewList = [self.dataHeaderScrollView subviews];
    for (UIView *view in subViewList) {
        if ([view isKindOfClass:[CourtJoinDateListView class]]) {
            CourtJoinDateListView *bdv = (CourtJoinDateListView *)view;
            if ([bdv.date isEqualToDate:_selectedDate]){
                [bdv updateSelected:YES];
            } else {
                if (YES == bdv.isSelected) {
                    [bdv updateSelected:NO];
                }
            }
        }
    }
}


#define TAG_PICKER_AC_CATEGORY  2016053001

- (IBAction)clickCategaryFilterButton:(id)sender {
    
//    _categoryFilterButton.selected = !_categoryFilterButton.selected;
    //取出目录名字
    NSMutableArray *courtJoinCategoryNameList = [NSMutableArray array];
    for (BusinessCategory *businessCategory in self.courtJoinCategoriesList) {
        [courtJoinCategoryNameList addObject:businessCategory.name];
    }
    
    if ([SportFilterListView hideInView:self.view tag:TAG_PICKER_AC_CATEGORY]){
        return;
    }
    //设置待选列表
    int selectedRow = 0;
    int index = 0;
    for (NSString *one in courtJoinCategoryNameList) {
        
        if ([self.categoryLabel.text isEqualToString:one]) {
            selectedRow = index;
        }
        index ++;
    }
    //显示
    CGFloat offy=0;

    [SportFilterListView showInView:self.view
                                  y:offy
                                tag:TAG_PICKER_AC_CATEGORY
                           dataList:courtJoinCategoryNameList
                        selectedRow:selectedRow
                           delegate:self
                       holderButton:_categoryFilterButton
                       imageUrlList:nil
               selectedImageUrlList:nil];
}

- (void)clickRightTopButton:(id)sender{
    
    SportWebController *swc = [[SportWebController alloc]initWithUrlString:[BaseConfigManager defaultManager].courtJoinInstructionUrl title:@"什么是球局"];
    [self.navigationController pushViewController:swc animated:YES];
}

#pragma mark - 网络回调
- (void)didGetCourtJoinList:(NSArray *)courtJoinList
          courtJoinDateList:(NSArray *)courtJoinDateList
    courtJoinCategoriesList:(NSArray *)courtJoinCategoriesList
  currentSelectedCategoryName:(NSString *)currentSelectedCategoryName
                currentDate:(NSDate *)currentTime
                     status:(NSString *)status
                        msg:(NSString *)msg{
    
    [SportProgressView dismiss];
    if ([status isEqualToString:STATUS_SUCCESS]) {
        
        //日期源
        self.dateList = courtJoinDateList;
        if ([self.courtJoinList count] ==0 || _page == PAGE_START) {
            self.courtJoinList = [NSMutableArray arrayWithArray:courtJoinList];
        }else {
            [self.courtJoinList addObjectsFromArray:courtJoinList];
        }
        
        //取出球局目录
        self.courtJoinCategoriesList = courtJoinCategoriesList;
        
        if ([courtJoinCategoriesList count] == 0) {
            self.navigationTitleView.hidden = YES;
        } else {
            self.navigationTitleView.hidden = NO;
        }
        
        [self.courtJoinListTableView reloadData];
        
        if ([courtJoinList count] < COUNT_ONE_PAGE){
            
            [self.courtJoinListTableView canNotLoadMore];
        }else {
            [self.courtJoinListTableView canLoadMore];
            
        }
        self.selectedDate = currentTime;
        //更新当前目录选中的名字
        
        if (currentSelectedCategoryName == nil) {
            self.navigationItem.titleView = nil;
            self.title = @"球局列表";
        }else {
            self.navigationItem.titleView = self.navigationTitleView;
            self.categoryLabel.text = currentSelectedCategoryName;
        }
        [self updateAllViews];
    }else {
        [SportProgressView dismissWithError:msg];
    }
    //无数据时处理分支
    if([_courtJoinList count] ==0){
        //如果连日期都为空那么就全遮，
        CGRect frame = CGRectMake(0, 0, 0, 0);
        if ([_dateList count] == 0){
           frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height-20-44);
        }else {
            frame = CGRectMake(0, self.dataHeaderScrollView.frame.size.height, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height-20-44-self.dataHeaderScrollView.frame.size.height);
        }

        if([status isEqualToString:STATUS_SUCCESS]){
            [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"没有相关数据"];
        } else{
            [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:@"网络错误"];
        }
        
    }else{
        [self removeNoDataView];
    }
    
    [self.courtJoinListTableView endLoad];
}

- (void)didClickNoDataViewRefreshButton
{
    [SportProgressView showWithStatus:@"加载中"];
    [self queryData];
}

#pragma mark - scrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    self.downy=scrollView.contentOffset.y;
    
    CGFloat offy=0;
    if (self.downy<68) {
        offy=110-self.downy;
    }else{
        
        offy=42;
    }
    UIView *v=[self.view.subviews lastObject];
    
    if ([v isKindOfClass:[SportFilterListView class]]) {
        v.frame=CGRectMake(0, offy, [UIScreen mainScreen].bounds.size.width,  [UIScreen mainScreen].bounds.size.height);
    }
}
#pragma mark - SportFilterListViewDelegate
- (void)didSelectSportFilterListView:(SportFilterListView *)sportFilterListView indexPath:(NSIndexPath *)indexPath
{
    if (sportFilterListView.tag == TAG_PICKER_AC_CATEGORY) {
        BusinessCategory *businessCategory = [self.courtJoinCategoriesList objectAtIndex:indexPath.row];
        self.currentSelectedCategoryId = businessCategory.businessCategoryId;
        self.categoryLabel.text = businessCategory.name;
        [self loadNewData];        
    }
}

#pragma mark - didClickCourtJoinDateListViewDelegate
- (void)didClickCourtJoinDateListView:(NSDate *)date
{
    if ([_selectedDate isEqualToDate:date]) {
        return;
    }
    self.selectedDate = date;
    [self loadNewData];
}

#pragma mark - courtJoinTableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.courtJoinList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *identifier = [CourtJoinListCell getCellIdentifier];
    
    CourtJoinListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [CourtJoinListCell createCell];
        cell.delegate = self;

    }
    cell.detailButton.hidden = YES;
    CourtJoin *courtJoin = [self.courtJoinList objectAtIndex:indexPath.row];
    [cell updateCellWithCourtJoin:courtJoin indexPath:indexPath];
    //球局列表的周几label和图标的label是要隐藏的，不过隐藏还要调约束，为了方便，使label的文字为空，看起来就跟隐藏一样了
    cell.timeLabel.text = nil;
    cell.iconLabel.text = nil;
    cell.hourLabelLeftConstraint.constant = 0;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CourtJoinDetailController *controller = [[CourtJoinDetailController alloc]initWithCourtJoinId: [(CourtJoin *)self.courtJoinList[indexPath.row] courtJoinId]];
    
    [self.navigationController pushViewController:controller animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 196.0;
}


-(void)didClickNickNameButton:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.courtJoinList.count) {
        return;
    }
    
    [self showUserDetailControllerWithUserId:[(CourtJoin *)self.courtJoinList[indexPath.row] courtUserId]];
}

@end
