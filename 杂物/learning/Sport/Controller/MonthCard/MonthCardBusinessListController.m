//
//  MonthCardBusinessListController.m
//  Sport
//
//  Created by 江彦聪 on 15/5/19.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "MonthCardBusinessListController.h"
#import "UIScrollView+SportRefresh.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "MonthCardSectionHeaderView.h"
#import "BusinessCategory.h"
#import "BusinessCategoryManager.h"
#import "CityManager.h"
#import "City.h"
#import "Region.h"
#import "BaseService.h"
#import "UserManager.h"
#import "MonthCardBusinessDetailController.h"
#import "SportPopupView.h"
#import "SportProgressView.h"
#import "SportHistoryController.h"
#import "DateUtil.h"
#import "CourseDetailController.h"

@interface MonthCardBusinessListController ()
@property (strong, nonatomic) NSMutableArray *venuesDataList;
@property (strong, nonatomic) NSMutableArray *courseDataList;
@property (assign, nonatomic) int venuesFinishPage;
@property (assign, nonatomic) int courseFinishPage;
@property (weak, nonatomic) IBOutlet UIView *venuesListView;
@property (weak, nonatomic) IBOutlet UIView *courseListView;
@property (assign, nonatomic) SELECTED_LIST selectedList;

@property (strong, nonatomic) NSMutableArray *selectedCategoryIdList;
@property (strong, nonatomic) NSMutableArray *selectedRegionIdList;
@property (strong, nonatomic) NSDate *selectedDate;
@property (strong, nonatomic) CityManager *cityManager;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *filterButtonCollection;
@property (weak, nonatomic) IBOutlet UIView *venuesFilterView;
@property (weak, nonatomic) IBOutlet UIView *courseFilterView;
@property (strong, nonatomic) NSArray *oneWeekDateList;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation MonthCardBusinessListController

#define COLOR_NORMAL    [UIColor colorWithRed:147.0/255.0 green:147.0/255.0 blue:147.0/255.0 alpha:1]
#define COLOR_SELECTED  [SportColor defaultColor]

#define TAG_REGION_FILTER_LIST_VIEW     2014072201
#define TAG_SORT_FILTER_LIST_VIEW       2014072202
#define TAG_MORE_FILTER_LIST_VIEW       2014072203
#define TAG_CATEGORY_FILTER_LIST_VIEW   2014091301
#define TAG_DATE_FILTER_LIST_VIEW       2015060801

#define TAG_VENUES_BUTTON_BASE 10
#define TAG_COURSE_BUTTON_BASE 20

-(id)initWithType:(SELECTED_LIST)type
{
    self = [super init];
    if (self) {
        self.selectedList = type;
    }
    
    return self;
}

-(CityManager *)cityManager
{
    if (_cityManager == nil) {
        _cityManager = [CityManager defaultManager];
        
        if ([_cityManager.cityList count] == 0) {
            [[BaseService defaultService] queryCityList:nil];
        }
    }

    return _cityManager;
}

-(NSMutableArray *)venuesDataList
{
    if (_venuesDataList == nil) {
        _venuesDataList = [[NSMutableArray alloc]initWithCapacity:2];
    }
    
    return _venuesDataList;
}

-(NSMutableArray *)courseDataList
{
    if (_courseDataList == nil) {
        _courseDataList = [[NSMutableArray alloc]initWithCapacity:2];
    }
    
    return _courseDataList;
}

-(NSArray *)oneWeekDateList
{
    if (_oneWeekDateList == nil) {
        _oneWeekDateList = [DateUtil parseOneWeekDateList];
    }
    
    return _oneWeekDateList;
}

-(NSMutableArray *)selectedCategoryIdList
{
    if (_selectedCategoryIdList == nil) {
        _selectedCategoryIdList = [NSMutableArray arrayWithArray:@[MONTHCARD_CATEGORY_ID_ALL, MONTHCARD_CATEGORY_ID_ALL]];
    }
    
    return _selectedCategoryIdList;
}

-(NSMutableArray *)selectedRegionIdList
{
    if (_selectedRegionIdList == nil) {
        _selectedRegionIdList = [NSMutableArray arrayWithArray:@[MONTHCARD_REGION_ID_ALL, MONTHCARD_REGION_ID_ALL]];
    }
    
    return _selectedRegionIdList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
//    [self createTitleViewWithleftButtonTitle:@"锻炼" rightButtonTitle:@"上课"];
    if (self.selectedList == SELECTED_LIST_COURSE) {
        self.title = @"精品课程";
    }else{
        self.title = @"我要锻炼";
    }
    
    //默认锻炼热门
    if (self.selectedList == SELECTED_LIST_VENUES) {
        [self selectedLeftButton];
    } else {
        [self selectedRightButton];
    }
    
    //设置下拉更新
    [self.tableView addPullDownReloadWithTarget:self action:@selector(loadNewData)];
    
    //设置上拉加载更多
    [self.tableView addPullUpLoadMoreWithTarget:self action:@selector(loadMoreData)];

    [self.tableView beginReload];
    
    self.tableView.fd_debugLogEnabled = NO;
    UINib *cellNib = [UINib nibWithNibName:[MonthCardVenuesListCell getCellIdentifier] bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:[MonthCardVenuesListCell getCellIdentifier]];
    cellNib = [UINib nibWithNibName:[MonthCardCourseListCell getCellIdentifier] bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:[MonthCardCourseListCell getCellIdentifier]];
    
    //重用headerView
    [self.tableView registerNib:[UINib nibWithNibName:[MonthCardSectionHeaderView getCellIdentifier] bundle:nil] forHeaderFooterViewReuseIdentifier:[MonthCardSectionHeaderView getCellIdentifier]];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.scrollsToTop = YES;
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
        self.tableView.estimatedRowHeight = 110.0f;
    }
    
    [self initButtons];
    
    [self updateButtons];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//下拉刷新
- (void)beginRefreshing
{
    [self.tableView beginReload];
}

#define COUNT_ONE_PAGE  10
#define PAGE_START      1
- (void)loadNewData
{
    self.venuesFinishPage = 0;
    self.courseFinishPage = 0;
    [self queryData];
}

- (void)loadMoreData
{
    [self queryData];
}

- (void)queryData
{
    NSString *categoryId = self.selectedCategoryIdList[self.selectedList];
    NSString *regionId = self.selectedRegionIdList[self.selectedList];
    double latitude = [[UserManager defaultManager] readUserLocation].coordinate.latitude;
    double longitude = [[UserManager defaultManager] readUserLocation].coordinate.longitude;
    
    
    if ([regionId isEqualToString:MONTHCARD_REGION_ID_ALL]) {
        regionId = nil;
    }
    
    if ([categoryId isEqualToString:MONTHCARD_CATEGORY_ID_ALL]) {
        categoryId = nil;
    }
    
    if (self.selectedList == SELECTED_LIST_VENUES) {
        [MonthCardService getVenuesList:self
                             categoryId:categoryId
                                 cityId:[CityManager readCurrentCityId]
                               regionId:regionId
                               latitude:(double)latitude
                              longitude:(double)longitude
                                  count:COUNT_ONE_PAGE
                                   page:self.venuesFinishPage+1];
    }else {
        
        NSString *dateString = [DateUtil stringFromDate:self.selectedDate DateFormat:@"yyyy-MM-dd"];
        [MonthCardService getCourseList:self
                             categoryId:categoryId
                                 cityId:[CityManager readCurrentCityId]
                               regionId:regionId
                                   date:dateString
                               latitude:(double)latitude
                              longitude:(double)longitude
                                  count:COUNT_ONE_PAGE
                                   page:self.courseFinishPage+1];
    }
}


- (void)showNoDataViewWithType:(NoDataType)type
                          tips:(NSString *)tips
{
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44 - self.venuesFilterView.frame.size.height);
    [self.noDataView removeFromSuperview];
    self.noDataView = [NoDataView createNoDataViewWithFrame:frame
                                                       type:type
                                                       tips:tips];
    self.noDataView.delegate = self;
    [self.tableView addSubview:self.noDataView];
    //[super showNoDataViewWithType:type frame:frame tips:tips];
}


- (void)didGetVenuesList:(NSArray *)list
                  page:(NSUInteger)page
                status:(NSString *)status
                   msg:(NSString *)msg
{
    [self.tableView endLoad];
    [SportProgressView dismiss];
    if ([status isEqualToString:STATUS_SUCCESS]) {
        NSMutableArray *recommendList = [NSMutableArray array];
        NSMutableArray *otherList = [NSMutableArray array];
        for (Business *business in list) {
            if (business.isRecommend) {
                [recommendList addObject:business];
            } else {
                [otherList addObject:business];
            }
        }
        
        if (page == PAGE_START) {
            self.venuesDataList[0] = recommendList;
            self.venuesDataList[1] = otherList;
        } else {
            [self.venuesDataList[0] addObjectsFromArray:recommendList];
            [self.venuesDataList[1] addObjectsFromArray:otherList];
        }
        
        self.venuesFinishPage ++;

        if ([list count] < COUNT_ONE_PAGE) {
            [self.tableView canNotLoadMore];
        } else {
            [self.tableView canLoadMore];
        }
    }else {
        [SportPopupView popupWithMessage:msg];
    }
    
    if ([(NSArray *)self.venuesDataList count] == 0 || ([(NSArray *)self.venuesDataList[0] count] == 0 && [(NSArray *)self.venuesDataList[1] count] == 0)) {
        if ([status isEqualToString:STATUS_SUCCESS]) {
            [self showNoDataViewWithType:NoDataTypeDefault tips:@"没有相关数据"];
        } else {
            [self showNoDataViewWithType:NoDataTypeNetworkError tips:@"网络错误"];
        }
    } else {
        [self removeNoDataView];
    }
        
    [self.tableView reloadData];
}

- (void)didGetCourseList:(NSArray *)list
                    page:(NSUInteger)page
                  status:(NSString *)status
                     msg:(NSString *)msg
{
    [self.tableView endLoad];
    [SportProgressView dismiss];
    if ([status isEqualToString:STATUS_SUCCESS]) {
        NSMutableArray *recommendList = [NSMutableArray array];
        NSMutableArray *otherList = [NSMutableArray array];
        for (MonthCardCourse *course in list) {
            if (course.isRecommend) {
                [recommendList addObject:course];
            } else {
                [otherList addObject:course];
            }
        }
        
        if (page == PAGE_START) {
            self.courseDataList[0] = recommendList;
            self.courseDataList[1] = otherList;
        } else {
            [self.courseDataList[0] addObjectsFromArray:recommendList];
            [self.courseDataList[1] addObjectsFromArray:otherList];
        }
        
        self.courseFinishPage ++;
        
        if ([list count] < COUNT_ONE_PAGE) {
            [self.tableView canNotLoadMore];
        } else {
            [self.tableView canLoadMore];
        }
    }else {
        [SportPopupView popupWithMessage:msg];
    }
    
    if ([(NSArray *)self.courseDataList count] == 0 || ([(NSArray *)self.courseDataList[0] count] == 0 && [(NSArray *)self.courseDataList[1] count] == 0)) {
        if ([status isEqualToString:STATUS_SUCCESS]) {
            [self showNoDataViewWithType:NoDataTypeDefault tips:@"没有相关数据"];
        } else {
            [self showNoDataViewWithType:NoDataTypeNetworkError tips:@"网络错误"];
        }
    } else {
        [self removeNoDataView];
    }
    
    [self.tableView reloadData];
}

- (void)didClickNoDataViewRefreshButton
{
    [self loadNewData];
}

- (void)selectedLeftButton
{
//    self.selectedRegionId = MONTHCARD_REGION_ID_ALL;
//    self.selectedCategoryId = MONTHCARD_CATEGORY_ID_ALL;
    self.selectedList = SELECTED_LIST_VENUES;
    self.venuesListView.hidden = NO;
    self.courseListView.hidden = YES;
    
    [self updateButtons];
    [self.tableView reloadData];
    
    //如果上一次是无数据或者第一次加载，才重新load
    if ([self.venuesDataList count] == 0) {
        [self.tableView beginReload];
    } else {
        if ([(NSArray *)self.venuesDataList[0] count] == 0 && [(NSArray *)self.venuesDataList[1] count] == 0) {
            [self showNoDataViewWithType:NoDataTypeDefault tips:@"没有相关数据"];
        }else {
            [self removeNoDataView];
        }
    }
    
    [super selectedLeftButton];
}

- (void)selectedRightButton
{
//    self.selectedRegionId = MONTHCARD_REGION_ID_ALL;
//    self.selectedCategoryId = MONTHCARD_CATEGORY_ID_ALL;
    
    self.selectedList = SELECTED_LIST_COURSE;
    self.venuesListView.hidden = YES;
    self.courseListView.hidden = NO;
    [self updateButtons];
    [self.tableView reloadData];
    
    //如果第一次加载，才重新load
    if ([self.courseDataList count] == 0) {
        [self.tableView beginReload];
    } else {
        if (([(NSArray *)self.courseDataList[0] count] == 0 && [(NSArray *)self.courseDataList[1] count] == 0)) {
            [self showNoDataViewWithType:NoDataTypeDefault tips:@"没有相关数据"];
        }else {
            [self removeNoDataView];
        }
    }
    [super selectedRightButton];
}

- (void)clickLeftTitleButton:(id)sender
{
    [MobClickUtils event:umeng_event_month_click_tab_exercise];
    [super clickLeftTitleButton:sender];
}

- (void)clickRightTitleButton:(id)sender
{
    [MobClickUtils event:umeng_event_month_click_tab_course];
    [super clickRightTitleButton:sender];
}

- (void)initButtons
{
    self.oneWeekDateList = [DateUtil parseOneWeekDateList];
    
//    self.selectedCategoryId = MONTHCARD_CATEGORY_ID_ALL;
//    self.selectedRegionId = MONTHCARD_REGION_ID_ALL;
    
    //如果超过当天晚上8点时，默认查询第二天的数据
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = kCFCalendarUnitHour;
    NSDateComponents *nowCmp = [calendar components:unit fromDate:[NSDate date]];
    if (nowCmp.hour >= 20) {
        self.selectedDate = self.oneWeekDateList[1];
    } else {
        self.selectedDate = self.oneWeekDateList[0];
    }
    
    for (UIButton *button in self.filterButtonCollection)
    {
        [button setBackgroundImage:[SportImage listFilterButtonImage] forState:UIControlStateNormal];
        [button setBackgroundImage:[SportImage listFilterButtonSelectedImage] forState:UIControlStateSelected];
        [button setTitleColor:COLOR_NORMAL forState:UIControlStateNormal];
        [button setTitleColor:COLOR_SELECTED forState:UIControlStateSelected];
        
                button.highlighted=NO;
        [button setAdjustsImageWhenHighlighted:NO];
        
    
        
        
        
    }
}

- (void)updateButtons
{
    UIButton *categoryButton;
    UIButton *regionButton;
    UIButton *timeButton;
    NSString *categoryId = self.selectedCategoryIdList[self.selectedList];
    NSString *regionId = self.selectedRegionIdList[self.selectedList];

    
    if (self.selectedList == SELECTED_LIST_VENUES) {
        categoryButton = (UIButton *)[self.venuesFilterView viewWithTag:TAG_VENUES_BUTTON_BASE];
        regionButton = (UIButton *)[self.venuesFilterView viewWithTag:TAG_VENUES_BUTTON_BASE + 1];
    } else {
        categoryButton = (UIButton *)[self.courseFilterView viewWithTag:TAG_COURSE_BUTTON_BASE];
        regionButton = (UIButton *)[self.courseFilterView viewWithTag:TAG_COURSE_BUTTON_BASE + 1];
        timeButton = (UIButton *)[self.courseFilterView viewWithTag:TAG_COURSE_BUTTON_BASE + 2];
    }
    
    [categoryButton setTitle:[[BusinessCategoryManager defaultManager] monthCardCategoryNameById:categoryId] forState:UIControlStateNormal];
    NSString *currentCityId = [CityManager readCurrentCityId];
    [regionButton setTitle:[self.cityManager regionName:regionId cityId:currentCityId] forState:UIControlStateNormal];
    
    NSString *dateString = [DateUtil stringFromDate:self.selectedDate DateFormat:@"M月d日"];
    [timeButton setTitle:dateString forState:UIControlStateNormal];
    
    self.venuesFinishPage = 0;
    self.courseFinishPage = 0;
}

- (void)didSelectSportFilterListView:(SportFilterListView *)sportFilterListView indexPath:(NSIndexPath *)indexPath
{
    if (sportFilterListView.tag == TAG_REGION_FILTER_LIST_VIEW) {
        if (indexPath.row == 0) {
            self.selectedRegionIdList[self.selectedList] = MONTHCARD_REGION_ID_ALL;
        } else {
            self.selectedRegionIdList[self.selectedList] = [(Region *)[[CityManager readCurrentCity].regionList objectAtIndex:indexPath.row - 1] regionId];
        }
        
        //友盟统计
        if (self.selectedList == SELECTED_LIST_VENUES) {
            [MobClickUtils event:umeng_event_month_venues_list_area_screening];
        } else {
            [MobClickUtils event:umeng_event_month_course_list_area_screening];
        }
    } else if (sportFilterListView.tag == TAG_CATEGORY_FILTER_LIST_VIEW) {
        if (indexPath.row == 0) {
            self.selectedCategoryIdList[self.selectedList] = MONTHCARD_CATEGORY_ID_ALL;
        }else {
            BusinessCategory *category = [[[BusinessCategoryManager defaultManager] monthCardAllCategories] objectAtIndex:indexPath.row - 1];
            self.selectedCategoryIdList[self.selectedList] = category.businessCategoryId;
        }
        
        //友盟统计
        if (self.selectedList == SELECTED_LIST_VENUES) {
            [MobClickUtils event:umeng_event_month_venues_list_categories_screening];
        } else {
            [MobClickUtils event:umeng_event_month_course_list_categories_screening];
        }
    }else if (sportFilterListView.tag == TAG_DATE_FILTER_LIST_VIEW) {
        self.selectedDate = [self.oneWeekDateList objectAtIndex:indexPath.row];
        
        //友盟统计
        [MobClickUtils event:umeng_event_month_course_list_time_screening];
    }

    [self updateButtons];
    [SportProgressView showWithStatus:@"加载中"];
    [self queryData];
}

- (IBAction)clickCategoryButton:(id)sender {
    //[MobClickUtils event:umeng_event_business_list_filter_category];
    UIButton *button = sender;
    
    button.selected = !button.selected;
    
    SportFilterListView *view = (SportFilterListView *)[self.view viewWithTag:TAG_CATEGORY_FILTER_LIST_VIEW];
    if (view) {
        [view hide];
        return;
    }
    
    int selectedRow = 0;
    int index = 1;
    NSMutableArray *mutableArray = [NSMutableArray array];
    [mutableArray addObject:MONTHCARD_CATEGORY_NAME_ALL];
    for (BusinessCategory *category in [[BusinessCategoryManager defaultManager] monthCardAllCategories]) {
        if ([self.selectedCategoryIdList[self.selectedList] isEqualToString:category.businessCategoryId]) {
            selectedRow = index;
        }
        [mutableArray addObject:category.name];
        index ++;
    }
    
//    for (BusinessCategory *category in [[BusinessCategoryManager defaultManager] currentAllCategories]) {
//        if ([self.selectedCategoryIdList[self.selectedList] isEqualToString:category.businessCategoryId]) {
//            selectedRow = index;
//        }
//        [iconUrlArray addObject:category.iconUrl];
//        index ++;
//    }

    
    SportFilterListView *filterListView = [SportFilterListView createSportFilterListViewWithDataList:mutableArray selectedRow:selectedRow];
    filterListView.delegate = self;
    filterListView.holderButton = button;
    filterListView.tag = TAG_CATEGORY_FILTER_LIST_VIEW;
    [filterListView showInView:self.view y:40];
    
//    //显示
//    [SportFilterListView showInView:self.view
//                                  y:40
//                                tag:TAG_CATEGORY_FILTER_LIST_VIEW
//                           dataList:mutableArray
//                        selectedRow:selectedRow
//                           delegate:self
//                       holderButton:button
//                       imageUrlList:iconUrlArray
//               selectedImageUrlList:iconUrlArray];
}

- (IBAction)clickRegionButton:(id)sender {
    //[MobClickUtils event:umeng_event_business_list_filter_region];
    UIButton *button = sender;
    button.selected = !button.selected;
    
    SportFilterListView *view = (SportFilterListView *)[self.view viewWithTag:TAG_REGION_FILTER_LIST_VIEW];
    if (view) {
        [view hide];
        return;
    }
    
    int selectedRow = 0;
    NSMutableArray *mutableArray = [NSMutableArray array];
    [mutableArray addObject:MONTHCARD_REGION_NAME_ALL];
    
    int index = 1;
    for (Region *region in [CityManager readCurrentCity].regionList) {
        [mutableArray addObject:region.regionName];
        if ([region.regionId isEqualToString:self.selectedRegionIdList[self.selectedList]]) {
            selectedRow = index;
        }
        index ++;
    }
    
    SportFilterListView *filterListView = [SportFilterListView createSportFilterListViewWithDataList:mutableArray selectedRow:selectedRow];
    filterListView.delegate = self;
    filterListView.holderButton = button;
    filterListView.tag = TAG_REGION_FILTER_LIST_VIEW;
    [filterListView showInView:self.view y:40];
}

- (IBAction)clickTimeButton:(id)sender {
    //[MobClickUtils event:umeng_event_business_list_filter_region];
    UIButton *button = sender;
    button.selected = !button.selected;
    
    SportFilterListView *view = (SportFilterListView *)[self.view viewWithTag:TAG_DATE_FILTER_LIST_VIEW];
    if (view) {
        [view hide];
        return;
    }
    
    int selectedRow = 0;
    NSMutableArray *mutableArray = [NSMutableArray array];
    
    int index = 0;
    for (NSDate *date in self.oneWeekDateList) {
        NSString *dateString = [DateUtil stringFromDate:date DateFormat:@"M月d日"];
        
        [mutableArray addObject:dateString];
        if (self.selectedDate == date) {
            selectedRow = index;
        }
        index ++;
    }
    
    SportFilterListView *filterListView = [SportFilterListView createSportFilterListViewWithDataList:mutableArray selectedRow:selectedRow];
    filterListView.delegate = self;
    filterListView.holderButton = button;
    filterListView.tag = TAG_DATE_FILTER_LIST_VIEW;
    [filterListView showInView:self.view y:40];
}

#pragma mark tableView的delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray *dataList;
    if (self.selectedList == SELECTED_LIST_VENUES) {
        dataList = _venuesDataList;
    } else {
        dataList = _courseDataList;
    }

    if ([dataList count] == 0) {
        return 0;
    }
    
    return [dataList count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *dataList;
    if (self.selectedList == SELECTED_LIST_VENUES) {
        dataList = _venuesDataList;
    } else {
        dataList = _courseDataList;
    }
    
    if ([dataList count] == 0) {
        return 0;
    }
    return [(NSArray *)[dataList objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.selectedList == SELECTED_LIST_VENUES) {
        if ([(NSArray *)[self.venuesDataList objectAtIndex:section] count] == 0) {
            return 0;
        }
    } else {
        if ([(NSArray *)[self.courseDataList objectAtIndex:section] count] == 0) {
            return 0;
        }
    }

    MonthCardSectionHeaderView *header=[tableView dequeueReusableHeaderFooterViewWithIdentifier:[MonthCardSectionHeaderView getCellIdentifier]];
    return header.frame.size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    MonthCardSectionHeaderView *header=[tableView dequeueReusableHeaderFooterViewWithIdentifier:[MonthCardSectionHeaderView getCellIdentifier]];
    
    if (self.selectedList == SELECTED_LIST_VENUES) {
        if ([(NSArray *)[self.venuesDataList objectAtIndex:section] count] == 0) {
            return nil;
        }
        
        if (section == 0) {
            header.titleLabel.text = @"推荐场馆";
        } else {
            header.titleLabel.text=@"所有场馆";
        }
    } else {
        if ([(NSArray *)[self.courseDataList objectAtIndex:section] count] == 0) {
            return nil;
        }
        
        if (section == 0) {
            header.titleLabel.text = @"推荐课程";
        } else {
            header.titleLabel.text=@"所有课程";
        }
    }
    
    return header;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier;
    if (self.selectedList == SELECTED_LIST_VENUES) {
        identifier = [MonthCardVenuesListCell getCellIdentifier];
    } else {
        identifier = [MonthCardCourseListCell getCellIdentifier];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

-(void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSArray *dataList;
    if (self.selectedList == SELECTED_LIST_VENUES) {
        if ([_venuesDataList count] == 0) {
            return;
        }
        
        dataList = _venuesDataList;
        
        NSArray *currentList = [dataList objectAtIndex:indexPath.section];
        cell = (MonthCardVenuesListCell *)cell;
        Business *business = [currentList objectAtIndex:indexPath.row];
        BOOL isLast = (indexPath.row == [currentList count] - 1);
        [(MonthCardVenuesListCell *)cell updateCell:business
               indexPath:indexPath
                  isLast:isLast];
    } else {
        if ([_courseDataList count] == 0) {
            return;
        }
        
        dataList = _courseDataList;
        NSArray *currentList = [dataList objectAtIndex:indexPath.section];
        cell = (MonthCardCourseListCell *)cell;
        MonthCardCourse *course = [currentList objectAtIndex:indexPath.row];
        BOOL isLast = (indexPath.row == [currentList count] - 1);
        [(MonthCardCourseListCell *)cell updateCell:course indexPath:indexPath isLast:isLast];
    }

    cell.fd_enforceFrameLayout = NO;
    return;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectedList == SELECTED_LIST_VENUES) {
        NSArray *currentList = [_venuesDataList objectAtIndex:indexPath.section];
        Business *business = [currentList objectAtIndex:indexPath.row];
        if (business.isRecommend) {
            [MobClickUtils event:umeng_event_month_click_recommend_venues_list];
        } else {
            [MobClickUtils event:umeng_event_month_click_all_venues_list];
        }
        MonthCardBusinessDetailController *controller = [[MonthCardBusinessDetailController alloc] initWithBusinessId:business.businessId categoryId:business.defaultCategoryId];
        [self.navigationController pushViewController:controller animated:YES];
    }else{
        NSArray *currentList = [_courseDataList objectAtIndex:indexPath.section];
        MonthCardCourse *course = [currentList objectAtIndex:indexPath.row];
        if (course.isRecommend) {
            [MobClickUtils event:umeng_event_month_click_recommend_course_list];
        } else {
            [MobClickUtils event:umeng_event_month_click_all_course_list];
        }
        CourseDetailController *controller = [[CourseDetailController alloc]init];
        controller.course = course;
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier;
    if (self.selectedList == SELECTED_LIST_VENUES) {
        identifier = [MonthCardVenuesListCell getCellIdentifier];
        
        return [tableView fd_heightForCellWithIdentifier:identifier configuration:^(MonthCardVenuesListCell *cell) {
            [self configureCell:cell atIndexPath:indexPath];
        }];
    } else {
        identifier = [MonthCardCourseListCell getCellIdentifier];
        return [tableView fd_heightForCellWithIdentifier:identifier configuration:^(MonthCardCourseListCell *cell) {
            [self configureCell:cell atIndexPath:indexPath];
        }];
    }
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//}

@end
