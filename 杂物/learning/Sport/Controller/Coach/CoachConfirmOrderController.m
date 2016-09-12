//
//  CoachConfirmOrderController.m
//  Sport
//
//  Created by qiuhaodong on 15/7/24.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CoachConfirmOrderController.h"
#import "CoachService.h"
#import "UserManager.h"
#import "SportProgressView.h"
#import "OrderConfirmPriceView.h"
#import "UIView+Utils.h"
#import "PayController.h"
#import "Voucher.h"
#import "SportPopupView.h"
#import "CityManager.h"
#import "CoachOftenArea.h"

@interface CoachConfirmOrderController () <CoachServiceDelegate, OrderConfirmPriceViewDelegate>

@property (copy, nonatomic) NSString *coachId;
@property (copy, nonatomic) NSString *goodsId;
@property (strong, nonatomic) NSDate *bookDate;
@property (assign, nonatomic) int timeRange;
@property (assign, nonatomic) int duration;
@property (copy, nonatomic) NSString *categoryId;

@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) CoachOftenArea *address;
@property (copy, nonatomic) NSString *activityId;
@property (strong, nonatomic) Voucher *voucher;

@property (weak, nonatomic) IBOutlet UIView *priceHolderView;
@property (weak, nonatomic) IBOutlet UIView *bottomHolderView;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UILabel *refundTipsLabel;

@end

@implementation CoachConfirmOrderController

//1.9 配合新接口
- (instancetype)initWithCoachId:(NSString *)coachId
                        goodsId:(NSString *)goodsId
                      startTime:(NSDate *)startTime
                        address:(CoachOftenArea *)address
{
    self = [super init];
    if (self) {
        self.coachId = coachId;
        self.goodsId = goodsId;
        self.startTime = startTime;
        self.address = address;
    }
    return self;
}

//- (instancetype)initWithCoachId:(NSString *)coachId
//                       bookDate:(NSDate *)bookDate
//                      timeRange:(int)timeRange
//                       duration:(int)duration
//                     categoryId:(NSString *)categoryId
//                      startTime:(NSDate *)startTime
//                        address:(NSString *)address
//{
//    self = [super init];
//    if (self) {
//        self.coachId = coachId;
//        self.bookDate = bookDate;
//        self.timeRange = timeRange;
//        self.duration = duration;
//        self.categoryId = categoryId;
//        self.startTime = startTime;
//        self.address = address;
//    }
//    return self;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"确认预约";
//    
//    [self.submitButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateNormal];
    
    self.priceHolderView.hidden = YES;
    self.bottomHolderView.hidden = YES;
    [self queryData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updatePhone];
}

- (void)updatePhone
{
    User *user  = [[UserManager defaultManager] readCurrentUser];
    if ([user.phoneNumber length] > 0) {
        self.phoneLabel.text = [NSString stringWithFormat:@"您的手机号码:%@", user.phoneNumber];
    } else {
        self.phoneLabel.text = @"您未绑定手机号码";
    }
}

- (void)queryData
{
    [SportProgressView showWithStatus:@"加载中"];
    
    [CoachService coachConfirmOrderBespeak:self
                                    userId:[[UserManager defaultManager] readCurrentUser].userId
                                   goodsId:self.goodsId
                                 startTime:self.startTime
                                 orderType:OrderTypeCoach];
//    [[CoachService defaultService] coachConfirmOrder:self
//                                              userId:[[UserManager defaultManager] readCurrentUser].userId
//                                             coachId:self.coachId
//                                            bookDate:self.bookDate
//                                           timeRange:self.timeRange
//                                            duration:self.duration
//                                          categoryId:self.categoryId];
}

- (void)didCoachConfirmOrder:(NSString *)status
                         msg:(NSString *)msg
                 totalAmount:(float)totalAmount
                 orderAmount:(float)orderAmount
                orderPromote:(float)orderPromote
                activityList:(NSArray *)activityList
             activityMessage:(NSString *)activityMessage
          selectedActivityId:(NSString *)selectedActivityId
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismiss];
        self.priceHolderView.hidden = NO;
        self.bottomHolderView.hidden = NO;
        
        self.activityId = selectedActivityId;
        
        OrderConfirmPriceView *orderConfirmPriceView = [OrderConfirmPriceView createOrderConfirmPriceView];
       self.orderConfirmPriceView=orderConfirmPriceView;
        orderConfirmPriceView.delegate = self;
        [orderConfirmPriceView updateViewWithAmount:totalAmount
                           canUseActivityAndVoucher:YES
                                       activityList:activityList
                                 selectedActivityId:self.activityId
                                            voucher:nil
                                         controller:self
                                    activityMessage:activityMessage
                                           goodsIds:self.coachId
                                          orderType:OrderTypeCoach];
        
        
        [self.priceHolderView addSubview:orderConfirmPriceView];
        [self.priceHolderView updateHeight:orderConfirmPriceView.frame.size.height];
        
        [self.bottomHolderView updateOriginY:self.priceHolderView.frame.origin.y + self.priceHolderView.frame.size.height + 10];
        
        [self removeNoDataView];
    } else {
        [SportProgressView dismissWithError:msg];
        
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        CGRect frame = CGRectMake(0, 0, screenSize.width, screenSize.height - 64);
        [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:msg];
    }
}

- (void)didSelectActivity:(NSString *)selectedActivityId
{
    self.voucher = nil;
    self.activityId = selectedActivityId;
}

- (void)didSelectVoucher:(Voucher *)voucher
{
    self.voucher = voucher;
    self.activityId = nil;
}

- (void)didCancelSelectVoucher
{
    self.voucher = nil;
}

- (void)didClickNoDataViewRefreshButton
{
    [self queryData];
}

#define TAG_ALERTVIEW_BIND_PHONE 2015072701
- (IBAction)clickSubmitButton:(id)sender {
    User *user  = [[UserManager defaultManager] readCurrentUser];
    
    if ([user.phoneNumber length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"为了你的账号安全，请绑定手机号码再提交订单" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        alertView.tag = TAG_ALERTVIEW_BIND_PHONE;
        [alertView show];
       // [alertView release];
        return;
    }
    
    [self submitOrder];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_ALERTVIEW_BIND_PHONE) {
        RegisterController *controller = [[RegisterController alloc] initWithVerifyPhoneType:VerifyPhoneTypeBind] ;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)submitOrder
{
    [MobClickUtils event:umeng_event_click_submit_order_button label:@"约练订单"];
    
    [SportProgressView showWithStatus:@"正在提交" hasMask:YES];
    User *user = [[UserManager defaultManager] readCurrentUser];
    [CoachService addCoachOrderBespeak:self
                                userId:user.userId
                                 phone:user.phoneEncode
                               coachId:self.coachId
                               address:self.address.businessName
                               goodsId:self.goodsId
                             startTime:self.startTime
                             orderType:OrderTypeCoach
                            activityId:self.activityId
                              couponId:self.voucher.voucherId
                                cityId:[CityManager readCurrentCityId]
                           voucherType:self.voucher.type];
}

- (void)didAddCoachOrder:(NSString *)status
                     msg:(NSString *)msg
                   order:(Order *)order
          cancelOrderMsg:(NSString *)cancelOrderMsg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        
        if ([cancelOrderMsg length] > 0) {
            [SportProgressView dismissWithSuccess:cancelOrderMsg];
        } else {
            [SportProgressView dismiss];
        }

        [self performSelector:@selector(pushPayControllerWithOrder:) withObject:order afterDelay:0.1];
        
        /*
        if ([cancelOrderMsg length] > 0) {
            [SportPopupView popupWithMessage:cancelOrderMsg];
        }*/
    } else {
        [SportProgressView dismissWithError:msg];
    }
}

- (void)pushPayControllerWithOrder:(Order *)order {
    
    PayController *controller = [[PayController alloc] initWithOrder:order];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
