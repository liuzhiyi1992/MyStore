//
//  HomeController.m
//  Sport
//
//  Created by haodong  on 14-4-24.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "HomeController.h"
#import "UIView+Utils.h"
#import <QuartzCore/QuartzCore.h>
#import "SportAd.h"
#import "Business.h"
#import "User.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
#import "BusinessDetailController.h"
#import "SportWebController.h"
#import "MapBusinessesController.h"
#import "BusinessCategoryManager.h"
#import "BusinessCategory.h"
#import "City.h"
#import "Region.h"
#import "SportProgressView.h"
#import "UserManager.h"
#import "BusinessListController.h"
#import "BusinessListCell.h"
#import "SearchResultCell.h"
#import "BusinessCategoryManager.h"
#import "HistoryManager.h"
#import "UIView+Utils.h"
#import "BookingDetailController.h"
#import "SearchBusinessController.h"
#import "AppGlobalDataManager.h"
#import "CityManager.h"
#import "GoSportUrlAnalysis.h"
#import "HomeHeaderView.h"
#import "UIScrollView+SportRefresh.h"
#import "MonthCardBusinessDetailController.h"
#import "MonthCardHomeHeaderView.h"
#import "MonthCardCourseListCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "CourseDetailController.h"
#import "MonthCardBusinessListController.h"
#import "Order.h"
#import "ConversationListViewController.h"
#import "TipNumberManager.h"
#import "RongService.h"
#import "UITableView+Utils.h"
#import "OrderConfirmController.h"
#import "FastOrderEntrance.h"
#import "SearchResultController.h"
#import "NSDictionary+JsonValidValue.h"
#import "BusinessSearchDataManager.h"
#import "SportPopupView.h"
#import "JPushManager.h"
#import "GSJPushService.h"

typedef enum {
    HomeListTypeLike = 0,
    HomeListTypeHistory = 1,
} HomeListType;

@interface HomeController ()<UserServiceDelegate,BaseServiceDelegate>

@property (strong, nonatomic) HomeHeaderView *homeHeaderView;
@property (strong, nonatomic) HomeFooterView *homeFooterView;
@property (strong, nonatomic) FiltrateButtonView *filtrateButtonView;
@property (strong, nonatomic) NSArray *adList;
@property (assign, nonatomic) BOOL isLoadingAd;
@property (copy, nonatomic) NSString *currentCityId;
@property (strong, nonatomic) NSMutableArray *likeList;
@property (strong, nonatomic) NSArray *historyList;
@property (assign, nonatomic) HomeListType listType;

@property (strong, nonatomic) MKUserLocation *currentLocation;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (assign, nonatomic) BOOL isDidFoundUserLocation;
@property (strong, nonatomic) City *equalCity;
@property (strong, nonatomic) NSMutableArray *courseDataList;
@property (strong, nonatomic) MonthCardHomeHeaderView *headerView;
@property (strong, nonatomic) NSString *hasMoreCourse;
@property (assign, nonatomic) int finishPage;
@property (strong, nonatomic) NSArray *tempArray;
@property (weak, nonatomic) IBOutlet UIButton *rightTipsCountButton;

@property (assign, nonatomic) BOOL isLoadingHomeInfo;
@property (strong, nonatomic) FastOrderEntrance *entrance;

@end

@implementation HomeController


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NAME_FINISH_QUERY_STATIC_DATA object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NAME_FINISH_SHOW_START_PAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NAME_FINISH_SHOW_BOOT_PAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NAME_CHANGE_TIPS_COUNT object:nil];
}

- (NSMutableArray *)likeList{
    if (_likeList == nil) {
        _likeList = [[NSMutableArray alloc] init];
    }
    return _likeList;
}

- (NSMutableArray *)courseDataList{
    if (_courseDataList == nil) {
        _courseDataList = [[NSMutableArray alloc] init];
    }
    return _courseDataList;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(finishQueryStaticData)
                                                     name:NOTIFICATION_NAME_FINISH_QUERY_STATIC_DATA
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
                                                 selector:@selector(applicationWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
//         Listen for receiving message notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateTipsCount)
                                                     name:NOTIFICATION_NAME_CHANGE_TIPS_COUNT                                                   object:nil];
    
        //用户登陆通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loadNewData) name:NOTIFICATION_NAME_DID_LOG_IN object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loadNewData) name:NOTIFICATION_NAME_DID_LOG_OUT object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loadNewData) name:NOTIFICATION_NAME_ACCESS_TOKEN_SUCESS object:nil];
        
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
#define RIGHT_TOP_TIPS_COUNT_BUTTON      2015052603
#define RIGHT_TOP_RED_POINT_IMAGE_VIEW   2015052604
- (void)createCustomTitleView
{
    [_customTitleView updateWidth:[UIScreen mainScreen].bounds.size.width];
    self.navigationItem.titleView = _customTitleView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataTableView.scrollsToTop = YES;
    
    [self createCustomTitleView];
    [self.dataTableView updateHeight:[UIScreen mainScreen].bounds.size.height - 20 - 44 - 49];
    [self.dataTableView addPullDownReloadWithTarget:self action:@selector(loadNewData)];
    [self.dataTableView addPullUpLoadMoreWithTarget:self action:@selector(loadMoreData)];
    
    [self.searchButtonBackgroundImageView setImage:[SportImage searchBackgroundImage]];
    [self.cityButton setTitle:[CityManager readCurrentCityName] forState:UIControlStateNormal];
    
    UINib *cellNib = [UINib nibWithNibName:[MonthCardCourseListCell getCellIdentifier] bundle:nil];
    [self.dataTableView registerNib:cellNib forCellReuseIdentifier:[MonthCardCourseListCell getCellIdentifier]];
    self.dataTableView.hidden = YES;
    [self.activityIndicatorView startAnimating];
    
//    [self performSelector:@selector(findMyLocation) withObject:nil afterDelay:1];
    [self updateNoHistoryTipsLabel];
    
    [self.footerImageView updateOriginX:(self.footerImageView.superview.frame.size.width - self.footerImageView.frame.size.width) /2 ];
    
    self.finishPage = 0;
    
//  [self queryVenueList];
//  [self queryAdDataNoProgressView];
    
    //没有获取到token，获取成功之后会有通知更新
    if([[AppGlobalDataManager defaultManager].qydToken length] > 0){
        [self loadNewData];
    }
}

- (void)findMyLocation
{
    //请求定位
    self.locationManager = [[CLLocationManager alloc] init] ;
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = 1000; SEL selector = NSSelectorFromString(@"requestWhenInUseAuthorization");
    if ([self.locationManager respondsToSelector:selector]) {
        [self.locationManager requestWhenInUseAuthorization];
    } else {
        [self.locationManager startUpdatingLocation];
    }
    
    //定位
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)] ;
    mapView.delegate = self;
    mapView.showsUserLocation = YES;
    [self.view addSubview:mapView];
    mapView.alpha = 0.5;
    HDLog(@"<HomeController> findMyLocation");
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    HDLog(@"mapView:didUpdateUserLocation: 1");
    if (_currentLocation == nil
        || [_currentLocation.location distanceFromLocation:userLocation.location] > 300) {
        self.currentLocation = userLocation;
        
        HDLog(@"mapView:didUpdateUserLocation: 2");
        
        [[UserManager defaultManager] saveUserLocation:userLocation.location];
    }
    
    if (_isDidFoundUserLocation == NO
        && [[AppGlobalDataManager defaultManager] isShowingBootPage] == NO
        && [[AppGlobalDataManager defaultManager] isShowingCityListView] == NO) {
        self.isDidFoundUserLocation = YES;
        
        [[CityManager defaultManager] queryLocationCityName:self
                                                   latitude:userLocation.location.coordinate.latitude  //23.05 //test data
                                                  longitude:userLocation.location.coordinate.longitude]; //114.22 //test data
    }
}

#define TAG_CHANGE_CITY_ALERTVIEW 2014112601
- (void)didQueryLocationCityName:(NSString *)cityName
                        latitude:(double)latitude
                       longitude:(double)longitude
{
    City *equalCity = nil;
    for (City *city in [[CityManager defaultManager] cityList]) {
        if ([city.cityName isEqualToString:cityName]) {
            equalCity = city;
            break;
        }
    }
    
    if (equalCity) {
        [[CityManager defaultManager] setSuggestCity:equalCity];
    }
    
    //找到匹配城市，并且与当前选择城市不一致
    if (equalCity &&
        [equalCity.cityId isEqualToString:[CityManager readCurrentCityId]] == NO) {
        
        //提示换到equalCity城市
        self.equalCity = equalCity;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:[NSString stringWithFormat:@"你所在城市是%@,建议你切换到%@", equalCity.cityName, equalCity.cityName]
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定", nil];
        alertView.tag = TAG_CHANGE_CITY_ALERTVIEW;
        [alertView show];
        
    } else {
        //用经纬度对比，选择最近城市
        
        CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude] ;
        CLLocationDistance minDistance = 0;
        City *minDistanceCity = nil;
        
        int index = 0;
        for (City *city in [[CityManager defaultManager] cityList]) {
            CLLocation *cityLocation = [[CLLocation alloc] initWithLatitude:city.latitude longitude:city.longitude];
            CLLocationDistance distance = [cityLocation distanceFromLocation:currentLocation];
            if (index == 0) {
                minDistance = distance;
                minDistanceCity = city;
            } else if (distance < minDistance){
                minDistance = distance;
                minDistanceCity = city;
            }
            
            index ++;
        }
        
        if (minDistanceCity) {
            [[CityManager defaultManager] setSuggestCity:minDistanceCity];
        }
        
        if (minDistanceCity &&
            [minDistanceCity.cityId isEqualToString:[CityManager readCurrentCityId]] == NO) {

            self.equalCity = minDistanceCity;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:[NSString stringWithFormat:@"离你最近的城市是%@,建议你切换到%@", minDistanceCity.cityName, minDistanceCity.cityName]
                                                               delegate:self
                                                      cancelButtonTitle:@"取消"
                                                      otherButtonTitles:@"确定", nil];
            alertView.tag = TAG_CHANGE_CITY_ALERTVIEW;
            [alertView show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_CHANGE_CITY_ALERTVIEW) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            
//            [CityManager saveCurrentCityId:_equalCity.cityId];
//            [CityManager saveCurrentCityName:_equalCity.cityName];
//            
            [self updateCity:_equalCity];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self reloadHistory];
    
    if (self.homeHeaderView) {
        [self.homeHeaderView resumeTimer];
    }
    
    //不需要频繁调用
//    User *user = [[UserManager defaultManager] readCurrentUser];
////    //获取未读消息数（融云除外，是由RM接口获取）
////    //未登录也请求接口
//    [UserService getMessageCountList:nil userId:user.userId deviceId:nil];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.homeHeaderView) {
        [self.homeHeaderView pauseTimer];
    }
}
-(void)viewDidDisappear:(BOOL)animated{

    [super viewDidDisappear:animated];
    self.historyList=nil;

}

-(void)applicationDidEnterBackground:(NSNotification*)note
{
    if (self.homeHeaderView) {
        [self.homeHeaderView pauseTimer];
    }
}

-(void)applicationWillEnterForeground:(NSNotification*)note
{
    if (self.homeHeaderView) {
        [self.homeHeaderView resumeTimer];
    }
}

- (IBAction)clickCityButton:(id)sender {
    [self showCityList];
}

- (void)showCityList
{
    CityListView *view = [CityListView createCityListView];
    [view show];
}

- (void)didSelectCity:(City *)city 
{
    [self updateCity:city];
}

- (void)updateCity:(City *)city
{
    [self.cityButton setTitle:[CityManager readCurrentCityName] forState:UIControlStateNormal];
    if ([_currentCityId isEqualToString:city.cityId] == NO) { //change city
        self.currentCityId = city.cityId;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_DID_CHANGE_CITY object:nil userInfo:nil];
        [self loadNewData];
        [[BaseService defaultService] queryStaticData:self];
        
        [self setJPushTags];
    }
}

//每次切换城市都向极光推送设置标签
- (void)setJPushTags {
    [[JPushManager defaultManager] setJPushTags];
}

//每次切换城市的时候解析切换城市的静态场馆搜索数据0d
- (void)didQueryStaticData:(NSString *)status resultDictionary:(NSDictionary *)resultDictionary{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self saveSearchStaticData:resultDictionary];
        });
    }
}

- (void)saveSearchStaticData:(NSDictionary *)resultDictionary{
    NSString *cityID = [CityManager readCurrentCityId];
    NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
    NSArray *searchArray = [data validArrayValueForKey:VALUE_ACTION_SEARCH_STATIC_DATA];
    NSDictionary *searchDic = nil;
    for (NSDictionary *dic in searchArray) {
        NSString *searchCityID = [dic validStringValueForKey:PARA_CITY_ID];
        if ([searchCityID isEqualToString:cityID]) {
            searchDic = [NSDictionary dictionaryWithDictionary:dic];
        }
    }
    
    NSString *version = [searchDic validStringValueForKey:PARA_VERSION];
    NSString *zipFile = [searchDic validStringValueForKey:PARA_ZIPFILE];
    
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:PARA_SEARCHCITYID] isEqualToString:cityID] || ![[[NSUserDefaults standardUserDefaults] objectForKey:PARA_SEARCHVERSION] isEqualToString:version]) {
        
        [[BusinessSearchDataManager defaultManager] DownloadTextFile:zipFile cityID:cityID];
        
        [[NSUserDefaults standardUserDefaults] setObject:version forKey:PARA_SEARCHVERSION];
        [[NSUserDefaults standardUserDefaults] setObject:cityID forKey:PARA_SEARCHCITYID];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


- (IBAction)clickMessageButton:(id)sender {
    ConversationListViewController *controller = [[ConversationListViewController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)clickMapButton:(id)sender {
    [MobClickUtils event:umeng_event_click_map_from_home];
    
    MapBusinessesController *controller = [[MapBusinessesController alloc] initWithCategoryId:DEFAULT_CATEGORY_ID];
  
    [self.navigationController pushViewController:controller animated:YES];
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

/**
 *  加载第一页推荐球馆数据
 */
- (void)loadNewData
{
    self.finishPage = 0;
    [self queryVenueList];
    
    [self queryAdData];
    
    [UserService getMessageCountList:self userId:[UserManager defaultManager].readCurrentUser.userId deviceId:[SportUUID uuid]];

}

/**
 *  加载更多推荐球馆数据
 */
- (void)loadMoreData
{
    [self queryVenueList];
}

/**
 *  获取首页推荐球馆数据
 */

#define PAGE_START      1
#define COUNT_ONE_PAGE [NSString stringWithFormat:@"10"]
- (void)queryVenueList{
    User *user = [[UserManager defaultManager] readCurrentUser];
    CLLocation *location = [[UserManager defaultManager] readUserLocation];
    [HomeService queryHomeVenueList:self
                             userID:user.userId
                             cityID:_currentCityId
                                ver:@"1.2"
                          longitude:[NSString stringWithFormat:@"%f",location.coordinate.longitude]
                           latitude:[NSString stringWithFormat:@"%f",location.coordinate.latitude]
                               page:self.finishPage + 1
                              count:COUNT_ONE_PAGE];
}

/**
 *  获取首页推荐球馆数据回调
 */
- (void)didQueryHomeVenueList:(NSString *)status msg:(NSString *)msg page:(int)page businessList:(NSArray *)businessList {
    [self.dataTableView endLoad];
    if ([status isEqualToString:STATUS_SUCCESS]) {
        //用来判断点击推荐球馆按钮时列表是否要刷新
        self.tempArray = [NSArray arrayWithArray:businessList];
        
        self.finishPage = page;
        if (self.finishPage == PAGE_START) {
            self.likeList = [NSMutableArray arrayWithArray:businessList];
        }else{
            [self.likeList addObjectsFromArray:businessList];
        }

        if (self.listType == HomeListTypeLike && !([businessList count] < [COUNT_ONE_PAGE intValue])) {
                [self.dataTableView canLoadMore];
        }else{
            [self.dataTableView canNotLoadMore];
        }
        
        [self.dataTableView reloadData];
        [self updateNoHistoryTipsLabel];
    }else{
        //只有上拉加载更多的时候提示错误信息，下拉刷新时会同时调用多个接口，这个接口就不显示错误信息
        if (page > PAGE_START) {
            [SportPopupView popupWithMessage:msg];
            
        }
    }
}

/**
 *  获取首页数据
 */
- (void)queryAdData
{
    if (_isLoadingAd == NO) {
        [self queryAdDataNoProgressView];
    }
}

/**
 *  获取首页数据
 */
- (void)queryAdDataNoProgressView
{
    if (_isLoadingAd == NO) {
        _isLoadingAd = YES;
        
        User *user = [[UserManager defaultManager] readCurrentUser];
        CLLocation *location = [[UserManager defaultManager] readUserLocation];
        
        self.isLoadingHomeInfo = YES;
        
        [HomeService queryQuickBookInfo:self userId:user.userId];
        [HomeService queryHomePage:self
                            userId:user.userId
                            cityId:_currentCityId
                         longitude:[NSString stringWithFormat:@"%f",location.coordinate.longitude]
                          latitude:[NSString stringWithFormat:@"%f",location.coordinate.latitude]];
    }
}

/**
 *  获取首页数据的协议回调
 */
- (void)didQueryHomePage:(NSString *)status
                     msg:(NSString *)msg
                  adList:(NSArray *)adList
            businessList:(NSArray *)businessList
            categoryList:(NSArray *)categoryList
              courseList:(NSArray *)courseList
           hasMoreCourse:(NSString *)hasMoreCourse
{
    self.isLoadingHomeInfo = NO;
    [self.activityIndicatorView stopAnimating];
    self.dataTableView.hidden = NO;
    
    _isLoadingAd = NO;
    
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismiss];
        [self convertCourtPoolUrl:adList];
        self.adList = adList;
        self.hasMoreCourse = hasMoreCourse;
        
        NSMutableArray *recommendList = [NSMutableArray array];
        for (MonthCardCourse *course in courseList) {
            [recommendList addObject:course];
        }
        self.courseDataList = [NSMutableArray arrayWithArray:recommendList];
        
        
        [self updateHeaderView];
        [self updateFooterView];
        
        [self.dataTableView reloadData];
        [self updateNoHistoryTipsLabel];
    }else {
        [SportProgressView dismissWithError:msg];
    }
    
    //无运动项目数据的提示，首页不提示NoDataView
    if ([categoryList count] == 0 && ![status isEqualToString:STATUS_ACCESS_TOKEN_ERROR]) {
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44 - 49);
        if ([status isEqualToString:STATUS_SUCCESS]) {
            [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"没有相关数据"];
        } else {
            [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:@"网络错误"];
        }
    } else {
        [self removeNoDataView];
    }
}

-(void) didQueryQuickBookInfo:(NSString *)status entrance:(FastOrderEntrance *)entrance {
    self.entrance = entrance;
    if ([status isEqualToString:STATUS_SUCCESS]) {
        if (entrance) {
            [AppGlobalDataManager defaultManager].isShowQuickBook = YES;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                [MobClickUtils event:umeng_event_show_quick_booking];
            });

        } else {
            [AppGlobalDataManager defaultManager].isShowQuickBook = NO;
        }
        
        //如果已经加载完主界面，那么需要调整Header
        if (self.isLoadingHomeInfo == NO) {
            [self.homeHeaderView updateFastViewWithFastOrderEntrance:entrance];
            [self.dataTableView sizeHeaderToFit:self.homeHeaderView.frame.size.height];
            [self.dataTableView reloadData];
        }
    } 
}

/**
 *  更新tableHeaderView的状态
 */
- (void)updateHeaderView
{
    if (_homeHeaderView == nil) {
        self.homeHeaderView = [HomeHeaderView createHomeHeaderViewWithDelegate:self];
    }
    
    NSArray *categoryList = [[BusinessCategoryManager defaultManager] currentAllCategories];
    [self.homeHeaderView updateViewWithCategoryList:categoryList
                                         bannerList:_adList
                                         courseList:self.courseDataList
                                  fastOrderEntrance:self.entrance];
    self.dataTableView.tableHeaderView = self.homeHeaderView;
}

/**
 *  创建tableFooterView
 */
- (void)updateFooterView{
    if (_homeFooterView == nil) {
        self.homeFooterView = [HomeFooterView createHomeFooterViewWithDelegate:self];
    }
    [self initFooterView];
    if (self.listType == HomeListTypeHistory) {
        self.dataTableView.tableFooterView = self.homeFooterView;
    }else{
        self.dataTableView.tableFooterView = nil;
    }
}

/**
 *  更新tableFooterView的状态
 */
- (void)initFooterView{
    BOOL isHiden;
    if (self.listType == HomeListTypeLike) {
        isHiden = YES;
    }else{
        isHiden = NO;
    }
    
    [self.homeFooterView updateFooterViewWithIsHidebutton:isHiden hasMoreCourse:self.hasMoreCourse courseList:self.courseDataList];
}

/**
 *  点击查看更多
 */
- (void)didClickLookMoreButton{
    [MobClickUtils event:umeng_event_click_home_ckeck_more_button];
    
    MonthCardBusinessListController *controller = [[MonthCardBusinessListController alloc]initWithType:SELECTED_LIST_COURSE];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didClickNoDataViewRefreshButton
{
    [SportProgressView showWithStatus:@"正在加载..."];
    [self loadNewData];
}

- (void)finishQueryStaticData{
    //[self reloadCategorysView];
}

- (void)reloadHistory
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.historyList = [[HistoryManager defaultManager] findAllBusinesses];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_listType == HomeListTypeHistory) {
                [self.dataTableView reloadData];
                [self updateNoHistoryTipsLabel];
            }
        });
    });
}

- (void)didClickHomeHeaderViewCategory:(BusinessCategory *)category
{
    BusinessListController *controller = [[BusinessListController alloc] initWithCategoryId:category.businessCategoryId isFirstController:NO categoryName:category.name];
   
    [self.navigationController pushViewController:controller animated:YES];
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

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_listType == HomeListTypeLike) {
        return [_likeList count];
    } else {
        if (self.courseDataList.count == 0) {
            return [_historyList count];
        }else{
            return [self.courseDataList count];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (_listType == HomeListTypeLike) {
        NSString *identifier = [BookHomeCell getCellIdentifier];
        BookHomeCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [BookHomeCell createCell];
            cell.delegate = self;
        }
        
        //workaround for IOS 7 auto layout bug
        if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
        {
            cell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
        }
        
        BOOL isLast = (indexPath.row == [_likeList count] - 1);

        Business *business = [_likeList objectAtIndex:indexPath.row];
        [cell updateCellWithBusiness:business indexPath:indexPath isLast:isLast];
        
        return cell;
    } else {
        if (self.courseDataList.count == 0) {
            NSString *identifier = [SearchResultCell getCellIdentifier];
            SearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [SearchResultCell createCell];
            }
            
            //workaround for IOS 7 auto layout bug
            if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
            {
                cell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
            }
            
            BOOL isLast = (indexPath.row == [_historyList count] - 1);
            Business *business = [_historyList objectAtIndex:indexPath.row];
            [cell updateCell:business indexPath:indexPath isLast:isLast isShowCategory:NO searchText:nil];
            
            return cell;
        }else{
            NSString *identifier = [MonthCardCourseListCell getCellIdentifier];
            
            MonthCardCourseListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            [self configureCell:cell atIndexPath:indexPath];
            
            return cell;
        }
        
    }
}

- (void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    NSArray *dataList;
    if ([_courseDataList count] == 0) {
        return;
    }
    
    dataList = _courseDataList;
    cell = (MonthCardCourseListCell *)cell;
    MonthCardCourse *course = [dataList objectAtIndex:indexPath.row];
    BOOL isLast = (indexPath.row == [dataList count] - 1);
    [(MonthCardCourseListCell *)cell updateCell:course indexPath:indexPath isLast:isLast];
    
    cell.fd_enforceFrameLayout = NO;
    return;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_listType == HomeListTypeLike) {
        return [BookHomeCell getCellHeight];
    } else {
        if (self.courseDataList.count == 0) {
            Business *business = [_historyList objectAtIndex:indexPath.row];
            if (business.neighborhood.length > 0) {
                return 100;
            }else{
                return 75;
            }
        }else{
            NSString *identifier = [MonthCardCourseListCell getCellIdentifier];
            return [tableView fd_heightForCellWithIdentifier:identifier configuration:^(MonthCardCourseListCell *cell) {
                [self configureCell:cell atIndexPath:indexPath];
            }];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Business *business = nil;
    SportController *controller = nil;
    if (_listType == HomeListTypeLike) {   
        business = [_likeList objectAtIndex:indexPath.row];
        controller = [[BusinessDetailController alloc] initWithBusinessId:business.businessId categoryId:business.defaultCategoryId];
        [MobClickUtils event:umeng_event_click_home_recommend_venue];
    } else {
        if (self.courseDataList.count == 0) {
            business = [_historyList objectAtIndex:indexPath.row];
            controller = [[BusinessDetailController alloc] initWithBusinessId:business.businessId categoryId:business.defaultCategoryId];
        }else{
            [MobClickUtils event:umeng_event_click_home_recommend_course];
            MonthCardCourse *course = self.courseDataList[indexPath.row];
            controller = [[CourseDetailController alloc]initWithCourse:course];
        }
    }
    
    [self.navigationController pushViewController:controller animated:YES];
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

- (void)didClickBookHomeCellBuyButton:(NSIndexPath *)indexPath
{
    Business *business = [_likeList objectAtIndex:indexPath.row];
    
    if (business.orderType == OrderTypeDefault && business.canOrder) {
        [MobClickUtils event:umeng_event_click_home_booking_button];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
        [formatter setDateFormat:@"H"];
        int nowHour = [[formatter stringFromDate:[NSDate date]] intValue];
        
        //如果现在的时间已经过了球馆的营业时间，则打开第二天的数据
        NSDate *defaultDate = nil;
        if (nowHour > business.endHour) {
            defaultDate = [NSDate dateWithTimeIntervalSinceNow:24 * 60 * 60];
        } else {
            defaultDate = [NSDate date];
        }
        
        BookingDetailController *controller = [[BookingDetailController alloc] initWithBusinessId:business.businessId categoryId:business.defaultCategoryId date:defaultDate] ;
        
        [self.navigationController pushViewController:controller animated:YES];
    
    } else {
        BusinessDetailController *controller = [[BusinessDetailController alloc] initWithBusinessId:business.businessId categoryId:business.defaultCategoryId];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.filtrateButtonView == nil) {
        self.filtrateButtonView = [FiltrateButtonView createFiltrateButtonViewWithDelegate:self];
    }
 
    [self.filtrateButtonView updateViewWithCourseList:self.courseDataList];
    return self.filtrateButtonView;
}

#define FILTRATEVIEWHEIGHT 45
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return FILTRATEVIEWHEIGHT;
}

#pragma mark - FiltrateButtonViewDelegate
//点击推荐场馆按钮
- (void)didClickVenueButton{
    self.listType = HomeListTypeLike;
    
    if ([self.tempArray count] < [COUNT_ONE_PAGE intValue]) {
        [self.dataTableView canNotLoadMore];
    } else {
        [self.dataTableView canLoadMore];
    }
    
    [self updateFooterView];
    [self.dataTableView reloadData];
    
    [self updateNoHistoryTipsLabel];
}

//点击推荐课程按钮
- (void)didClickCourseButton{
    self.listType = HomeListTypeHistory;
    [self.dataTableView canNotLoadMore];
    [self updateFooterView];
    [self.dataTableView reloadData];
    
    [self updateNoHistoryTipsLabel];
}

//没数据时显示的内容
- (void)updateNoHistoryTipsLabel
{
    if (_listType == HomeListTypeHistory && [_courseDataList count] == 0 && [_historyList count] == 0) {
        [self.homeHeaderView showNoListDataTipsWithText:@"最近没有浏览任何场馆哦"];
        self.dataTableView.tableFooterView = nil;
    } else if (_listType == HomeListTypeLike && [_likeList count] == 0) {
        [self.homeHeaderView showNoListDataTipsWithText:@"暂无推荐场馆"];
        self.dataTableView.tableFooterView = nil;
    } else {
        [self.homeHeaderView hideNoListDataTips];
    }
}

-(void)updateTipsCount
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

-(void)didClickFastOrderButton:(FastOrderEntrance *)entrance {
    [MobClickUtils event:umeng_event_click_quick_booking];
    Order *order = [[Order alloc]init];
    
    order.productList = entrance.goodsList;
    order.categoryId = entrance.categoryId;
    order.categoryName = entrance.categoryName;
    order.useDate = entrance.bookDate;
    order.businessId = entrance.businessId;
    order.businessName = entrance.businessName;
    
    OrderConfirmController *controller = [[OrderConfirmController alloc]initWithOrderFromQuickBooking:order];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)convertCourtPoolUrl:(NSArray *)adList {
    for (SportAd *ad in adList) {
        if ([ad.adLink rangeOfString:@"/courtpool/index?from=app"].length == 0) {
            continue;
        }
        
        NSMutableString *urlString = [[NSMutableString alloc] init];

        [urlString appendString:ad.adLink];
        
        [urlString appendFormat:@"&device_id=%@", [SportUUID uuid]];
        
        User *user = [[UserManager defaultManager] readCurrentUser];
        if ([user.userId length] > 0) {
            [urlString appendFormat:@"&user_id=%@", user.userId];
        }
        
        ad.adLink = urlString;
    }

}

@end
