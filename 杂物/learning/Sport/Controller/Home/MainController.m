//
//  MainController.m
//  Sport
//
//  Created by xiaoyang on 16/5/11.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "MainController.h"
#import "ConversationListViewController.h"
#import "UIView+Utils.h"
#import "UserManager.h"
#import "AppGlobalDataManager.h"
#import "CityManager.h"
#import "City.h"
#import "User.h"
#import "UserService.h"
#import "SportAd.h"
#import "GoSportUrlAnalysis.h"
#import "SportWebController.h"
#import "MainCellSectionHeaderView.h"
#import "TipNumberManager.h"
#import "SearchResultController.h"
#import "SearchBusinessController.h"
#import "BusinessListPickerView.h"
#import "SportStartAndEndTimePickerView.h"
#import "CourtJoinListController.h"
#import "DateUtil.h"
#import "PickerViewDataList.h"
#import "UITableView+Utils.h"
#import "MainService.h"
#import "UserManager.h"
#import "SportProgressView.h"
#import "UIScrollView+SportRefresh.h"
#import "JPushManager.h"
#import "CourtJoin.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
#import "PriceUtil.h"
#import "BusinessDetailController.h"
#import "DateUtil.h"
#import "CourtJoinDetailController.h"
#import "MainControllerCategory.h"
#import "BusinessListController.h"
#import "BusinessCategory.h"
#import "BusinessCategoryManager.h"
#import "SuggestCityAlertManager.h"
#import "MainHomeSignInView.h"
#import "UIImageView+WebCache.h"
#import "SportPopupView.h"
#import "NSDictionary+JsonValidValue.h"
#import "BusinessSearchDataManager.h"
#import "NSDate+Utils.h"
#import "SportSignInController.h"

@interface MainController ()<UserServiceDelegate,SportStartAndEndTimePickerViewDelegate,MainCellSectionHeaderViewDelegate,MainServiceDelegate,BaseServiceDelegate>
@property (weak, nonatomic) IBOutlet UITableView *dataTableView;
@property (weak, nonatomic) IBOutlet UIButton *rightTipsCountButton;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MKUserLocation *currentLocation;
@property (assign, nonatomic) BOOL isDidFoundUserLocation;
@property (strong, nonatomic) City *equalCity;
@property (strong, nonatomic) MainHeaderView *mainHeaderView;
@property (strong, nonatomic) NSArray *adList;
@property (strong, nonatomic) NSArray *canJoinGameList;
@property (assign, nonatomic) BOOL isOpen;
@property (weak, nonatomic) IBOutlet UIView *navigationBarSearchHolderView;
@property (weak, nonatomic) IBOutlet UIButton *punchTheClockButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchAndSignInDistanceConstraint;

@property (weak, nonatomic) IBOutlet UIView *signInHolderView;

@property (assign, nonatomic) BOOL isLoadingAd;
@property (copy, nonatomic) NSString *currentCityId;
@property (copy, nonatomic) NSString *defaultSelectedCategoryId;
@property (strong, nonatomic) NSArray *courtJoinList;
@property (strong, nonatomic) NSArray *venueList;
@property (strong, nonatomic) MainControllerCategory *mainControllerCategory;
@property (copy, nonatomic) NSString *selectCategoryName;
@property (assign, nonatomic) BOOL isCanOpenOrClose;
@property (copy, nonatomic) NSString *currentClickCategoryId;
@property (copy, nonatomic) NSDate *currentSelectedDate;
@property (copy, nonatomic) NSString *currentSelectedWeekString;
@property (copy, nonatomic) NSString *currentSelectedHourString;
@property (copy, nonatomic) NSString *currentSelectedSoccerSelectedNumber;
@property (copy, nonatomic) NSString *currentSelectedFilterId;
@property (assign, nonatomic) NSInteger currentSelectedTimeInterval;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) MainCellSectionHeaderView *mainCellSectionHeaderView;
@property (assign, nonatomic) BOOL isShowCityList;
@property (strong, nonatomic) UIButton *checkMoreButton;
@end

@implementation MainController

#define CLICKDATEPICKERVIEWID                 1
#define CLICKHOURPICKERVIEWID                 2
#define CLICKEXTRACONDITIONID                 3
#define CLICKEXTRACONDITIONNOSOCCERPERSON     4

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NAME_DID_CHANGE_CITY object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NAME_FINISH_SHOW_START_PAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NAME_CHANGE_TIPS_COUNT object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NAME_DID_LOG_IN object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NAME_DID_LOG_OUT object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NAME_ACCESS_TOKEN_SUCESS object:nil];
}

- (instancetype)init {
    self = [super init];
    if(self) {
    
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActiveNotification)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(didChangeCity)
                                                         name:NOTIFICATION_NAME_DID_CHANGE_CITY
                                                       object:nil];
            
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(finishShowStartPage)
                                                         name:NOTIFICATION_NAME_FINISH_SHOW_START_PAGE
                                                       object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(finishShowBootPage)
                                                         name:NOTIFICATION_NAME_FINISH_SHOW_BOOT_PAGE
                                                       object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(applicationDidEnterBackground:)
                                                         name:UIApplicationDidEnterBackgroundNotification
                                                       object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(applicationWillEnterForeground:)
                                                         name:UIApplicationWillEnterForegroundNotification
                                                       object:nil];
        // Listen for receiving message notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateTipsCount)
                                                     name:NOTIFICATION_NAME_CHANGE_TIPS_COUNT
                                                   object:nil];
        //用户登陆通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loadNewData) name:NOTIFICATION_NAME_DID_LOG_IN object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loadNewData) name:NOTIFICATION_NAME_DID_LOG_OUT object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loadNewData) name:NOTIFICATION_NAME_ACCESS_TOKEN_SUCESS object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSignInSucceed) name:NOTIFICATION_NAME_SIGN_IN_SUCCEED object:nil];
        
        self.currentCityId = [CityManager readCurrentCityId];
    }
    return self;
}

- (void)finishShowStartPage
{
    if ([[AppGlobalDataManager defaultManager] isShowingBootPage] == NO) {
        if ([CityManager readRealCurrentCityId] == nil) {
            [self showCityList];
        }
    }
}
- (void)finishShowBootPage
{
    if ([CityManager readRealCurrentCityId] == nil) {
        [self showCityList];
    }
}

- (void)createCustomTitleView
{
    [_customTitleView updateWidth:[UIScreen mainScreen].bounds.size.width];
    self.navigationItem.titleView = _customTitleView;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"首页";
    [self.cityButton setTitle:[CityManager readCurrentCityName] forState:UIControlStateNormal];
    self.isOpen = NO;
    self.isCanOpenOrClose = YES;    
    self.dataTableView.hidden = YES;

    [self createCustomTitleView];
    [self.dataTableView addPullDownReloadWithTarget:self action:@selector(loadNewData)];
    [self.searchButtonBackgroundImageView setImage:[SportImage searchBackgroundImage]];
    
    //没有获取到token，获取成功之后会有通知更新
    if([[AppGlobalDataManager defaultManager].qydToken length] > 0){
        [self loadNewData];
    }
    
    self.activityIndicatorView.hidesWhenStopped = YES;
    [self.activityIndicatorView startAnimating];
    
    [self updateTableViewFooterViewHeight:100];
    
    [self performSelector:@selector(findMyLocation) withObject:nil afterDelay:1];

    [self defaultSearchBusinessData];
}

- (void)defaultSearchBusinessData {
    
    self.currentSelectedTimeInterval = 2;
    [self defaultDateAndWeek];
    [self defaultHour];
    self.currentSelectedFilterId = FILTRATE_ID_ALL;
    self.currentSelectedSoccerSelectedNumber = PEOPLE_NUMBER_ALL;
}

- (void)loadNewData
{
    if (self.isShowCityList) {
        [self showCityList];
    }
    //当前时间超显示时间的时候，刷新重置（防止一直不动，超时下拉刷新的行为）
    NSInteger currentHour = [PickerViewDataList currentHour];
    
    if (currentHour > [self.currentSelectedHourString integerValue]) {
        
        [self defaultSearchBusinessData];

    }
    
    [self queryAdData];
    
    [UserService getMessageCountList:self userId:[UserManager defaultManager].readCurrentUser.userId deviceId:[SportUUID uuid]];
}
/**
 *  获取首页数据
 */
- (void)queryAdData
{
    [self queryAdDataNoProgressView];
}

/**
 *  获取首页数据
 */
- (void)queryAdDataNoProgressView
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    CLLocation *location = [[UserManager defaultManager] readUserLocation];

    [MainService queryIndex:self
                     UserId:user.userId
                     cityId:_currentCityId
                   latitude:[NSString stringWithFormat:@"%f",location.coordinate.longitude]
                  longitude:[NSString stringWithFormat:@"%f",location.coordinate.latitude]
                 categoryId:_currentClickCategoryId];

}

- (void)findMyLocation {
    [[SuggestCityAlertManager shareManager] startSearchSuggestCity];
}

- (void)didChangeCity {
    [self.cityButton setTitle:[CityManager readCurrentCityName] forState:UIControlStateNormal];
    
    //城市更改了
    if ([_currentCityId isEqualToString:[CityManager readCurrentCityId]] == NO) {
        //清空数据
        self.adList = nil;
        self.courtJoinList = nil;
        self.venueList = nil;
        self.mainControllerCategory = nil;
        //清空选择
        self.currentClickCategoryId = nil;
        self.mainControllerCategory.currentSelectedCategoryId = nil;
        self.mainHeaderView = nil;
        self.currentCityId = [CityManager readCurrentCityId];
        //快捷找场重置数据，放在网络请求之前，防止网络延时导致重置跟着延迟
        [self defaultSearchBusinessData];
        [self.activityIndicatorView startAnimating];
        [self removeNoDataView];
        self.dataTableView.hidden = YES;
        [self loadNewData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickMessageButton:(id)sender {
    ConversationListViewController *controller = [[ConversationListViewController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.mainHeaderView.bannerView) {
        [self.mainHeaderView.bannerView resumeTimer];
    }
    if([[AppGlobalDataManager defaultManager].qydToken length] > 0){

        User *user = [[UserManager defaultManager] readCurrentUser];
    //    获取未读消息数（融云除外，是由RM接口获取）
    //    未登录也请求接口
        [UserService getMessageCountList:nil userId:user.userId deviceId:nil];
    }
    [self checkDataIsValid];
}

- (void)applicationDidBecomeActiveNotification
{
    [self checkDataIsValid];
}

- (void)checkDataIsValid
{
    //上次产生数据的日期不是今天，则新刷新数据
    if (self.mainControllerCategory && ![self.mainControllerCategory.createTime isToday]) {
        
        [self defaultSearchBusinessData];
        [self loadNewData];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.mainHeaderView.bannerView) {
        [self.mainHeaderView.bannerView pauseTimer];
    }
}

-(void)applicationDidEnterBackground:(NSNotification*)note
{
    if (self.mainHeaderView.bannerView) {
        [self.mainHeaderView.bannerView pauseTimer];
    }
}

-(void)applicationWillEnterForeground:(NSNotification*)note
{
    if (self.mainHeaderView.bannerView) {
        [self.mainHeaderView.bannerView resumeTimer];
    }
}

- (void)updateHeaderView{
    //请求的项目与当前项目不一致
    if (self.currentClickCategoryId && self.mainControllerCategory.currentSelectedCategoryId && ![self.mainControllerCategory.currentSelectedCategoryId isEqualToString:self.currentClickCategoryId]) {
        return;
    }
    
    if (_mainHeaderView == nil) {
        self.mainHeaderView = [MainHeaderView createMainHeaderViewWithDelegate:self];
    }
    
    NSArray *allCategoryList = [[BusinessCategoryManager defaultManager] currentAllCategories];
    [self.mainHeaderView updateViewWithCategoryList:allCategoryList
                                         adList:_adList
                                         venueList:self.venueList
                             mainControllerCategory:self.mainControllerCategory];
    

    
    //为了add不同的子view的时候，同步之前的约束残留
    //一定要调这一句，因为tableView的reloadData，放到里面去了，原因，因为reloadData时系统修改了tableView的偏移值，放里面主要为了不让系统改偏移值，导致页面出现异常的滑动
    [self updateHeaderViewConstraint];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
         [self defaultContentOffset];
    });
    //更新快捷找场
    [self updateSearchBusinessQuickly];
}

- (void)updateTableViewFooterViewHeight:(double)height{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, height)];
    footerView.backgroundColor = [UIColor clearColor];
    self.dataTableView.tableFooterView = footerView;
    UIButton *checkMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    checkMoreButton.frame =CGRectMake(25, 0,[UIScreen mainScreen].bounds.size.width - 50, 40);
    [checkMoreButton updateCenterX:[UIScreen mainScreen].bounds.size.width / 2];
//    [checkMoreButton setBackgroundImage:[[UIImage imageNamed:@"SearchBusinessBackground"] stretchableImageWithLeftCapWidth:20 topCapHeight:0] forState:UIControlStateNormal];
//    [checkMoreButton setBackgroundImage:[[UIImage imageNamed:@"SearchBusinessBackgroundSelected"] stretchableImageWithLeftCapWidth:20 topCapHeight:0] forState:UIControlStateHighlighted];
    [checkMoreButton addTarget:self action:@selector(clickCheckMoreButton) forControlEvents:UIControlEventTouchUpInside];
    [checkMoreButton setTitle:@"查看更多>" forState:UIControlStateNormal];
    [checkMoreButton setTitle:@"查看更多>" forState:UIControlStateHighlighted];
    [checkMoreButton setTitleColor:[UIColor hexColor:@"666666"] forState:UIControlStateNormal];
    [checkMoreButton setTitleColor:[UIColor hexColor:@"666666"] forState:UIControlStateHighlighted];
    checkMoreButton.backgroundColor = [UIColor clearColor];
    checkMoreButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    checkMoreButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [footerView addSubview:checkMoreButton];
    self.checkMoreButton = checkMoreButton;
    checkMoreButton.hidden = YES;
    
}

- (void)clickCheckMoreButton {
    if ([self.courtJoinList count] >= 5){
        
        CourtJoinListController *cjlc = [[CourtJoinListController alloc] init];
        [self.navigationController pushViewController:cjlc animated:YES];
    }
}

- (void)updateSearchBusinessQuickly {

    NSString *currentSelectedDateString = [PickerViewDataList dateFormatTransformToNSString:self.currentSelectedDate];
    
    [self.mainHeaderView updateSearchBusinessQuicklyViewWithCurrentSelectedTimeInterval:_currentSelectedTimeInterval
                                                              currentSelectedDateString:currentSelectedDateString
                                                              currentSelectedWeekString:_currentSelectedWeekString
                                                              currentSelectedHourString:_currentSelectedHourString
                                                                currentSelectedFilterId:_currentSelectedFilterId
                                                    currentSelectedSoccerSelectedNumber:_currentSelectedSoccerSelectedNumber];
}

#define signInViewHeight 67

- (void)updateHeaderViewConstraint {
    
    self.isCanOpenOrClose = NO;
    CGPoint offset = self.dataTableView.contentOffset;
    [self.dataTableView reloadData];
    self.dataTableView.tableHeaderView = self.mainHeaderView;
    
    //补footer高度，使内容至少满一屏
    double tableViewFrameHeight = [UIScreen mainScreen].bounds.size.height - 49 - 64;
    double tableViewContentHeight = self.dataTableView.contentSize.height - self.dataTableView.tableFooterView.frame.size.height;
    double footerHeight = tableViewFrameHeight + signInViewHeight - tableViewContentHeight;
    footerHeight = MAX(0, footerHeight);
    [self updateTableViewFooterViewHeight:footerHeight + 100];
    
    //判断是否超过最大可偏移量
    CGFloat canOffsetYMax = self.dataTableView.contentSize.height - tableViewFrameHeight;
    canOffsetYMax = MAX(0, canOffsetYMax);
    if (offset.y > canOffsetYMax) {
        offset = CGPointMake(offset.x, canOffsetYMax);
    }
    
    [self.dataTableView setContentOffset:offset];
    
    self.isCanOpenOrClose = YES;
}

- (void)didCLickHomeHeaderViewBanner:(SportAd *)banner
{
    if ([banner.adLink length] > 0) {
        NSURL *url = [NSURL URLWithString:banner.adLink];
        if ([GoSportUrlAnalysis isGoSportScheme:url]) {
            [GoSportUrlAnalysis pushControllerWithUrl:url NavigationController:self.navigationController];
        } else {
            SportWebController *controller = [[SportWebController alloc] initWithUrlString:banner.adLink title:banner.adName];
            
            [self.navigationController pushViewController:controller animated:NO];
        }
    }
}

- (IBAction)clickCityButton:(id)sender {
    [self showCityList];
}

- (void)showCityList
{
    self.isShowCityList = YES;
    
    //如没有token，则等token成功后才调用
    if([[AppGlobalDataManager defaultManager].qydToken length] > 0){
        CityListView *view = [CityListView createCityListView];
        [view show];
        self.isShowCityList = NO;
    }
}

- (IBAction)clickSearchButton:(id)sender {
    [MobClickUtils event:umeng_event_enter_search];
    SearchBusinessController *controller = [[SearchBusinessController alloc] initWithControllertype:ControllerTypeHome];
    controller.block = ^(NSString *clearWord){
        SearchResultController *controller = [[SearchResultController alloc] initWithSearchText:clearWord];
        [self.navigationController pushViewController:controller animated:NO];
    };
    [self presentViewController:controller animated:NO completion:nil];
}

- (void)updateTipsCount
{
    dispatch_async(dispatch_get_main_queue(), ^{
        TipNumberManager *manager = [TipNumberManager defaultManager];
        NSUInteger homeCount = manager.customerServiceMessageCount + manager.systemMessageCount + manager.salesMessageCount + manager.forumMessageCount + manager.imReceiveMessageCount;
        
        if (homeCount > 99) {
            homeCount = 99;
        }
        
        if (homeCount > 0) {
            self.rightTipsCountButton.hidden = NO;
            [self.rightTipsCountButton setTitle:[@(homeCount) stringValue] forState:UIControlStateNormal];
        } else {
            self.rightTipsCountButton.hidden = YES;
            
        }
    });
}
- (void)dataTableViewDidScroll {

    self.isCanOpenOrClose = NO;
    
//    self.dataTableView.scrollEnabled = NO;
    [UIView animateWithDuration:0.3 animations:^{
    
        if (self.isOpen) {
            //提示系统，自定义更新tableView的页面布局
            [self.dataTableView beginUpdates];
            //tableView偏移
            [self.dataTableView setContentOffset:CGPointMake(0, 0)];
            [self punchTheClockButtonUpdateConstraintIsHidden:YES];

            
        } else {
            [self.dataTableView setContentOffset:CGPointMake(0, self.mainHeaderView.recordHolderView.frame.size.height)];
            [self punchTheClockButtonUpdateConstraintIsHidden:NO];
        }
        
    } completion:^(BOOL finished) {
    
        if (self.isOpen) {
            [self.dataTableView endUpdates];
        }
        
        //可滑动
        self.dataTableView.scrollEnabled = YES;
        
        self.isCanOpenOrClose = YES;
    }];
}

- (IBAction)clickPunchTheClockButton:(id)sender {
    
    [UIView animateWithDuration:0.3 animations:^{
    
        //navBar动作
        [self punchTheClockButtonUpdateConstraintIsHidden:YES];
        self.isOpen = YES;
        [self dataTableViewDidScroll];
    }];
}

- (void)punchTheClockButtonUpdateConstraintIsHidden:(BOOL)punchTheClockButtonIsHidden {

    CGFloat navigationBarSearchHolderViewExtend = self.signInHolderView.frame.origin.x - self.navigationBarSearchHolderView.frame.origin.x + self.signInHolderView.frame.size.width;
    CGFloat navigationBarSearchHolderViewExtendShorten = self.signInHolderView.frame.origin.x - self.navigationBarSearchHolderView.frame.origin.x ;
    
    if (punchTheClockButtonIsHidden){
        //打卡按钮变透明的时候，搜索栏移过来遮住打卡view
        [self.navigationBarSearchHolderView updateWidth:navigationBarSearchHolderViewExtend];
    }else{
        [self.navigationBarSearchHolderView updateWidth:navigationBarSearchHolderViewExtendShorten];

    }
    [UIView animateWithDuration:0.3 animations:^{
        //隐藏时，将打卡button的透明设为零
        self.punchTheClockButton.alpha = punchTheClockButtonIsHidden?0:1;
    }];
}

//一开始默认偏移
- (void)defaultContentOffset {
    
    [self.dataTableView setContentOffset:CGPointMake(0, self.mainHeaderView.recordHolderView.bounds.size.height)];

}
#pragma mark - 首页数据回调
- (void)didQueryIndexWithAdList:(NSArray *)adList
                   mainControllerCategory:(MainControllerCategory *)mainControllerCategory
                             businessList:(NSArray *)businessList
                            courtJoinList:(NSArray *)courtJoinList
                                   signIn:(SignIn *)signIn
                            currentCityId:(NSString *)currentCityId
                                   status:(NSString *)status
                                      msg:(NSString *)msg
{
    //对请求城市和当前城市不一致的时候，不刷新数据
    if (self.currentCityId && [self.currentCityId isEqualToString:currentCityId] == NO) {
        return;
    }
    self.signIn = signIn;

    self.dataTableView.hidden = NO;
    
    _isLoadingAd = NO;
    [self.activityIndicatorView stopAnimating];
    
    [SportProgressView dismiss];
    
    if ([status isEqualToString:STATUS_SUCCESS]) {
        
        self.adList = adList;
        self.courtJoinList = courtJoinList;
        self.venueList = businessList;
        self.mainControllerCategory = mainControllerCategory;
        //更新头部
        [self updateHeaderView];
        [self.dataTableView reloadData];

    }else {
//        [SportProgressView dismissWithError:msg];
    }
    
//    无运动项目数据的提示，
    if ([self.mainControllerCategory.categoryList count] == 0 && ![status isEqualToString:STATUS_ACCESS_TOKEN_ERROR]) {
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44 - 49);
        if ([status isEqualToString:STATUS_SUCCESS]) {
            [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"没有相关数据"];
        } else {
            [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:@"网络错误"];
        }
    } else {
        [self removeNoDataView];
    }
    [self.dataTableView endLoad];
}

- (void)setSignIn:(SignIn *)signIn {
    _signIn = signIn;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:signIn forKey:PARA_SIGN_IN];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_DID_UPDATE_SIGN_IN_DATA object:nil userInfo:userInfo];
}
#pragma mark - courtJoinCellDelegate 
- (void)didClickDetailButton:(NSIndexPath *)indexPath {
    CourtJoinDetailController *controller = [[CourtJoinDetailController alloc]initWithCourtJoinId: [(CourtJoin *)self.courtJoinList[indexPath.row] courtJoinId]];
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - 
- (void)didClickNoDataViewRefreshButton
{
    [SportProgressView showWithStatus:@"正在加载..."];
    [self loadNewData];
}

#pragma mark - scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat offsetY = scrollView.contentOffset.y;
    
    if (self.isCanOpenOrClose) {
        if (!self.isOpen && 0 < offsetY && offsetY < self.mainHeaderView.recordHolderView.frame.size.height){
            self.isOpen = YES;
            [self dataTableViewDidScroll];
        } else if (self.isOpen && offsetY > 1) {
            self.isOpen = NO;
            [self dataTableViewDidScroll];
        }
    }
}

#pragma mark - MainHeaderViewDelegate
- (void)didClickDatePickerView {

    [self datePickerViewIsShow];
}

- (void)clickDatePickerViewNoExtraCondition {
    [self datePickerViewIsShow];
    
}

- (void)datePickerViewIsShow {
    if (self.isCanOpenOrClose == NO) {
        return;
    }
    BusinessPickerData *pickerDateData = [PickerViewDataList data];
    NSArray *array = [NSArray arrayWithObjects:pickerDateData.monthDayWeekArray, nil];
    
    //pickerView里面要显示行数
    NSInteger dateIndex = 0;
    for (int i = 0 ; i < [pickerDateData.dateArray count]; i++) {
        NSDate *one = pickerDateData.dateArray[i];
        if ([self.currentSelectedDate isEqualToDateIgnoringTime:one]) {
            dateIndex = i;
            break;
        }
    }
    NSString *dateIndexString = [NSString stringWithFormat:@"%ld",(long)dateIndex];
    NSArray *currentSelectIndexArray = [NSArray arrayWithObjects:dateIndexString, nil];
    
    typeof(self) __weak weakSelf = self;
    
    [SportStartAndEndTimePickerView popupPickerWithDataArray:array currentSelectedArray:currentSelectIndexArray currentClickPickerStyleId:CLICKDATEPICKERVIEWID  handler:^(SportStartAndEndTimePickerView *view) {
        
        int firstRow = (int)[view.dataPickerView selectedRowInComponent:0];
        //若有点击，将日期传过去为了跳转businessListController
         weakSelf.currentSelectedDate = pickerDateData.dateArray[firstRow];
        //虽然不用跳到businessListController，不过，接收是到时统一传到mainHeaderView显示用
        weakSelf.currentSelectedWeekString = pickerDateData.weekArray[firstRow];
        NSInteger startHour = [weakSelf.currentSelectedHourString integerValue];
        NSInteger currentHour = [weakSelf currentHour];
        NSInteger currentHourNextHour = currentHour + 1;

        if ([weakSelf.currentSelectedDate isToday]) {
            //23点过后，是绝对不能选前一天的了
            if (currentHour < 23) {
                //取最大值是为了针对切换日期这种情况，假如currentSelectHourString即当前选择的开始时间，在“今天”没超时，就可以选，超时了，就只能选当前的下一个小时
                NSInteger filterHour = MAX(currentHourNextHour, startHour);
                weakSelf.currentSelectedHourString = [NSString stringWithFormat:@"%ld",(long)filterHour];
                if (filterHour + weakSelf.currentSelectedTimeInterval > 24) {
                    weakSelf.currentSelectedTimeInterval = 24 - filterHour;
                }
                
            }
        }
        //更新快捷找场
        [weakSelf updateSearchBusinessQuickly];
    }];
}

- (NSString *)dateTransformationFormat:(NSString *)dateString{

    return [NSString stringWithFormat:@"%.f", [[DateUtil dateFromString:dateString DateFormat:@"yyyy-MM-dd HH:mm:ss"] timeIntervalSince1970]];
}

- (void)didClickHourPickerView {
    [self hourPickerViewIsShow];
}

- (void)clickHourPickerViewNoExtraCondition {
    [self hourPickerViewIsShow];
}

- (void)hourPickerViewIsShow {
    
    if (self.isCanOpenOrClose == NO) {
        return;
    }
    
    BusinessPickerData *pickerData = [PickerViewDataList data];
    NSArray *showList = nil;
    NSArray *valueList = nil;
    if ([self.currentSelectedDate isToday]) {
       showList = @[pickerData.todayHourArrayHaveSuffix, pickerData.timeIntervalArrayHaveSuffix];
       valueList =  @[pickerData.todayHourArrayNoSuffix, pickerData.timeIntervalArrayNoSuffix];
    } else {
       showList= @[pickerData.hourArrayHaveSuffix, pickerData.timeIntervalArrayHaveSuffix];
       valueList= @[pickerData.hourArrayNoSuffix, pickerData.timeIntervalArrayNoSuffix];
    }
    
    //pickerView里面要显示的hour行数
    NSInteger hourIndex = 0;
    for (int i = 0; i < [valueList[0] count]; i ++) {
        NSString *one = valueList[0][i];
        if ([self.currentSelectedHourString isEqualToString:one]) {
            hourIndex = i;
            break;
        }
    }
    //时段
    NSInteger timeIntervalIndexh = 0;
    for (int i = 0; i < [valueList[1] count]; i ++) {
        NSString *one = valueList[1][i];
        if ([[@(self.currentSelectedTimeInterval) stringValue] isEqualToString:one]) {
            timeIntervalIndexh = i;
            break;
        }
    }
    NSString *hourIndexString = [NSString stringWithFormat:@"%ld",(long)hourIndex];
    NSString *timeIntervalIndexString = [NSString stringWithFormat:@"%ld",(long)timeIntervalIndexh];
    NSArray *currentSelectHourIndexArray = [NSArray arrayWithObjects:hourIndexString,timeIntervalIndexString, nil];
    
    typeof(self) __weak weakSelf = self;
    [SportStartAndEndTimePickerView popupPickerWithDataArray:showList currentSelectedArray:currentSelectHourIndexArray currentClickPickerStyleId:CLICKHOURPICKERVIEWID  handler:^(SportStartAndEndTimePickerView *view) {
        
        int firstRow = (int)[view.dataPickerView selectedRowInComponent:0];
        int secondRow = (int)[view.dataPickerView selectedRowInComponent:1];
        
        int startTime = [([valueList[0] count] > firstRow ? valueList[0][firstRow] : nil) intValue];
        
        int timeInterval = [([valueList[1] count] > secondRow ? valueList[1][secondRow] : nil) intValue];
        
        //暂不判断超过当天选择时间
        if (startTime + timeInterval > 24) {
            timeInterval = 24-startTime;
        }
        //跳转用的时间（貌似只用开始时间)
        weakSelf.currentSelectedHourString = [NSString stringWithFormat:@"%d",startTime];
        //时段
        weakSelf.currentSelectedTimeInterval = timeInterval;
        //更新快捷找场
        [weakSelf updateSearchBusinessQuickly];

    }];
}

- (void)didClickExtraConditionPickerView {
    if (self.isCanOpenOrClose == NO) {
        return;
    }
    BusinessPickerData *businessPickerData = [PickerViewDataList data];
    //如果是足球的时候同时处理数据源，不显示场地人数
    if ([self.selectCategoryName isEqualToString:@"足球"]) {
        
        NSArray *list = @[businessPickerData.soccerPersonHaveSuffixArray,businessPickerData.indoorOroutdoorArray];
        
        //pickerView里面要显示的额外行数
        NSInteger soccerNumberIndex = 0;
        for (int i = 0; i < [businessPickerData.soccerPersonNoSuffixArray count]; i ++) {
            NSString *one = businessPickerData.soccerPersonNoSuffixArray[i];
            if ([self.currentSelectedSoccerSelectedNumber isEqualToString:one]) {
                soccerNumberIndex = i;
                break;
            }
        }
        
        //室内外
        NSInteger indoorOrOutIndex = 0;
        for (int i = 0; i < [businessPickerData.indoorOroutdoorIdArray count]; i ++) {
            NSString *one = businessPickerData.indoorOroutdoorIdArray[i];
            if ([self.currentSelectedFilterId isEqualToString:one]) {
                indoorOrOutIndex = i;
                break;
            }
        }
        NSString *soccerNumberIndexString = [NSString stringWithFormat:@"%ld",(long)soccerNumberIndex];
        NSString *indoorOrOutIndexString = [NSString stringWithFormat:@"%ld",(long)indoorOrOutIndex];
        NSArray *currentSelectExtraConditionIndexArray = [NSArray arrayWithObjects:soccerNumberIndexString,indoorOrOutIndexString, nil];
        
        typeof(self) __weak weakSelf = self;
        [SportStartAndEndTimePickerView popupPickerWithDataArray:list currentSelectedArray:currentSelectExtraConditionIndexArray currentClickPickerStyleId:CLICKEXTRACONDITIONID handler:^(SportStartAndEndTimePickerView *view) {
            int firstRow = (int)[view.dataPickerView selectedRowInComponent:0];
            int secondRow = (int)[view.dataPickerView selectedRowInComponent:1];
            
            //跳转用的足球人数

            if (firstRow <=[businessPickerData.soccerPersonNoSuffixArray count]) {
                
                weakSelf.currentSelectedSoccerSelectedNumber = businessPickerData.soccerPersonNoSuffixArray[firstRow];

            }
            //跳转用的室内外人数

            if (secondRow <= [businessPickerData.indoorOroutdoorIdArray count]) {
                
                weakSelf.currentSelectedFilterId = businessPickerData.indoorOroutdoorIdArray[secondRow];

            }
            //更新快捷找场
            [weakSelf updateSearchBusinessQuickly];
        }];
        
    } else {
        
        NSArray *list = @[businessPickerData.indoorOroutdoorArray];
        //pickerView里面要显示的选择行数，没有足球人数的
        NSInteger indoorOrOutIndex = 0;
        for (int i = 0; i < [businessPickerData.indoorOroutdoorIdArray count]; i ++) {
            NSString *one = businessPickerData.indoorOroutdoorIdArray[i];
            if ([self.currentSelectedFilterId isEqualToString:one]) {
                indoorOrOutIndex = i;
                break;
            }
        }
        NSString *indoorOrOutIndexString = [NSString stringWithFormat:@"%ld",(long)indoorOrOutIndex];
        NSArray *currentSelectExtraConditionIndexNoSoccerArray = [NSArray arrayWithObjects:indoorOrOutIndexString, nil];
        typeof(self) __weak weakSelf = self;
        [SportStartAndEndTimePickerView popupPickerWithDataArray:list currentSelectedArray:currentSelectExtraConditionIndexNoSoccerArray currentClickPickerStyleId:CLICKEXTRACONDITIONNOSOCCERPERSON handler:^(SportStartAndEndTimePickerView *view) {
            int firstRow = (int)[view.dataPickerView selectedRowInComponent:0];
            
            //跳转用的室内外人数

            if (firstRow <= [businessPickerData.indoorOroutdoorIdArray count]) {
                
                weakSelf.currentSelectedFilterId = businessPickerData.indoorOroutdoorIdArray[firstRow];
                
            }
            //更新快捷找场
            [weakSelf updateSearchBusinessQuickly];
        }];
    }
}

//默认的日期和星期
- (void)defaultDateAndWeek {
    BusinessPickerData *businessPickerData = [PickerViewDataList data];
    NSInteger currentHour = [PickerViewDataList currentHour];
    if (currentHour >= 21 && currentHour < 23) {
        if ([businessPickerData.dateArray count] >= 2 && [businessPickerData.weekArray count] >= 2) {
            self.currentSelectedDate = businessPickerData.dateArray[1];
            self.currentSelectedWeekString = businessPickerData.weekArray[1];
        }

    } else {
        if ([businessPickerData.dateArray count] >= 1 && [businessPickerData.weekArray count] >= 1) {

            self.currentSelectedDate = businessPickerData.dateArray[0];
            self.currentSelectedWeekString = businessPickerData.weekArray[0];
            
        }
    }

}

//默认的时间
- (void)defaultHour {
    NSInteger defaultHour = 18;
    NSInteger hour = [self currentHour];
    if (hour <21 && 18 <= hour ) {
        //默认时间是如果在18点到21点之间，那么显示下一个小时
        defaultHour = hour + 1;
    }
    self.currentSelectedHourString = [NSString stringWithFormat:@"%ld",(long)defaultHour];
}

- (NSInteger) currentHour {
    return [PickerViewDataList currentHour];
}

//默认categoryId的回调
- (void)backDefaultCategoryId:(NSString *)categoryId{
    self.currentClickCategoryId = categoryId;
}

//点击有额外情况的快速找场
- (void)didClickSearchBusinessButton {
    [self pushBusinessListController];
}

//点击没有额外情况的快速找场
- (void)didClickSearchBusinessNoExtraCondition {
     [self pushBusinessListController];
}

//进入BusinessListController
- (void)pushBusinessListController{
    if (self.isCanOpenOrClose == NO) {
        return;
    }
    
    NSInteger startHour = [self.currentSelectedHourString integerValue];
    
    BusinessListController *blc = [[BusinessListController alloc] initWithCategoryId:_currentClickCategoryId
                                                                                date:self.currentSelectedDate
                                                                           startHour:startHour
                                                                        timeTnterval:self.currentSelectedTimeInterval
                                                                        soccerNumber:self.currentSelectedSoccerSelectedNumber
                                                                    selectedFilterId:self.currentSelectedFilterId];
    
    [self.navigationController pushViewController:blc animated:YES];
}

//点击banner的委托事件
- (void)didCLickMainHeaderViewBanner:(SportAd *)banner {
    
    if (self.isCanOpenOrClose == NO) {
        return;
    }
    
    if ([banner.adLink length] > 0) {
        NSURL *url = [NSURL URLWithString:banner.adLink];
        if ([GoSportUrlAnalysis isGoSportScheme:url]) {
            [GoSportUrlAnalysis pushControllerWithUrl:url NavigationController:self.navigationController];
        } else {
            SportWebController *controller = [[SportWebController alloc] initWithUrlString:banner.adLink title:banner.adName];
            
            [self.navigationController pushViewController:controller animated:NO];
        }
    }
}
//点击banner项目按钮的委托
- (void)clickCategaryButtonWithCategoryName:(NSString *)categoryName categoryId:(NSString *)categoryId{
    self.currentClickCategoryId = categoryId;
    //获取目录name，用于判断不是足球的时候将场地人数给隐藏了
    self.selectCategoryName = categoryName;
    //快捷找场重置数据，放在网络请求之前，防止网络延时导致重置跟着延迟
    [self defaultSearchBusinessData];
    
    [self updateHeaderViewConstraint];
    //发起网络请求，更新headerView的数据
    [self loadNewData];
}
- (void)searchBusiessNoExtraConditionUpdateTableViewFrame {
    [self updateHeaderViewConstraint];
}

//点击常去推荐球馆按钮的委托
- (void)clickOftenGoBusinessButtonWithBusinessId:(NSString *)businessId categoryId:(NSString *)categoryId{
    if (self.isCanOpenOrClose == NO) {
        return;
    }
    
    BusinessDetailController *bdc = [[BusinessDetailController alloc] initWithBusinessId:businessId categoryId:categoryId];
    [self.navigationController pushViewController:bdc animated:YES];
}

//点击全部目录按钮
- (void)clickCategoryViewCategory:(BusinessCategory *)category{
    if (self.isCanOpenOrClose == NO) {
        return;
    }
    
    BusinessListController *controller = [[BusinessListController alloc] initWithCategoryId:category.businessCategoryId isFirstController:NO categoryName:category.name];
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - MainCellSectionHeaderView

- (void)didClickCheckMoreButton {
//    if ([self.courtJoinList count] >= 5){
//        
//        CourtJoinListController *cjlc = [[CourtJoinListController alloc] init];
//        [self.navigationController pushViewController:cjlc animated:YES];
//    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.courtJoinList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [CourtJoinListCell getCellIdentifier];
    CourtJoinListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [CourtJoinListCell createCell];
        cell.delegate = self;
    }
    
    cell.canJoinNumberLabel.hidden = YES;
    CourtJoin *courtJoin = [self.courtJoinList objectAtIndex:indexPath.row];
    cell.iconLabel.text = courtJoin.categoryName;
    [cell updateCellWithCourtJoin:courtJoin indexPath:indexPath];
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

- (void)didClickMainCellBuyButton:(NSIndexPath *)indexPath {
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.mainCellSectionHeaderView == nil) {
        self.mainCellSectionHeaderView = [MainCellSectionHeaderView createMainCellSectionHeaderViewWithDelegate:self];
    }
    
    if ([self.courtJoinList count] < 5) {
        self.mainCellSectionHeaderView.checkMoreLabel.hidden = YES;
        self.checkMoreButton.hidden = YES;
    }else {
        self.mainCellSectionHeaderView.checkMoreLabel.hidden = YES;
        self.checkMoreButton.hidden = NO;
    }
    
    if ([self.courtJoinList count] == 0) {
        self.mainCellSectionHeaderView.courtJoinNameLabel.hidden = YES;
    }else {
        self.mainCellSectionHeaderView.courtJoinNameLabel.hidden = NO;
    }
    return self.mainCellSectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
        return 35.0;
}

-(void)didClickNickNameButton:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.courtJoinList.count) {
        return;
    }
    
    [self showUserDetailControllerWithUserId:[(CourtJoin *)self.courtJoinList[indexPath.row] courtUserId]];
}

- (void)didSignInSucceed {
    [self queryAdData];
}

@end
