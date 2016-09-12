//
//  MoneyRecordController.m
//  Sport
//
//  Created by haodong  on 15/3/22.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "MoneyRecordController.h"
#import "SportProgressView.h"
#import "UserManager.h"
#import "MoneyRecordCell.h"
#import "MoneyRecord.h"
#import "PriceUtil.h"
#import "MembershipCardRecord.h"
#import "UIScrollView+SportRefresh.h"
#import "SportPopupView.h"

@interface MoneyRecordController ()
@property (assign, nonatomic) int page;
@property (strong, nonatomic) NSMutableArray *dataList;
@property (weak, nonatomic) IBOutlet UILabel *myBalanceLabel;
@property (assign, nonatomic) float money;
@property (copy, nonatomic) NSString *cardNumber;
@property (copy, nonatomic) NSString *cardMobile;
@property (copy, nonatomic) NSString *venueId;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UITableView *dataTableView;

@property (assign, nonatomic) RecordType type;
@end

@implementation MoneyRecordController


#define PAGE_START 1
#define COUNT_ONE_PAGE 20

- (instancetype)initWithMoney:(float)money
                         type:(RecordType)type
{
    self = [super init];
    if (self) {
        self.money = money;
        self.type = type;
    }
    return self;
}

- (instancetype)initWithMoney:(float)money
                   cardNumber:(NSString *)cardNumber
                         type:(RecordType)type
                   cardMobile:(NSString *)cardMobile
                      venueId:(NSString *)venueId
{
    self = [super init];
    if (self) {
        self.money = money;
        self.cardNumber = cardNumber;
        self.type = type;
        self.cardMobile = cardMobile;
        self.venueId = venueId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.type == RecordTypeMoney) {
        self.title = @"余额记录";
        self.subTitleLabel.text = @"我的余额:";
    }
    else if(self.type == RecordTypeMembershipcard)
    {
        self.title = @"会员卡记录";
        self.subTitleLabel.text = @"会员卡余额:";
    }
    
    [self.dataTableView addPullDownReloadWithTarget:self action:@selector(loadNewData)];
    [self.dataTableView addPullUpLoadMoreWithTarget:self action:@selector(loadMoreData)];
    [self.dataTableView beginReload];
    
    self.myBalanceLabel.text = [NSString stringWithFormat:@"¥%@", [PriceUtil toValidPriceString:_money]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)queryData
{
    User *user = [[UserManager defaultManager] readCurrentUser];

    if (self.type == RecordTypeMoney) {
        
        [UserService getUserMoneyLog:self
                               userId:user.userId
                                 page:_page
                                count:COUNT_ONE_PAGE];
    } else if(self.type == RecordTypeMembershipcard) {
    
        [MembershipCardService getCardUseRecordList:self
                                         cardNumber:self.cardNumber
                                             userId:user.userId
                                               page:_page count:COUNT_ONE_PAGE
                                            venueId:self.venueId
                                       mobileNumber:self.cardMobile];

    }
}

- (void)didGetUserMoneyLog:(NSString *)status msg:(NSString *)msg recordList:(NSArray *)recordList
{
    [self.dataTableView endLoad];
    
    if ([status isEqualToString:STATUS_SUCCESS]) {
        if ([self.dataList count] == 0 || _page == PAGE_START) {
            self.dataList = [NSMutableArray arrayWithArray:recordList];
        } else {
            [self.dataList addObjectsFromArray:recordList];
        }
    } else {
        [SportPopupView popupWithMessage:msg];
    }
    
    [self.dataTableView reloadData];
    
    if ([recordList count] < COUNT_ONE_PAGE) {
        [self.dataTableView canNotLoadMore];
    } else {
        [self.dataTableView canLoadMore];
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

- (void)showNoDataViewWithType:(NoDataType)type
                         frame:(CGRect)frame
                          tips:(NSString *)tips
{
    [self.noDataView removeFromSuperview];
    self.noDataView = [NoDataView createNoDataViewWithFrame:frame
                                                       type:type
                                                       tips:tips];
    self.noDataView.delegate = self;
    [self.dataTableView addSubview:self.noDataView];
}

- (void)didGetCardUseRecordList:(NSArray *)recordList status:(NSString *)status msg:(NSString *)msg
{
    [self.dataTableView endLoad];
    
    if ([status isEqualToString:STATUS_SUCCESS]) {
        if ([self.dataList count] == 0 || _page == PAGE_START) {
            self.dataList = [NSMutableArray arrayWithArray:recordList];
        } else {
            [self.dataList addObjectsFromArray:recordList];
        }
    } else {
        [SportPopupView popupWithMessage:msg];
    }
    
    [self.dataTableView reloadData];
    
    if ([recordList count] < COUNT_ONE_PAGE) {
        [self.dataTableView canNotLoadMore];
    } else {
        [self.dataTableView canLoadMore];
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
    [self queryData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [MoneyRecordCell getCellIdentifier];
    MoneyRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [MoneyRecordCell createCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (self.type == RecordTypeMoney) {
        
        MoneyRecord *record = [_dataList objectAtIndex:indexPath.row];
        [cell updateCellWithMoneyRecord:record];
        
    }else if(self.type == RecordTypeMembershipcard) {
        MembershipCardRecord *record = [_dataList objectAtIndex:indexPath.row];
        [cell updateCellWithMembershipCard:record];
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [MoneyRecordCell getCellHeight];
}

- (void)refreshDataStart
{
    self.page = PAGE_START;
    [self queryData];
}

- (void)loadMorDataStart
{
    self.page ++;
    [self queryData];
}

@end
