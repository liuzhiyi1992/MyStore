//
//  ActivityHistroyListController.m
//  Sport
//
//  Created by haodong  on 14-5-3.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "ActivityHistroyListController.h"
#import "SportProgressView.h"
#import "UserManager.h"
#import "ActivityDetailController.h"
#import "UIScrollView+SportRefresh.h"

@interface ActivityHistroyListController ()
@property (strong, nonatomic) NSMutableArray *dataList;
@property (strong, nonatomic) NSString *userId;
@property (assign, nonatomic) int page;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

#define COUNT_ONE_PAGE 20
#define PAGE_START     1

@implementation ActivityHistroyListController
- (void)viewDidUnload {
    [super viewDidUnload];
}

- (instancetype)initWithUserId:(NSString *)userId
{
    self = [super init];
    if (self) {
        self.userId = userId;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"活动列表";
    self.page = PAGE_START;
    [self queryData];
    [self.tableView addPullDownReloadWithTarget:self action:@selector(loadNewData)];
    [self.tableView addPullUpLoadMoreWithTarget:self action:@selector(loadMoreData)];
}

- (void)queryData
{
    [SportProgressView showWithStatus:@"正在加载..."];
    [ActivityService queryActivityList:self
                                  type:ActivityListTypeHistory
                                userId:_userId
                        activityStatus:nil
                                 proId:nil
                               actName:nil
                              latitude:0
                             longitude:0
                                  sort:nil
                                  page:_page
                                 count:COUNT_ONE_PAGE];
}

- (void)didQueryActivityList:(NSArray *)list status:(NSString *)status type:(ActivityListType)type page:(int)page
{
    [SportProgressView dismiss];
    
    if ([status isEqualToString:STATUS_SUCCESS]) {
        if (_page == PAGE_START) {
            self.dataList = [NSMutableArray arrayWithArray:list];
        } else {
            [self.dataList addObjectsFromArray:list];
        }
    }
    
    [self.tableView reloadData];
    
    if ([list count] < COUNT_ONE_PAGE) {
        [self.tableView canNotLoadMore];
    } else {
        [self.tableView canLoadMore];
    }
    [self.tableView endLoad];
    
    
    //无数据时的提示
    if ([_dataList count] == 0) {
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44);
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
- (void)loadNewData
{
    self.page = PAGE_START;
    [self queryData];
}

- (void)loadMoreData
{
    self.page ++;
    [self queryData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [ActivityCell getCellIdentifier];
    ActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [ActivityCell createCell];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        cell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
    
    Activity *activity = [_dataList objectAtIndex:indexPath.row];
    [cell updateCell:indexPath activity:activity];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ActivityCell getCellHeight];
}


- (void)didClickActivityCell:(NSIndexPath *)indexPath
{
    Activity *activity = [_dataList objectAtIndex:indexPath.row];
    ActivityDetailController *controller = [[ActivityDetailController alloc] initWithActivityId:activity.activityId];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
