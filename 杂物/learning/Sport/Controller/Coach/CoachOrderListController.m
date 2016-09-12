//
//  CoachOrderListController.m
//  Sport
//
//  Created by 江彦聪 on 15/5/19.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CoachOrderListController.h"
#import "UIScrollView+SportRefresh.h"
#import "UserManager.h"
//#import "MyCoachDetailController.h"
#import "Order.h"
//#import "TipNumberManager.h"
#import "UserService.h"
#import "UserInfoController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "SportPopUpView.h"
#import "CoachOrderDetailController.h"
#import "SportProgressView.h"

@interface CoachOrderListController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataList;
@property (strong, nonatomic) NSMutableArray *unPaidList;
@property (strong, nonatomic) NSMutableArray *readyBeginList;
@property (strong, nonatomic) NSMutableArray *onGoingList;
@property (strong, nonatomic) NSMutableArray *readyConfirmList;
@property (strong, nonatomic) NSMutableArray *finishedList;
@property (strong, nonatomic) NSMutableArray *cancelList;
@property (assign, nonatomic) int finishPage;
@property (strong, nonatomic) CoachOrderListCell* cell;
@end

@implementation CoachOrderListController

- (NSMutableArray *)dataList
{
    if (_dataList == nil) {
        _dataList = [NSMutableArray array];
    }
    
    return _dataList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"我的约练";
    //设置下拉更新
    [self.tableView addPullDownReloadWithTarget:self action:@selector(loadNewData)];
    
    //设置上拉加载更多
    [self.tableView addPullUpLoadMoreWithTarget:self action:@selector(loadMoreData)];

   self.tableView.rowHeight = UITableViewAutomaticDimension;
//   if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
//      self.tableView.estimatedRowHeight = 100.0f;
//   }
    
    self.tableView.fd_debugLogEnabled = NO;
    UINib *cellNib = [UINib nibWithNibName:[CoachOrderListCell getCellIdentifier] bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:[CoachOrderListCell getCellIdentifier]];

    [self.tableView beginReload];

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

#define COUNT_ONE_PAGE  20
#define PAGE_START      1
- (void)loadNewData
{
    self.finishPage = 0;
    [self queryData];
}

- (void)loadMoreData
{
    [self queryData];
}

- (void)queryData
{
    [SportProgressView showWithStatus:@"加载中"];
    [CoachService getCoachOrderList:self userId:[[UserManager defaultManager] readCurrentUser].userId count:COUNT_ONE_PAGE page:self.finishPage + 1];

}

- (void)didGetCoachOrderList:(NSArray *)list
                  page:(NSUInteger)page
                status:(NSString *)status
                   msg:(NSString *)msg
{
    [self.tableView endLoad];
    [self.dataList removeAllObjects];
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismiss];
        NSMutableArray *list1 = [NSMutableArray array];
        NSMutableArray *list2 = [NSMutableArray array];
        NSMutableArray *list3 = [NSMutableArray array];
        NSMutableArray *list4 = [NSMutableArray array];
        NSMutableArray *list5 = [NSMutableArray array];
        NSMutableArray *list6 = [NSMutableArray array];
        for (Order *order in list) {
            switch (order.coachStatus) {
                case CoachOrderStatusUnpaid:
                    [list1 addObject:order];
                    break;
                case CoachOrderStatusReadyCoach:
                    [list2 addObject:order];
                    break;
                case CoachOrderStatusCoaching:
                    [list3 addObject:order];
                    break;
                case CoachOrderStatusReadyConfirm:
                    [list4 addObject:order];
                    break;
                case CoachOrderStatusFinished:
                    [list5 addObject:order];
                    break;
                case CoachOrderStatusUnPaidCancelled:
                case CoachOrderStatusCancelled:
                case CoachOrderStatusExpired:
                case CoachOrderStatusRefund:
                default:
                    [list6 addObject:order];
                    break;
            }
        }
        
        if (page == PAGE_START) {
            self.unPaidList = [NSMutableArray arrayWithArray:list1];
            self.readyBeginList = [NSMutableArray arrayWithArray:list2];
            self.onGoingList = [NSMutableArray arrayWithArray:list3];
            self.readyConfirmList = [NSMutableArray arrayWithArray:list4];
            self.finishedList = [NSMutableArray arrayWithArray:list5];
            self.cancelList = [NSMutableArray arrayWithArray:list6];
        }else{
            [self.unPaidList addObjectsFromArray:list1];
            [self.readyBeginList addObjectsFromArray:list2];
            [self.onGoingList addObjectsFromArray:list3];
            [self.readyConfirmList addObjectsFromArray:list4];
            [self.finishedList addObjectsFromArray:list5];
            [self.cancelList addObjectsFromArray:list6];
        }
        
        NSArray *tempArr = [NSArray arrayWithObjects:self.unPaidList, self.readyBeginList, self.onGoingList, self.readyConfirmList, self.finishedList,self.cancelList,nil];
        for (NSArray *arr in tempArr) {
            if (arr.count > 0) {
                [self.dataList addObject:arr];
            }
        }
    
        self.finishPage = (int)page;
        
        if ([list count] < COUNT_ONE_PAGE) {
            [self.tableView canNotLoadMore];
        } else {
            [self.tableView canLoadMore];
        }
    }else {
        [SportProgressView dismissWithError:msg];
    }
    
    //无数据时的提示
    if ([self.dataList count] == 0 ||
        ([self.unPaidList count] == 0 &&
         [self.readyBeginList count] == 0 &&
         [self.onGoingList count] == 0 &&
         [self.readyConfirmList count] == 0 &&
         [self.finishedList count] == 0 &&
         [self.cancelList count] == 0)) {
            
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44);
        if ([status isEqualToString:STATUS_SUCCESS]) {
            [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"没有相关数据"];
        } else {
            [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:@"网络错误"];
        }
    } else {
        [self removeNoDataView];
    }

    [self.tableView reloadData];
}

- (void)showNoDataViewWithType:(NoDataType)type
                         frame:(CGRect)frame
                          tips:(NSString *)tips
{
    [self.noDataView removeFromSuperview];
    self.noDataView = [NoDataView createNoDataViewWithFrame:frame
                                                       type:type
                                                       tips:tips];
    self.noDataView.delegate = self;
    [self.tableView addSubview:self.noDataView];
}

- (void)didClickNoDataViewRefreshButton
{
    [self beginRefreshing];
}

#pragma mark -- tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *list = [_dataList objectAtIndex:section];
    return [list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [CoachOrderListCell getCellIdentifier];
    CoachOrderListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    cell.delegate = self;
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [MobClickUtils event:umeng_event_click_coach_order_list];
    
    NSArray *list = [_dataList objectAtIndex:indexPath.section];
    Order *order = list[indexPath.row];
    
    CoachOrderDetailController *controller = [[CoachOrderDetailController alloc]initWithOrder:order];
    [self.navigationController pushViewController:controller animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        return [tableView fd_heightForCellWithIdentifier:[CoachOrderListCell getCellIdentifier] configuration:^(CoachOrderListCell *cell) {
            [self configureCell:cell atIndexPath:indexPath];
        }];

}

-(void) configureCell:(CoachOrderListCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSArray *list = [_dataList objectAtIndex:indexPath.section];
    Order *order = list[indexPath.row];

    BOOL isLast = (indexPath.row == [self.dataList count] - 1);
    
    cell.fd_enforceFrameLayout = NO;
    [cell updateCell:order
           indexPath:indexPath
              isLast:isLast];

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
