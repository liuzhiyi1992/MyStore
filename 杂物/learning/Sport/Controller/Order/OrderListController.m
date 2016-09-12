//
//  OrderListController.m
//  Sport
//
//  Created by haodong  on 13-7-29.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "OrderListController.h"
#import "Order.h"
#import "User.h"
#import "UserManager.h"
#import "SportProgressView.h"
#import "SportPopupView.h"
#import "SportNavigationController.h"
#import "UIView+Utils.h"
#import "TipNumberManager.h"
#import "PayHelpController.h"
#import "BusinessDetailController.h"
#import "PayController.h"
#import "WriteReviewController.h"
#import "UIScrollView+SportRefresh.h"
#import "CoachWriteReviewController.h"
#import "SportUUID.h"
#import "SportOrderDetailFactory.h"
#import "CoachOrderDetailController.h"

@interface OrderListController ()<CoachServiceDelegate>
@property (strong, nonatomic) NSMutableArray *dataList;
@property (strong, nonatomic) NSIndexPath *selectedForwardIndexPath;
@property (strong, nonatomic) NSIndexPath *selectedCancelIndexPath;
@property (assign, nonatomic) int selectedOrderStatus; // 1 待开始 2待评价 0全部
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (assign, nonatomic) int finishPage;
@property (weak, nonatomic) IBOutlet UITableView *dataTableView;
@property (weak, nonatomic) IBOutlet UIView *cursorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cursorViewLeadingConstraint;

@end


@implementation OrderListController

#define PAGE_START 1
#define COUNT_ONE_PAGE 20

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateCursorLocation];
    [self.dataTableView reloadData];
    [self queryNotPayCount];
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [self.view setFrame:CGRectMake(0, 0, keyWindow.frame.size.width, keyWindow.frame.size.height)];
    
    self.tableViewHeightConstraint.constant = keyWindow.frame.size.height - self.headerViewHeightConstraint.constant - self.navigationController.navigationBar.frame.size.height;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateCursorLocation];
}

- (instancetype)initWithOpenIndex:(int)index {
    self = [self init];
    if (self) {
        self.selectedOrderStatus = index;
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.selectedOrderStatus  = 0;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateMessageCount)
                                                     name:NOTIFICATION_NAME_CHANGE_TIPS_COUNT
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(finishWriteReview:)
                                                     name:NOTIFICATION_NAME_FINISH_WRITE_REVIEW
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(finishPayOrder:)
                                                     name:NOTIFICATION_NAME_FINISH_PAY_ORDER
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(finishCoachOrder:)
                                                     name:NOTIFICATION_NAME_FINISH_COACH_ORDER
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cancelCoachOrder:)
                                                     name:NOTIFICATION_NAME_CANCEL_COACH_ORDER
                                                   object:nil];

    }
    return self;
}

- (void)setSelectedOrderStatus:(int)selectedOrderStatus {
    _selectedOrderStatus = selectedOrderStatus;
    [self updateCursorLocation];
}

- (void)finishPayOrder:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *orderId = [notification.userInfo objectForKey:@"order_id"];
        for (Order *order in _dataList) {
            if ([orderId isEqualToString:order.orderId]) {
                order.status = OrderStatusPaid;
            }
        }
        [self.dataTableView reloadData];
        [self loadNewData];
    });
}


- (void)finishWriteReview:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *orderId = [notification.userInfo objectForKey:@"order_id"];
        for (Order *order in _dataList) {
            if ([orderId isEqualToString:order.orderId]) {
                order.commentStatus = CommentStatusAlreadyComment;
            }
        }
        [self.dataTableView reloadData];
        [self loadNewData];
    });
}

-(void)finishCoachOrder:(NSNotification *)notification {
    NSString *orderId = [notification.userInfo objectForKey:@"order_id"];
    for (Order *order in _dataList) {
        if ([orderId isEqualToString:order.orderId]) {
            order.coachStatus = CoachOrderStatusFinished;
            order.status = OrderStatusUsed;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.dataTableView reloadData];
        [self loadNewData];
    });
}

-(void)cancelCoachOrder:(NSNotification *)notification {
    NSString *orderId = [notification.userInfo objectForKey:@"order_id"];
    for (Order *order in _dataList) {
        if ([orderId isEqualToString:order.orderId]) {
            order.coachStatus = CoachOrderStatusCancelled;
            order.status = OrderStatusCancelled;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.dataTableView reloadData];
        [self loadNewData];
    });
}

- (void)updateMessageCount
{
    NSUInteger needPayCount = [[TipNumberManager defaultManager] needPayOrderCount];
    NSUInteger canCommentCount = [[TipNumberManager defaultManager] canCommentCount];
    NSUInteger readyBeginCount = [[TipNumberManager defaultManager] readyBeginCount];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (needPayCount > 0) {
            self.unpaidTipsButton.hidden = NO;
            [self.unpaidTipsButton setTitle:[@(needPayCount) stringValue] forState:UIControlStateNormal];
        } else {
            self.unpaidTipsButton.hidden = YES;
        }
        
        if (readyBeginCount > 0) {
            [self.firstFilterButton setTitle:[NSString stringWithFormat:@"待开始(%d)",(int)readyBeginCount] forState:UIControlStateNormal];
        } else {
            [self.firstFilterButton setTitle:@"待开始" forState:UIControlStateNormal];
        }
        
        if (canCommentCount > 0) {
            [self.secondFilterButton setTitle:[NSString stringWithFormat:@"未评价(%d)",(int)canCommentCount] forState:UIControlStateNormal];
        } else {
            [self.secondFilterButton setTitle:@"未评价" forState:UIControlStateNormal];
        }
    });
}

#define HEIGHT_FILTER_VIEW 45
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = DDTF(@"kMyOrder");
    self.dataTableView.backgroundColor = [UIColor clearColor];
    
    [self initButtons];
    
    [self updateMessageCount];

    //[SportProgressView showWithStatus:DDTF(@"刷新中...")];
    
//    NSUInteger count = [[TipNumberManager defaultManager] needPayOrderCount];
//    if (count > 0) {
//        self.thirdFilterButton.selected = YES;
//        self.selectedOrderStatus = 0;
//    } else {
//        self.secondFilterButton.selected = YES;
//        self.selectedOrderStatus = 2;
//    }

//    [self updateSelectionTab];
    
    [self.dataTableView addPullDownReloadWithTarget:self action:@selector(loadNewData)];
    [self.dataTableView addPullUpLoadMoreWithTarget:self action:@selector(loadMoreData)];
    [self.dataTableView beginReload];
    
    [self createRightTopButton:@"帮助"];
}

//todo 弃用
- (void)initButtons
{
//    [self.firstFilterButton setTitleColor:[UIColor hexColor:@"222222"] forState:UIControlStateNormal];
//    [self.firstFilterButton setBackgroundImage:[SportImage blueFrameButtonLeftImage] forState:UIControlStateNormal];
//    [self.firstFilterButton setBackgroundImage:[SportImage blueButtonLeftImage] forState:UIControlStateSelected];
    
//    [self.secondFilterButton setTitleColor:[UIColor hexColor:@"222222"] forState:UIControlStateNormal];
//    [self.secondFilterButton setBackgroundImage:[SportImage blueFrameButtonMiddleImage] forState:UIControlStateNormal];
//    [self.secondFilterButton setBackgroundImage:[SportImage blueButtonMiddleImage] forState:UIControlStateSelected];
    
//    [self.thirdFilterButton setTitleColor:[UIColor hexColor:@"222222"] forState:UIControlStateNormal];
//    [self.thirdFilterButton setBackgroundImage:[SportImage blueFrameButtonRightImage] forState:UIControlStateNormal];
//    [self.thirdFilterButton setBackgroundImage:[SportImage blueButtonRightImage] forState:UIControlStateSelected];
}

- (void)clickRightTopButton:(id)sender
{
    PayHelpController *controller = [[PayHelpController alloc] init] ;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)clickFirstFilterButton:(id)sender {
    _firstFilterButton.selected = YES;
    _secondFilterButton.selected = NO;
    _thirdFilterButton.selected = NO;
    
    [SportProgressView showWithStatus:DDTF(@"刷新中...")];
    self.selectedOrderStatus = 1;
    [self loadNewData];
}

- (IBAction)clickSecondFilterButton:(id)sender {
    _firstFilterButton.selected = NO;
    _secondFilterButton.selected = YES;
    _thirdFilterButton.selected = NO;
    
    [SportProgressView showWithStatus:DDTF(@"刷新中...")];
    self.selectedOrderStatus = 2;
    
    [self loadNewData];
}

- (IBAction)clickThirdFilterButton:(id)sender {
    [MobClickUtils event:umeng_event_order_list_click_cancell_status];

    _firstFilterButton.selected = NO;
    _secondFilterButton.selected = NO;
    _thirdFilterButton.selected = YES;
    
    [SportProgressView showWithStatus:DDTF(@"刷新中...")];
    self.selectedOrderStatus = 0;
    [self loadNewData];
}

- (void)updateCursorLocation {
    UIButton *relevenceButton = nil;
    switch (_selectedOrderStatus) {
        case 0:
            relevenceButton = _thirdFilterButton;
            break;
        case 1:
            relevenceButton = _firstFilterButton;
            break;
        case 2:
            relevenceButton = _secondFilterButton;
            break;
        default:
            break;
    }
    if (nil == relevenceButton) {
        return;
    }
    relevenceButton.selected = YES;
    _cursorViewLeadingConstraint.constant = CGRectGetMidX(relevenceButton.frame) - 0.5 * _cursorView.frame.size.width;
    [UIView animateWithDuration:0.2 animations:^{
        [_cursorView updateCenterX:relevenceButton.center.x];
    }];
}

- (void)queryNotPayCount
{
//    User *user = [[UserManager defaultManager] readCurrentUser];
//    [[OrderService defaultService] queryNeedPayOrderCount:nil userId:user.userId];
    
    [self getMessageCount];
}

- (void)queryData
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    [OrderService queryNewUIOrderList:self
                               userId:user.userId
                          orderStatus:_selectedOrderStatus
                                 page:_finishPage + 1
                                count:COUNT_ONE_PAGE];
}

- (void)didQueryOrderList:(NSString *)status
                      msg:(NSString *)msg
                orderList:(NSArray *)orderList
                     page:(int)page
              orderStatus:(int)orderStatus
{
    [self.dataTableView endLoad];
    
    BOOL isNewPage = NO;
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismiss];

        
        if (_selectedOrderStatus == orderStatus) {
            
            self.finishPage = page;

//            [self updateSelectionTab];
            if ([self.dataList count] == 0 || page == PAGE_START) {
                self.dataList = [NSMutableArray arrayWithArray:orderList];
                isNewPage = YES;
            } else {
                [self.dataList addObjectsFromArray:orderList];
            }
        }
    } else {
        [SportProgressView dismissWithError:msg];
    }
    
    [self.dataTableView reloadData];
    
    if (isNewPage) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.dataTableView setContentOffset:CGPointZero animated:YES];
        });
    }
    
    //加载更多，或下来刷新的处理
    if ([orderList count] < COUNT_ONE_PAGE) {
        [self.dataTableView canNotLoadMore];
    } else {
        [self.dataTableView canLoadMore];
    }

    //无数据时的提示
    if ([_dataList count] == 0) {
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44);
        if ([status isEqualToString:STATUS_SUCCESS]) {
            [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"您还没有相关订单"];
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

- (void)didClickNoDataViewRefreshButton {
    [self queryData];
}

- (void)loadNewData {
    self.finishPage = 0;
    [self queryData];
    
    [self queryNotPayCount];
}

- (void)loadMoreData {
    [self queryData];
}

- (void)didCancelOrder:(NSString *)status orderId:(NSString *)orderId
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismissWithSuccess:@"取消成功"];
        
        for (Order *order in self.dataList) {
            if ([order.orderId isEqualToString:orderId]) {
                order.status = OrderStatusCancelled;
                break;
            }
        }
        [self.dataTableView reloadData];
    } else {
        [SportProgressView dismissWithError:@"取消失败"];
    }
    
    [self loadNewData];
}

#pragma mark -UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Order *order = [_dataList objectAtIndex:indexPath.row];

    NSString *identifier = [OrderSimpleCell getCellIdentifier];
    OrderSimpleCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [OrderSimpleCell createCell];
        cell.delegate = self;
    }
    
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        cell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
    
    [cell updateCellWithOrder:order indexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Order *order = [_dataList objectAtIndex:indexPath.row];
    return [OrderSimpleCell getCellHeightWithOrder:order];
}

- (void)didClickOrderSimpleCellButton:(NSIndexPath *)indexPath
{
    Order *order = [_dataList objectAtIndex:indexPath.row];
    UIViewController *orderDetailController = [SportOrderDetailFactory orderDetailControllerWithOrder:order];
    if (nil != orderDetailController) {
        [self.navigationController pushViewController:orderDetailController animated:YES];
    }
}

#define TAG_CANCEL_ALERTVIEW  2013091101
- (void)didClickOrderSimpleCellCancelButton:(NSIndexPath *)indexPath
{
    self.selectedCancelIndexPath = indexPath;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"是否要取消订单"
                                                       delegate:self
                                              cancelButtonTitle:@"否"
                                              otherButtonTitles:@"是", nil];
    alertView.tag = TAG_CANCEL_ALERTVIEW;
    [alertView show];
}

- (void)didClickOrderSimpleCellPayButton:(NSIndexPath *)indexPath
{
    Order *order = [_dataList objectAtIndex:indexPath.row];    
    PayController *controller = [[PayController alloc] initWithOrder:order];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didClickOrderSimpleCellWriteReviewButton:(NSIndexPath *)indexPath
{
    Order *order = [_dataList objectAtIndex:indexPath.row];
    if (order.type == OrderTypeCoach) {
        CoachWriteReviewController *controller = [[CoachWriteReviewController alloc] initWithBusinessId:order.coachId businessName:@"评价" orderId:order.orderId];
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        WriteReviewController *controller = [[WriteReviewController alloc] initWithBusinessId:order.businessId businessName:order.businessName orderId:order.orderId] ;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)didClickOrderSimpleCellWebDetailButtonButton:(NSIndexPath *)indexPath
{
    Order *order = [_dataList objectAtIndex:indexPath.row];
    
    SportWebController *controller = [[SportWebController alloc] initWithUrlString:order.detailUrl title:@"图文详情"] ;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didClickOrderSimpleCellCoachActionButton:(NSIndexPath *)indexPath
{
    Order *order = [_dataList objectAtIndex:indexPath.row];
    switch (order.coachStatus) {
        case CoachOrderStatusReadyCoach:
            
            //待陪练，一天前可取消，当天不可取消
            if(order.isCoachCanCancel) {
                //取消预约
                CoachOrderDetailController *controller = [[CoachOrderDetailController alloc] initWithOrder:order];
                
                [self.navigationController pushViewController:controller animated:YES];
                
                break;
            }
        case CoachOrderStatusCoaching:
        case CoachOrderStatusReadyConfirm:
            self.selectedForwardIndexPath = indexPath;
            [self doConfirmOrder];
            //确认
            break;
        case CoachOrderStatusUnPaidCancelled:
        case CoachOrderStatusCancelled:
        case CoachOrderStatusExpired:
        case CoachOrderStatusRefund:
        case CoachOrderStatusFinished:
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_CANCEL_ALERTVIEW) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            return;
        } else {
            Order *order = [_dataList objectAtIndex:_selectedCancelIndexPath.row];
            User *user = [[UserManager defaultManager] readCurrentUser];
            [SportProgressView showWithStatus:@"正在取消订单..." hasMask:YES];
            [OrderService cancelOrder:self
                                order:order
                               userId:user.userId];
        }
    }
}

#define TAG_CONFIRM 0x0001
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_CONFIRM) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [SportProgressView showWithStatus:@"确认中"];
            Order *order = [_dataList objectAtIndex:_selectedForwardIndexPath.row];
            [CoachService confirmService:self userId:[[UserManager defaultManager] readCurrentUser].userId orderId:order.orderId];
        }
    }
}

-(void)doConfirmOrder
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"是否确认？" message:@"(确认后约练费用将会打到对方的账户)" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = TAG_CONFIRM;
    [alert show];
}

-(void)didConfirmService:(NSString *)status msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismiss];
        [self queryNotPayCount];
    }else {
        [SportProgressView dismissWithError:msg];
    }
}
-(void)popupCancelReasonView
{
    
}

//弃用
-(void)updateSelectionTab {
    self.firstFilterButton.selected = NO;
    self.secondFilterButton.selected = NO;
    self.thirdFilterButton.selected = NO;
    switch (self.selectedOrderStatus) {
        case 0:
        {
            self.thirdFilterButton.selected = YES;
            _cursorViewLeadingConstraint.constant = CGRectGetMidX(_thirdFilterButton.frame) - 0.5 * _cursorView.frame.size.width;
            [UIView animateWithDuration:0.2 animations:^{
                [_cursorView updateCenterX:_thirdFilterButton.center.x];
            }];
        }
            break;
        case 1:
        {
            self.firstFilterButton.selected = YES;
            _cursorViewLeadingConstraint.constant = CGRectGetMidX(_firstFilterButton.frame) - 0.5 * _cursorView.frame.size.width;
            [UIView animateWithDuration:0.2 animations:^{
                [_cursorView updateCenterX:_firstFilterButton.center.x];
            }];
        }
            break;
        case 2:
        {
            self.secondFilterButton.selected = YES;
            _cursorViewLeadingConstraint.constant = CGRectGetMidX(_secondFilterButton.frame) - 0.5 * _cursorView.frame.size.width;
            [UIView animateWithDuration:0.2 animations:^{
                [_cursorView updateCenterX:_secondFilterButton.center.x];
            }];
        }
            break;
    }

}

- (void)getMessageCount
{
    [UserService getMessageCountList:nil
                              userId:[[UserManager defaultManager] readCurrentUser].userId
                            deviceId:[SportUUID uuid]];
}


@end
