//
//  UnableVouchersController.m
//  Sport
//
//  Created by haodong  on 15/3/21.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "UnableVouchersController.h"
#import "VoucherCell.h"
#import "UserManager.h"
#import "UIView+Utils.h"
#import "Voucher.h"
#import "UIScrollView+SportRefresh.h"
#import "TicketService.h"
#import "SportVoucherCell.h"
#import "SportPopupView.h"
#import "SportProgressView.h"

@interface UnableVouchersController ()<TicketServiceDelegate>

@property (strong, nonatomic) NSMutableArray *dataList;
@property (assign, nonatomic) NSUInteger page;
@property (assign, nonatomic) VoucherType selectedType;

@property (weak, nonatomic) IBOutlet UIButton *sportButton;
@property (weak, nonatomic) IBOutlet UIButton *defaultButton;
@property (weak, nonatomic) IBOutlet UIView *moveLiveView;
@property (weak, nonatomic) IBOutlet UITableView *dataTableView;

@end

@implementation UnableVouchersController


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define PAGE_START 1
#define COUNT_ONE_PAGE 5

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"失效卡券";
    self.sportButton.selected = YES;
    self.selectedType = VoucherTypeSport;
    self.page = PAGE_START;
    
    [self.dataTableView addPullDownReloadWithTarget:self action:@selector(loadNewData)];
    [self.dataTableView addPullUpLoadMoreWithTarget:self action:@selector(loadMoreData)];
//    [self.view  addPullDownReloadWithTarget:self action:@selector(loadNewData)];
//    [self.dataTableView addPullUpLoadMoreWithTarget:self action:@selector(loadMoreData)];
//    
    [self.dataTableView beginReload];
    
}

- (IBAction)clickSport:(id)sender {
    [MobClickUtils event:umeng_event_click_failure_tab_sport_stamps];
    
    self.sportButton.selected = YES;
    self.defaultButton.selected = NO;
    [UIView animateWithDuration:0.2 animations:^{
        [self.moveLiveView updateOriginX:0];
    }];
    
    self.selectedType = VoucherTypeSport;
    [self.dataTableView beginReload];
}

- (IBAction)clickDefaultButton:(id)sender {
    [MobClickUtils event:umeng_event_click_failure_tab_coupon];
    
    self.sportButton.selected = NO;
    self.defaultButton.selected = YES;
    [UIView animateWithDuration:0.2 animations:^{
        [self.moveLiveView updateOriginX:[UIScreen mainScreen].bounds.size.width / 2];
    }];
    
    self.selectedType = VoucherTypeDefault;
    [self.dataTableView beginReload];
}

- (void)loadNewData
{
    self.page = 0;
    [self queryData];
}

- (void)loadMoreData
{
    [self queryData];
}

- (void)queryData
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    
    if (self.selectedType == VoucherTypeDefault) {

        [TicketService expireCouponList:self
    userId:user.userId
    page:_page + 1
    count:COUNT_ONE_PAGE];

    } else if (self.selectedType == VoucherTypeSport) {
        [TicketService expireTicketList:self
                                 userId:user.userId
                                   page:_page + 1
                                  count:COUNT_ONE_PAGE];
    }
}

- (void)didExpireCouponList:(NSArray *)voucherList
                     status:(NSString *)status
                        msg:(NSString *)msg
                       page:(NSUInteger)page
{
    [self.dataTableView endLoad];
    
    if ([status isEqualToString:STATUS_SUCCESS]) {
        self.page = page;
        if (_page == PAGE_START) {
            self.dataList = [NSMutableArray arrayWithArray:voucherList];
        } else {
            [self.dataList addObjectsFromArray:voucherList];
          //  [self.dataTableView canNotLoadMore];
        }
        
        [self.dataTableView reloadData];
        if ([voucherList count] < COUNT_ONE_PAGE) {
            [self.dataTableView canNotLoadMore];
        } else {
            [self.dataTableView canLoadMore];
        }

        if (_selectedType == VoucherTypeDefault) {
            [self.dataTableView reloadData];
        }
    }else {
        self.dataList = [NSMutableArray array];
    }
    
    [self reloadTips:status msg:msg];
}

- (void)didExpireTicketList:(NSArray *)list
                     status:(NSString *)status
                        msg:(NSString *)msg
                       page:(NSUInteger)page
{
    [self.dataTableView endLoad];
    
    if ([status isEqualToString:STATUS_SUCCESS]) {
        self.page = page;
        if (_page == PAGE_START) {
            self.dataList = [NSMutableArray arrayWithArray:list];
            
        } else {
            [self.dataList addObjectsFromArray:list];
        }
        
        if ([list count] < COUNT_ONE_PAGE) {
            [self.dataTableView canNotLoadMore];
        } else {
            [self.dataTableView canLoadMore];
        }
        
        if (_selectedType == VoucherTypeSport) {
            [self.dataTableView reloadData];
        }
        
        if ([list count] < COUNT_ONE_PAGE) {
            [self.dataTableView canNotLoadMore];
        } else {
            [self.dataTableView canLoadMore];
        }
    } else {
        self.dataList = [NSMutableArray array];
   
    }
    [self reloadTips:status msg:msg];
}

//无数据时的提示
- (void)reloadTips:(NSString *)status msg:(NSString *)msg
{
    if ([_dataList count] == 0) {
        CGRect frame = CGRectMake(0, 40, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44 - 40);
        if ([status isEqualToString:STATUS_SUCCESS]) {
            //NSString *tips = (_selectedType == VoucherTypeDefault ? @"没有失效的代金券" : @"没有失效的运动券");
            
            [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"没有相关数据"];
        } else {
            [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:@"网络错误"];
            [SportPopupView popupWithMessage:msg];
        }
    } else {
        [self removeNoDataView];
    }
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
    Voucher *voucher  = [_dataList objectAtIndex:indexPath.row];
    
//    if (voucher.type == VoucherTypeSport) {
//        NSString *identifier = [SportVoucherCell getCellIdentifier];
//        SportVoucherCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//        if (cell == nil) {
//            cell = [SportVoucherCell createCell];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        }
//        [cell updateCellWithVoucher:voucher isShowUseButton:NO];
//        return cell;
//    } else {
        NSString *identifier = [VoucherCell getCellIdentifier];
        VoucherCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [VoucherCell createCell];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        //workaround for IOS 7 auto layout bug
        if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
        {
            cell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
        }
    
        [cell updateCellWithVoucher:voucher isShowUseButton:NO];
        return cell;
//   }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [VoucherCell getCellHeight];
}

@end
