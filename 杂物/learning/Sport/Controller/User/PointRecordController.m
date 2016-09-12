//
//  PointRecordController.m
//  Sport
//
//  Created by haodong  on 14/11/17.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "PointRecordController.h"
#import "PointRecordCell.h"
#import "User.h"
#import "UserManager.h"
#import "UIView+Utils.h"
#import "PointRecord.h"
#import "SportProgressView.h"
#import "UIScrollView+SportRefresh.h"

@interface PointRecordController ()
@property (strong, nonatomic) NSMutableArray *dataList;
@property (assign, nonatomic) int page;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PointRecordController

#define PAGE_START 1
#define COUNT_ONE_PAGE 20


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"积分记录";
    
    [self.lineImageView setImage:[SportImage lineImage]];
    [self.tableView updateHeight:[UIScreen mainScreen].bounds.size.height - 20 - 44 - 40];
    
    User *user = [[UserManager defaultManager] readCurrentUser];
    
    self.pointLabel.text = [NSString stringWithFormat:@"%d", user.point];
    
    self.page = PAGE_START;
    [self queryData];
    [self.tableView addPullDownReloadWithTarget:self action:@selector(loadNewData)];
    [self.tableView addPullUpLoadMoreWithTarget:self action:@selector(loadMoreData)];
}

- (void)queryData
{
    [SportProgressView showWithStatus:@"加载中"];
    
    User *user = [[UserManager defaultManager] readCurrentUser];
    [PointService queryPointRecordList:self
                                userId:user.userId
                                  page:_page
                                 count:COUNT_ONE_PAGE];
}

- (void)didQueryPointRecordList:(NSArray *)list status:(NSString *)status msg:(NSString *)msg
{
    [SportProgressView dismiss];
    if ([status isEqualToString:STATUS_SUCCESS]) {
        if ([self.dataList count] == 0 || _page == PAGE_START) {
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
    
    //无数据时的提示
    if ([self.dataList count] == 0) {
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44);
        if ([status isEqualToString:STATUS_SUCCESS]) {
            [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"没有相关数据"];
        } else {
            [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:@"网络错误"];
        }
    } else {
        [self removeNoDataView];
    }

    [self.tableView endLoad];
}

- (void)didClickNoDataViewRefreshButton
{
    [self queryData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [PointRecordCell getCellIdentifier];
    PointRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [PointRecordCell createCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        cell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
    
    PointRecord *record = [_dataList objectAtIndex:indexPath.row];
    
    [cell updateCellWithPointRecord:record];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [PointRecordCell getCellHeight];
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

@end
