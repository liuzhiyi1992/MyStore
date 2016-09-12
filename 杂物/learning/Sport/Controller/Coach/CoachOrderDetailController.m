//
//  CoachOrderDetailController.m
//  Sport
//
//  Created by 江彦聪 on 15/7/15.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CoachOrderDetailController.h"
#import "UIScrollView+SportRefresh.h"
#import "Order.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "SportPopUpView.h"
#import "CoachDetailCell.h"
#import "DateUtil.h"
#import "PriceUtil.h"
#import "CoachHeaderView.h"
#import "UIUtils.h"
#import "CoachWriteReviewController.h"
#import "CoachOrderController.h"
#import "SportProgressView.h"
#import "CoachCancelReasonView.h"
#import "UserManager.h"
#import "CoachIntroductionController.h"
#import "CoachFeedbackController.h"
#import "PayController.h"
#import "UIView+Utils.h"

@interface CoachOrderDetailController ()<CoachHeaderViewDelegate, CoachCancelReasonViewDelegate>
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *secondViewLineViewConstraintHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lastViewLineViewConstraintHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *secondViewLineImageConstraintHeight;

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderStatusLabel;
@property (strong, nonatomic) Order *order;
@property (weak, nonatomic) IBOutlet UITableView *contentTableView;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSArray *dataList;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *secondView;
@property (strong, nonatomic) CoachHeaderView *headerView;
@property (strong, nonatomic) CoachCancelReasonView *cancelView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@end

#define TITLE_ORDER_SN          @"订单号"
#define TITLE_CATEGORY          @"约练项目"
#define TITLE_TIME              @"时间"
#define TITLE_ADDRESS           @"约练地址"
#define TITLE_PRICE             @"支付金额"

@implementation CoachOrderDetailController

-(id)initWithOrder:(Order *)order
{
    self = [super init];
    if (self) {
        self.order = order;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"约练详情";

    //设置下拉更新
    [self.scrollView addPullDownReloadWithTarget:self action:@selector(loadNewData)];

    self.contentTableView.rowHeight = UITableViewAutomaticDimension;
    //   if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
    //      self.tableView.estimatedRowHeight = 100.0f;
    //   }
    
    self.contentTableView.fd_debugLogEnabled = NO;
    UINib *cellNib = [UINib nibWithNibName:[CoachDetailCell getCellIdentifier] bundle:nil];
    [self.contentTableView registerNib:cellNib forCellReuseIdentifier:[CoachDetailCell getCellIdentifier]];

    [self initHeaderView];

    self.dataList = [NSArray arrayWithObjects:TITLE_ORDER_SN,TITLE_CATEGORY,TITLE_TIME,TITLE_ADDRESS,TITLE_PRICE ,nil];
    
    //由于订单列表和订单详情的信息is_can_cancel不相同，待收到最新网络数据再显示
    self.confirmButton.hidden = YES;
    
    //如果传orderId过来，信息不够不能更新UI
    //[self updateUI];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self queryData];
}


-(void)clickRightTopButton:(id)sender
{
    if (self.order.complainedStatus == ComplainStatusAlreadyComplained) {
        [SportPopupView popupWithMessage:@"已经投诉过了，感谢您的宝贵意见！"];
        return;
    }
    
    [MobClickUtils event:umeng_event_click_coach_order_complanit];
    
    CoachFeedbackController *controller = [[CoachFeedbackController alloc]initWithOrderId:self.order.orderId coachId:self.order.coachId coachName:self.order.coachName];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initHeaderView
{
    self.headerView = [CoachHeaderView createViewWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, _headerHeightConstraint.constant)];
    [self.headerView showWithSuperView:self.scrollView secondView:self.secondView];
    
    self.headerView.delegate = self;
}

-(void)didClickButton
{
    [MobClickUtils event:umeng_event_click_coach_order_introduce];
    [self pushCoachIntroductionController];
}

-(void)pushCoachIntroductionController {
    CoachIntroductionController *controller = [[CoachIntroductionController alloc]initWithCoachId:self.order.coachId];
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)updateUI
{
    switch (self.order.complainedStatus) {
        case ComplainStatusAlreadyComplained:
            [self createRightTopButton:@"已投诉"];
            self.navigationItem.rightBarButtonItem.enabled = NO;
            break;
        case ComplainStatusValid:
            [self createRightTopButton:@"投诉"];
            self.navigationItem.rightBarButtonItem.enabled = YES;
        default:
            break;
    }

    self.secondViewLineViewConstraintHeight.constant = 0.5;
    self.secondViewLineImageConstraintHeight.constant = 0.5;
    self.lastViewLineViewConstraintHeight.constant = 0.5;
    
    [self.headerView updateWithOrder:self.order];
    self.phoneLabel.text = self.order.coachPhone;
    self.orderStatusLabel.text = self.order.coachOrderStatusText;
    self.orderStatusLabel.textColor = self.order.coachOrderStatusTextColor;

    [self.contentTableView reloadData];
    [self updateBottomButtonStatus];
    
    self.tableViewHeightConstraint.constant = [self height];
}

- (void)loadNewData
{
    [self queryData];
}

- (void)queryData
{
    [SportProgressView showWithStatus:@"加载中"];
//    [[CoachService defaultService] getCoachOrderInfo:self orderId:self.order.orderId];
    [CoachService getCoachOrderInfo:self orderId:self.order.orderId];
}

-(void)didGetCoachOrderInfo:(Order *)order status:(NSString *)status msg:(NSString *)msg
{
    [self.scrollView endLoad];
    [SportProgressView dismiss];
    
    if ([status isEqualToString:STATUS_SUCCESS]) {
        self.order = order;
        [self updateUI];
        self.confirmButton.hidden = NO;
    }else {
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

-(void)didClickNoDataViewRefreshButton
{
    [self queryData];
}

#define IMAGE_ORANGE [SportImage orangeButtonImage]
#define IMAGE_CANCEL [SportImage coachCancelButtonImage]
#define CANCEL_COLOR [SportColor defaultColor]
#define CONFIRM_SERVICE_AND_COMMENT @"确认并评价"
#define CONFIRM_SERVICE @"请确认服务"
#define REORDER @"重新预约"
#define ORDER_AGAIN @"再次预约"
#define WAIT_FOR_COMMENT  @"评价"
- (void)updateBottomButtonStatus
{
    NSString *title = nil;
    UIImage *buttonImage = IMAGE_ORANGE;
    UIColor *color = [UIColor whiteColor];
    
    switch (self.order.coachStatus) {
        case CoachOrderStatusUnpaid:
            title = @"马上支付";
            break;
        case CoachOrderStatusReadyCoach:
            //待陪练，一天前可取消，当天不可取消
            if(self.order.isCoachCanCancel) {
                title = @"取消预约";
                buttonImage = IMAGE_CANCEL;
                color = CANCEL_COLOR;
                break;
            }
        case CoachOrderStatusCoaching:
        case CoachOrderStatusReadyConfirm:
            title = CONFIRM_SERVICE_AND_COMMENT;
            break;
        case CoachOrderStatusFinished:
            switch(self.order.commentStatus) {
                case CommentStatusValid:
                    title = WAIT_FOR_COMMENT;
                    break;
                case CommentStatusInvalid:
                case CommentStatusAlreadyComment:
                default:
                    title = ORDER_AGAIN;
                    break;
            }
            
            break;
        case CoachOrderStatusUnPaidCancelled:
        case CoachOrderStatusCancelled:
        case CoachOrderStatusExpired:
        case CoachOrderStatusRefund:
        default:
            title = REORDER;
            break;
    }
    
    //self.confirmButton.layer.cornerRadius = 5.0f;
    //self.confirmButton.layer.masksToBounds = YES;
    [self.confirmButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.confirmButton setTitle:title forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:color forState:UIControlStateNormal];
}

- (IBAction)clickConfirmButton:(id)sender {
    switch (self.order.coachStatus) {
        case CoachOrderStatusUnpaid:
            //支付页面
            [self pushPayController];
            break;
        case CoachOrderStatusReadyCoach:
            
            //待陪练，一天前可取消，当天不可取消
            if(self.order.isCoachCanCancel) {
                //取消预约
                [self popupCancelReasonView];
                break;
            }
        case CoachOrderStatusCoaching:
        case CoachOrderStatusReadyConfirm:
            [self doConfirmOrder];
            //确认
            break;
        case CoachOrderStatusUnPaidCancelled:
        case CoachOrderStatusCancelled:
        case CoachOrderStatusExpired:
        case CoachOrderStatusRefund:
        case CoachOrderStatusFinished:
        default:
            if ([self.confirmButton.currentTitle isEqualToString:WAIT_FOR_COMMENT]) {
                [self pushCommentController];
                break;
            }
            
            //由于有可能无法获取具体服务项目，跳去教练详情页面
            [self pushCoachIntroductionController];
            
            break;
        }
    
    [MobClickUtils event:umeng_event_click_coach_order_bottom label:self.confirmButton.titleLabel.text];
}

#define TAG_CONFIRM 0x0001
-(void)doConfirmOrder
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"是否确认？" message:@"(确认后约练费用将会打到对方的账户)" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = TAG_CONFIRM;
    [alert show];
}

-(void)pushCommentController
{
    CoachWriteReviewController *controller = [[CoachWriteReviewController alloc] initWithBusinessId:self.order.coachId businessName:@"评价" orderId:self.order.orderId];
    
    [self.navigationController pushViewController:controller animated:YES];
}


//-(void)pushOrderController
//{
//    CoachOrderController *controller = [[CoachOrderController alloc]initWithCoachId:self.order.coachId name:self.order.coachName];
//    [self.navigationController pushViewController:controller animated:YES];
//
//}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_CONFIRM) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [SportProgressView showWithStatus:@"确认中"];
            [CoachService confirmService:self userId:[[UserManager defaultManager] readCurrentUser].userId orderId:self.order.orderId];
        }
    }
}

-(void)didConfirmService:(NSString *)status msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismiss];
        
        [self pushCommentController];
    }else {
        [SportProgressView dismissWithError:msg];
    }
}

#pragma mark-- tableView的delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [CoachDetailCell getCellIdentifier];
    CoachDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Use cell delegate
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier:[CoachDetailCell getCellIdentifier] configuration:^(CoachDetailCell *cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
    
}

- (CGFloat)height
{
    CGFloat height = 0;
    for (NSUInteger row = 0 ; row < [self.dataList count]; row ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        height += [self.contentTableView fd_heightForCellWithIdentifier:[CoachDetailCell getCellIdentifier] configuration:^(CoachDetailCell *cell) {
            [self configureCell:cell atIndexPath:indexPath];
        }];
    }
    return height;
}

-(void) configureCell:(CoachDetailCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    BOOL isLast = (indexPath.row == [self.dataList count] - 1);
    
    cell.fd_enforceFrameLayout = NO;
    NSString *title = [self.dataList objectAtIndex:indexPath.row];
    NSString *content = @"";
    if ([title isEqualToString:TITLE_ORDER_SN]) {
        content = self.order.orderNumber;
    }
    else if ([title isEqualToString:TITLE_CATEGORY]) {
        content = self.order.coachCategory;
        
    }else if ([title isEqualToString:TITLE_TIME]) {
        if (_order.coachStartTime == nil) {
            return;
        }
        
        NSDate *endTime = [NSDate dateWithTimeIntervalSince1970:_order.coachStartTime.timeIntervalSince1970 + _order.coachDuration*60];
        
        NSString *startTimeString = [DateUtil stringFromDate:_order.coachStartTime DateFormat:[NSString stringWithFormat:@"yyyy年MM月dd日（%@）\nHH:mm-",[DateUtil ChineseWeek2:_order.coachStartTime]]];
        
        content = [startTimeString stringByAppendingString:[DateUtil stringFromDate:endTime DateFormat:@"HH:mm"]];
        
    }else if ([title isEqualToString:TITLE_ADDRESS]) {
        content = self.order.coachAddress;
    }else if ([title isEqualToString:TITLE_PRICE]) {
        content = [PriceUtil toPriceStringWithYuan:_order.amount];
        
    }
    
    UIColor *contentColor = (isLast ? [SportColor defaultOrangeColor] : nil);
    [cell updateCellWithTitle:title content:content indexPath:indexPath isLast:isLast contentColor:contentColor];
}

- (IBAction)clickPhoneButton:(id)sender {
    [MobClickUtils event:umeng_event_click_coach_order_phone];
    BOOL result = [UIUtils makePromptCall:self.order.coachPhone];
    if (result == NO) {
        [SportPopupView popupWithMessage:@"此设备不支持打电话"];
    }
}

-(void)popupCancelReasonView
{
    self.cancelView = [CoachCancelReasonView createCoachCancelReasonView];
    [self.cancelView show];
    self.cancelView.delegate = self;
}

-(void)didClickConfirmCancelButtonWithReasonId:(NSString *)reasonId
{
    [SportProgressView showWithStatus:@"加载中"];
    [CoachService cancelCoachBespeak:self userId:[[UserManager defaultManager] readCurrentUser].userId orderId:self.order.orderId reasonId:reasonId];
}

- (void)didCancelCoachBooking:(NSString *)status
                          msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismiss];
        [self queryData];
        [self dismissReasonView];
        
        [self performSelector:@selector(popupWithMessage:) withObject:@"取消预约成功" afterDelay:1];
        
    } else {
        [SportProgressView dismissWithError:msg];
    }
}

-(void)popupWithMessage:(NSString *)message
{
    [SportPopupView popupWithMessage:message];
}

-(void)dismissReasonView
{
    [self.cancelView removeFromSuperview];
}

- (void)pushPayController
{
    
    PayController *controller = [[PayController alloc] initWithOrder:self.order];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)clickRefundUrl:(id)sender {
    SportWebController *controller = [[SportWebController alloc]initWithUrlString:self.order.refundUrl title:@"退款说明"];
    [self.navigationController pushViewController:controller animated:YES];
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
