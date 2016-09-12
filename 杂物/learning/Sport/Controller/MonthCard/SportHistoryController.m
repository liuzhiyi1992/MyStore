//
//  SportHistoryController.m
//  Sport
//
//  Created by haodong  on 15/6/10.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportHistoryController.h"
#import "SportHistoryVenueCell.h"
#import "SportHistoryCourseCell.h"
#import "Business.h"
#import "MonthCardCourse.h"
#import "UIScrollView+SportRefresh.h"
#import "BaseService.h"
#import "SportPopupView.h"
#import "UserManager.h"
#import "MonthCard.h"
#import "MonthCardRechargeController.h"
#import "MonthCardBusinessDetailController.h"
#import "CourseDetailController.h"
#import "DateUtil.h"
#import "SportProgressView.h"

#define COUNT_ONE_PAGE  10
#define PAGE_START      1

typedef enum {
    HistoryTypeVenue = 0,
    HistoryTypeCourse = 1,
} HistoryType;

@interface SportHistoryController ()<UITableViewDelegate>

@property (strong, nonatomic) MonthCard *monthCard;
@property (strong, nonatomic) NSMutableArray *venuesDataList;
@property (strong, nonatomic) NSMutableArray *courseDataList;
@property (strong, nonatomic) UIView *moveLineView;
@property (assign, nonatomic) HistoryType historyType;
@property (assign, nonatomic) int venuesFinishPage;
@property (assign, nonatomic) int courseFinishPage;
@property (weak, nonatomic) IBOutlet UITableView *dataTableView;
@property (weak, nonatomic) IBOutlet UIView *buttonSuperView;
@property (weak, nonatomic) IBOutlet UIButton *venueButton;
@property (weak, nonatomic) IBOutlet UIButton *courseButton;

@end

@implementation SportHistoryController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initMoveLine];
    //设置下拉更新
    [self.dataTableView addPullDownReloadWithTarget:self action:@selector(loadNewData)];
    //设置上拉加载更多
    [self.dataTableView addPullUpLoadMoreWithTarget:self action:@selector(loadMoreData)];
    [self.dataTableView beginReload];
    UINib *cellNib = [UINib nibWithNibName:[SportHistoryVenueCell getCellIdentifier] bundle:nil];
    [self.dataTableView registerNib:cellNib forCellReuseIdentifier:[SportHistoryVenueCell getCellIdentifier]];
    cellNib = [UINib nibWithNibName:[SportHistoryCourseCell getCellIdentifier] bundle:nil];
    [self.dataTableView registerNib:cellNib forCellReuseIdentifier:[SportHistoryCourseCell getCellIdentifier]];
    self.dataTableView.tableFooterView = [[UIView alloc] init];
    self.dataTableView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
    self.title = @"运动记录";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.monthCard = [[UserManager defaultManager] readCurrentUser].monthCard;
 //   NSDate *today = [NSDate date];
//    int timediff = [_monthCard.endTime timeIntervalSince1970] - [today timeIntervalSince1970];
//    int numDay = timediff/(24*3600);
    int numDay = [DateUtil expiredaysFromNow:_monthCard.endTime];
    if (numDay > 0) {
        [self createRightTopButton:[NSString stringWithFormat:@"还剩%d天",numDay]];
    } else {
        [self createRightTopButton:@"加入动Club"];
    }
}

- (void)clickRightTopButton:(id)sender
{
    [MobClickUtils event:umeng_event_month_sports_record_click_left_time];
    
    MonthCardRechargeController *controller = [[MonthCardRechargeController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)clickedVenueButton:(UIButton *)sender {
    [MobClickUtils event:umeng_event_month_sports_record_click_tab_business];
    
    self.historyType = HistoryTypeVenue;
    self.venueButton.selected = YES;
    self.courseButton.selected = NO;
    [UIView animateWithDuration:0.15 animations:^{
        CGPoint center = self.moveLineView.center;
        center.x = sender.center.x;
        self.moveLineView.center = center;
    }];
    [self.dataTableView reloadData];
    [self removeNoDataView];
    if ([self.venuesDataList count] == 0) {
        [self queryData];
    }
}

- (IBAction)clickedCourseButton:(UIButton *)sender {
    [MobClickUtils event:umeng_event_month_sports_record_click_tab_course];
    
    self.historyType = HistoryTypeCourse;
    self.venueButton.selected = NO;
    self.courseButton.selected = YES;
    [UIView animateWithDuration:0.15 animations:^{
        CGPoint center = self.moveLineView.center;
        center.x = sender.center.x;
        self.moveLineView.center = center;
    }];
    [self.dataTableView reloadData];
    [self removeNoDataView];
    if ([self.courseDataList count] == 0) {
        [self queryData];
    }
}

-(void)initMoveLine{
    self.venuesDataList = [NSMutableArray array];
    self.courseDataList = [NSMutableArray array];
    self.venueButton.selected = YES;
    self.courseButton.selected = NO;
    self.moveLineView = [[UIView alloc]initWithFrame:CGRectMake(0, self.buttonSuperView.frame.size.height-2,[UIScreen mainScreen].bounds.size.width/2, 2)] ;
    self.moveLineView.backgroundColor = [UIColor colorWithRed:116.0/255.0 green:175/255.0 blue:251/255.0 alpha:1];
    [self.buttonSuperView addSubview:self.moveLineView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//刷新数据
- (void)beginRefreshing
{
    [self.dataTableView beginReload];
}

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
    [SportProgressView showWithStatus:@"加载中"];
    NSString *userId = [[UserManager defaultManager] readCurrentUser].userId;
    
    if (self.historyType == HistoryTypeVenue) {
        [MonthCardService sportRecordVenues:self userId:userId page:self.venuesFinishPage+1 count:COUNT_ONE_PAGE];
    }else {
        [MonthCardService sportRecordCourse:self userId:userId page:self.courseFinishPage+1 count:COUNT_ONE_PAGE];
    }
}

#pragma mark - 运动记录
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.historyType == HistoryTypeVenue) {
        return [self.venuesDataList count];
    } else {
        return [self.courseDataList count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.historyType == HistoryTypeVenue) {
        NSString *identifier = [SportHistoryVenueCell getCellIdentifier];
        SportHistoryVenueCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [SportHistoryVenueCell createCell];
        }
        
        //workaround for IOS 7 auto layout bug
        if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
        {
            cell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
        }
        
        Business *business = self.venuesDataList[indexPath.row];
        [cell updateCellWithBusiness:business indexPath:indexPath];
        
        return cell;
    } else {
        NSString *identifier = [SportHistoryCourseCell getCellIdentifier];
        SportHistoryCourseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [SportHistoryCourseCell createCell];
        }
        
        //workaround for IOS 7 auto layout bug
        if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
        {
            cell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
        }
        
        MonthCardCourse *course = self.courseDataList[indexPath.row];
        [cell updateCellWithCourse:course indexPath:indexPath];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.historyType == HistoryTypeVenue) {
        return [SportHistoryVenueCell getCellHeight];
    } else {
        return [SportHistoryCourseCell getCellHeight];
    }
}
- (void)didGetRcordVenueList:(NSArray *)venus page:(NSUInteger)page status:(NSString *)status msg:(NSString *)msg
{
    [self.dataTableView endLoad];
    
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismiss];
        NSMutableArray *venueList = [NSMutableArray array];
        for (Business *business in venus) {
                [venueList addObject:business];
        }
        
        if (page == PAGE_START) {
            self.venuesDataList = venueList;
        } else {
            [self.venuesDataList addObjectsFromArray:venueList];
        }
            self.venuesFinishPage ++;
        
        if ([venus count] < COUNT_ONE_PAGE) {
            [self.dataTableView canNotLoadMore];
        } else {
            [self.dataTableView canLoadMore];
        }
    } else {
        [SportProgressView dismissWithError:msg];
    }
    
    [self.dataTableView reloadData];
    if (self.venuesDataList.count == 0) {
        CGRect frame = CGRectMake(0,43, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44 - 43);
        if ([status isEqualToString:STATUS_SUCCESS]) {
            [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"没有相关数据"];
        } else {
            [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:@"网络错误"];
        }
    } else {
        [self removeNoDataView];
    }
}

- (void)didClickNoDataViewRefreshButton
{
    [self queryData];
}

- (void)didGetRcordCourseList:(NSArray *)courses page:(NSUInteger)page status:(NSString *)status msg:(NSString *)msg
{
    [self.dataTableView endLoad];
    
    if ([status isEqualToString:STATUS_SUCCESS]) {
        
        NSMutableArray *courseList = [NSMutableArray array];
        for (MonthCardCourse *course in courses) {
            [courseList addObject:course];
        }
        
        if (page == PAGE_START) {
            self.courseDataList = courseList;
        } else {
            [self.courseDataList addObjectsFromArray:courseList];

        }
        self.courseFinishPage ++;
        if ([courses count] < COUNT_ONE_PAGE) {
            [self.dataTableView canNotLoadMore];
        } else {
            [self.dataTableView canLoadMore];
        }
    }else {
        [SportPopupView popupWithMessage:msg];
       
    }
    
    [self.dataTableView reloadData];
    if (self.courseDataList.count == 0) {
        CGRect frame = CGRectMake(0, 43, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44 - 43);
        if ([status isEqualToString:STATUS_SUCCESS]) {
            [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"没有相关数据"];
        } else {
            [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:@"网络错误"];
        }
    } else {
        [self removeNoDataView];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.historyType == HistoryTypeVenue) {
        [MobClickUtils event:umeng_event_month_sports_record_click_business];
        
        Business *business = [_venuesDataList objectAtIndex:indexPath.row];
        MonthCardBusinessDetailController *controller = [[MonthCardBusinessDetailController alloc] initWithBusinessId:business.businessId categoryId:business.defaultCategoryId] ;
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        [MobClickUtils event:umeng_event_month_sports_record_click_course];
        
        MonthCardCourse *course = [_courseDataList objectAtIndex:indexPath.row];
        CourseDetailController *controller = [[CourseDetailController alloc] init];
        controller.course = course;
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

@end
