//
//  AbleVouchersController.m
//  Sport
//
//  Created by qiuhaodong on 15/6/29.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "AbleVouchersController.h"
#import "TicketService.h"
#import "UserManager.h"
#import "UIScrollView+SportRefresh.h"
#import "VoucherCell.h"
#import "SportVoucherCell.h"
#import "Voucher.h"
#import "UnableVouchersController.h"
#import "SportPopupView.h"
#import "SportProgressView.h"

@interface AbleVouchersController () <TicketServiceDelegate, UITableViewDataSource, UITableViewDelegate, VoucherCellDelegate, SportVoucherCellDelegate>

@property (strong, nonatomic) NSArray *dataList;

@property (weak, nonatomic) IBOutlet UITableView *dataTableView;

@end

@implementation AbleVouchersController


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.dataTableView addPullDownReloadWithTarget:self action:@selector(loadNewData)];
    [self.dataTableView beginReload];
    
    self.title = @"我的卡券";
    [self createRightTopButton:@"失效卡券"];
}

- (void)clickRightTopButton:(id)sender
{
    [MobClickUtils event:umeng_event_click_my_ticket_failure_ticket];
    UnableVouchersController *controller = [[UnableVouchersController alloc] init] ;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)loadNewData
{
    User *user = [[UserManager defaultManager] readCurrentUser];
//    [TicketService getTicketList:self
//                          userId:user.userId
//                        goodsIds:nil
//                       orderType:nil];
    [TicketService getNewTicketList:self userId:user.userId goodsIds:nil orderType:nil entry:nil categoryId:nil cityId:nil];
}

- (void)didGetTicketList:(NSArray *)list
                  status:(NSString *)status
                     msg:(NSString *)msg
              usableDays:(NSString *)usableDays
          userClubStatus:(int)userClubStatus
{
    [SportProgressView dismiss];
    [self.dataTableView endLoad];
    if ([status isEqualToString:STATUS_SUCCESS]) {
        self.dataList = list;
        [self.dataTableView reloadData];
    } else {
        [SportPopupView popupWithMessage:msg];
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
}

- (void)didClickNoDataViewRefreshButton
{
    [SportProgressView showWithStatus:@"正在加载..."];
    [self loadNewData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Voucher *voucher  = [_dataList objectAtIndex:indexPath.row];
    
//    if (voucher.type == VoucherTypeSport) {
//        NSString *identifier = [SportVoucherCell getCellIdentifier];
//        SportVoucherCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//        if (cell == nil) {
//            cell = [SportVoucherCell createCell];
//            cell.delegate = self;
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        }
//        [cell updateCellWithVoucher:voucher isShowUseButton:NO];
//        return cell;
//    } else {
        NSString *identifier = [VoucherCell getCellIdentifier];
        VoucherCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [VoucherCell createCell];
            cell.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell updateCellWithVoucher:voucher isShowUseButton:NO];
        return cell;
    //}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Voucher *voucher  = [_dataList objectAtIndex:indexPath.row];
    if (voucher.type == VoucherTypeSport) {
        return [SportVoucherCell getCellHeight];
    } else {
        return [VoucherCell getCellHeight];
    }
}

@end
