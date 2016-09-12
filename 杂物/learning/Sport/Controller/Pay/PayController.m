//
//  PayController.m
//  Sport
//
//  Created by haodong  on 14-8-18.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "PayController.h"
#import "Order.h"
#import "UIView+Utils.h"
#import "Voucher.h"
#import "PriceUtil.h"
#import "OrderManager.h"
#import "SportPopupView.h"
#import "SportProgressView.h"
#import "AliPayOrder.h"
#import "AliPayManager.h"
#import "WeChatPayManager.h"
#import "UserManager.h"
#import "SportPopupView.h"
#import "PayHelpController.h"
#import "SingleBookingController.h"
#import "BaseConfigManager.h"
#import "UIUtils.h"
#import "FavourableActivity.h"
#import "MyPointController.h"
#import "DateUtil.h"
#import "ProductDetailGroupView.h"
#import "WebPayController.h"
#import "PayMethod.h"
#import "NSDictionary+JsonValidValue.h"
#import "ForumEntrance.h"
#import "ForumEntranceView.h"
#import "ShareView.h"
#import "PayMembershipCardInfoView.h"
#import "PaySuccessView.h"
#import "MonthCardFinishPayController.h"
#import "MembershipCardVerifyPhoneController.h"
#import "NSDate+Correct.h"
#import "MyVouchersController.h"
#import "HomeController.h"
#import "SportNavigationController.h"
#import "AppDelegate.h"
#import "Product.h"
#import "PaySuccessWithRedPacketView.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageDownloader.h"
#import "ShareFieldWillingSurveyView.h"
#import "ShortTipsView.h"
#import "HWWeakTimer.h"
#include "PreciseTimerHelper.h"
#import "SponsorCourtJoinEditingView.h"
#import "ImprovePersonalInfoController.h"
#import "SponsorCourtJoinView.h"
#import <objc/runtime.h>
#import "UIImage+normalized.h"
#import "SportOrderDetailFactory.h"
@interface PayController () <ShareViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *orderHolderViewTopLineImageView;
@property (strong, nonatomic) IBOutlet UIView *orderHolderViewBottomLineImageView;
@property (strong, nonatomic) Order *order;
@property (strong, nonatomic) PayMethod *selectedPayMethod;
@property (assign, nonatomic) BOOL stopCalTime;
@property (weak, nonatomic) IBOutlet UIView *orderDetailView;
@property (assign, nonatomic) BOOL localPaySuccess;
@property (assign, nonatomic) BOOL isSelectedMoney;
@property (copy, nonatomic) NSString *payPassword;
@property (strong, nonatomic) ForumEntrance *forumEntrance;
@property (assign, nonatomic) double thirdPartyPayAmount;
@property (strong, nonatomic) PaySuccessWithRedPacketView *redPacketView;
@property (copy, nonatomic) NSString *urlString;
@property (strong, nonatomic) UIImage *redBacketImage;
@property (strong, nonatomic) ShortTipsView *tipsView;
@property (assign, nonatomic) BOOL isShowShortTips;
@property (strong, nonatomic) PaySuccessView *paySuccessView;

@property (assign, nonatomic) uint64_t startTime;
@property (weak, nonatomic) NSTimer *countDownTimer;
@property (copy, nonatomic) NSString *shareSource;
@end

@implementation PayController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (instancetype)initWithOrder:(Order *)order
{
    self = [super init];
    if (self) {
        self.order = order;
        [self registerNotification];
    }
    return self;
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushImprovePersonalInfoController) name:NOTIFICATION_NAME_COURT_JOIN_IMPROVE_PERSONAL_INFO object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareCourtJoin:) name:NOTIFICATION_NAME_POP_SHARE_VIEW object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sponsorCourtJoinSucceed:) name:NOTIFICATION_NAME_COURT_JOIN_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateShareContent:) name:NOTIFICATION_NAME_UPDATE_COURT_JOIN_SHARE_CONTENT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClickCJRegulationButton) name:NOTIFICATION_NAME_DID_CLICK_CJ_REGULATION_BUTTON object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"支付";
    [self createRightTopButton:@"帮助"];
    [self.orderHolderViewTopLineImageView updateHeight:0.5];
    [self.orderHolderViewBottomLineImageView updateOriginY:49.5];
    [self.orderHolderViewBottomLineImageView updateHeight:0.5];
    //[self.payButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateNormal];
    [self.unpayHolderView updateHeight:[UIScreen mainScreen].bounds.size.height - 20 - 44];
    
    self.unpayHolderView.hidden = NO;
    self.paySuccessHolderView.hidden = YES;
    self.timeDelayHolderView.hidden = YES;
    [self updateUnpayOrderData];
    
//    if (_order.type != OrderTypePackage || _order.type != OrderTypeCourse) {
//        [self queryHotTopic];
//    }
    
    [SportProgressView showWithStatus:@"正在刷新订单" hasMask:YES];
    [self queryOrderData];
    
    NSString *eventLabel = nil;
    if (_order.type == OrderTypeDefault) {
        eventLabel = @"场次";
    } else if (_order.type == OrderTypeSingle) {
        eventLabel = @"人次";
    } else if (_order.type == OrderTypePackage) {
        eventLabel = @"特惠";
    } else if (_order.type == OrderTypeMembershipCard) {
        eventLabel = @"会员";
    } else if (_order.type == OrderTypeMonthCardRecharge) {
        eventLabel = @"月卡";
    } else if (_order.type == OrderTypeCourse) {
        eventLabel = @"课程";
    }else if (_order.type == OrderTypeCourtPool) {
        eventLabel = @"拼场";
    }
    
    [MobClickUtils event:umeng_event_enter_pay label:eventLabel];
}

- (void)clickRightTopButton:(id)sender
{
    [MobClickUtils event:umeng_event_pay_success_click_help];
     
    PayHelpController *controller = [[PayHelpController alloc] init] ;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_paySuccessView appearSponsorCourtJoinView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_paySuccessView hideSponsorCourtJoinView];
}

- (void)startTimer {
    
    if (self.countDownTimer != nil) {
        [self stopTimer];
    }
    
    typeof(self) __weak weakSelf = self;
    self.countDownTimer = [HWWeakTimer scheduledTimerWithTimeInterval:1 target:weakSelf selector:@selector(calTime) userInfo:nil repeats:YES];
    
    [self.countDownTimer fire];
}

//不需要调用stopTimer,HWWeakTimer已经做了相关处理
- (void)stopTimer {
    if(self.countDownTimer){
        [self.countDownTimer invalidate];
        self.countDownTimer = nil;
    }
}

#define MAX_PAY_TIME 600
- (void)calTime
{
    int diff = abs_to_nanos(mach_absolute_time()-self.startTime) / (1000.0 * NSEC_PER_MSEC);

    if (_order) {
      
       if (_order.status == OrderStatusUnpaid && diff < self.order.payExpireLeftTime) {
           int remain = self.order.payExpireLeftTime - diff;
           int m = remain / 60;
           int s = remain % 60;
           
           NSString *tipsEnd = nil;
           if (_order.type == OrderTypeMembershipCard) {
               tipsEnd = @"内完完成订场，订场费用将在您消费当天由场馆从会员卡中扣除。";
           } else if (_order.type == OrderTypeCoach) {
               tipsEnd = @"内完成付款，否则该时段不予保留。";
           } else {
               tipsEnd = @"内完成付款，否则订单自动取消。";
           }
           NSString *tips = [NSString stringWithFormat:@"请在%d分%d秒%@", m, s, tipsEnd];
           
           NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc]initWithString:tips];
           if (s < 10) {
               [attributedStr addAttribute:NSForegroundColorAttributeName value:[SportColor otherRedColor] range:NSMakeRange(2, 4)];
           }else{
               [attributedStr addAttribute:NSForegroundColorAttributeName value:[SportColor otherRedColor] range:NSMakeRange(2, 5)];
           }
           self.remainingTimeLabel.attributedText = attributedStr;
       } else {
           if (diff >= self.order.payExpireLeftTime) {
               NSString *title = @"支付超时";
               self.remainingTimeLabel.text = title;
           }else {
               self.remainingTimeLabel.text = @"";
           }
           
           [self stopTimer];
           return;
       }
       
//       dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//           sleep(1);
//           dispatch_async(dispatch_get_main_queue(), ^{
//               [self calTime];
//           });
//       });
    }
}

- (BOOL)handleGestureNavigate
{
    [self clickBackButton:nil];
    return NO;
}

- (void)clickBackButton:(id)sender
{
    [_paySuccessView.sponsorCourtJoinView removeFromSuperview];
    NSUInteger count = [self.navigationController.childViewControllers count];
    NSUInteger preIndex = (count >= 2 ? count - 2  : 0 );
    UIViewController *preController = [self.navigationController.childViewControllers objectAtIndex:preIndex];//上一个controller
    if ([preController isKindOfClass:NSClassFromString(@"BusinessOrderConfirmController")]
        || ([preController isKindOfClass:[SingleBookingController class]] && _order.status == OrderStatusPaid) || [NSStringFromClass([preController class]) isEqualToString:@"CourtJoinConfirmOrderController"]) {
        
        NSUInteger targetIndex = (count >= 3 ? count - 3  : 0 ); //退两页
        UIViewController *targetController = [self.navigationController.childViewControllers objectAtIndex:targetIndex];
        [self.navigationController popToViewController:targetController animated:YES];
        
    } else if ([NSStringFromClass([preController class]) isEqualToString:@"CoachConfirmOrderController"]) { //如果是约练订单
        NSUInteger targetIndex = (count >= 4 ? count - 4  : 0 ); //退三页
        UIViewController *targetController = [self.navigationController.childViewControllers objectAtIndex:targetIndex];
        [self.navigationController popToViewController:targetController animated:YES];
        
    }else if (_order.type == OrderTypeMonthCardRecharge && _order.status == OrderStatusPaid) { //如果是月卡充值订单，并且充值成功
        
        UIViewController *beforeController = nil;
        for (UIViewController *one in self.navigationController.childViewControllers) {
            NSString *name = NSStringFromClass([one class]);
            if ([name isEqualToString:@"MonthCardRechargeController"]      //找出月卡充值页的前一个页面，或月卡介绍页的前一个页面
                || [name isEqualToString:@"ActClubIntroduceController"]) {
                break;
            } else {
                beforeController = one;
            }
        }
        
        if (beforeController) {
            [self.navigationController popToViewController:beforeController animated:YES];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#define  SPACE 15
#define  TIPS_AND_ORIGINAL_SPACE 40
- (void)updateUnpayOrderData
{
    CGFloat y = SPACE;
    if(self.isShowShortTips){
            y = TIPS_AND_ORIGINAL_SPACE;
    }else{
            y = SPACE;
    }

    
    //订单名称
    [self.orderHolderView updateOriginY:y];
    y += self.orderHolderView.frame.size.height + SPACE;
    
    if (self.order.type == OrderTypeCourtPool) {
        self.orderNameLabel.text = [NSString stringWithFormat:@"%@ %@",self.order.businessName,[DateUtil stringFromDate:self.order.startTime DateFormat:@"MM月dd日H点拼场"] ];
    } else {
        self.orderNameLabel.text = _order.orderName;
    }
    
    //支付金额
    BOOL isShowPrice = NO;
    if (_order.type == OrderTypeMembershipCard) {
        isShowPrice = NO;
    } else {
        isShowPrice = YES;
    }
    
    if (isShowPrice) {
        self.payTypeHolderView.hidden = NO;
        [self updatePriceHoderView];
        [self.priceHolderView updateOriginY:y];
        y += self.priceHolderView.frame.size.height + SPACE;
    } else {
        self.payTypeHolderView.hidden = YES;
    }
    
    //会员卡信息
    BOOL isShowMembershipCardInfo = NO;
    if (_order.type == OrderTypeMembershipCard) {
        isShowMembershipCardInfo = YES;
    } else {
        isShowMembershipCardInfo = NO;
    }
    
    if (isShowMembershipCardInfo) {
        self.cardInfoHolderView.hidden = NO;
        
        for (UIView *subView in self.cardInfoHolderView.subviews) {
            [subView removeFromSuperview];
        }
        PayMembershipCardInfoView *payMembershipCardInfoView = [PayMembershipCardInfoView createViewWithOrder:_order];
        [self.cardInfoHolderView addSubview:payMembershipCardInfoView];
        [self.cardInfoHolderView updateHeight:payMembershipCardInfoView.frame.size.height];
        [self.cardInfoHolderView updateOriginY:y];
        y += self.cardInfoHolderView.frame.size.height + SPACE;
    } else {
        self.cardInfoHolderView.hidden = YES;
    }
    
    //初始化默认选中支付方式  //默认选中第一个 20160517
    NSArray *payMethodList = [self.order.payMethodList count] > 0?self.order.payMethodList:[[BaseConfigManager defaultManager] payMethodList];
    if ([payMethodList count] > 0) {
        self.selectedPayMethod = [payMethodList objectAtIndex:0];
    }
//    if (self.selectedPayMethod == nil && [payMethodList count] > 0) {
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        NSString *selectedPayKey = [defaults valueForKey:KEY_LAST_SELECTED_PAY];
//        
//        self.selectedPayMethod = [payMethodList objectAtIndex:0];
//        if (selectedPayKey != nil) {
//            for (PayMethod *one in payMethodList) {
//                if ([one.payKey isEqualToString:selectedPayKey]) {
//                    self.selectedPayMethod = one;
//                    break;
//                }
//            }
//        }
//    }
    
    //支付方式
    BOOL isShowPayType = NO;
    if (_order.type == OrderTypeMembershipCard
        || _order.isClubPay
        || ![[PaymentAnimator shareAnimator] isNeedThirdPay:self.thirdPartyPayAmount]) {
        isShowPayType = NO;
    } else {
        isShowPayType = YES;
    }
    
    if (isShowPayType) {
        self.payTypeHolderView.hidden = NO;

        //更新支付方式
        for (UIView *subView in self.payTypeHolderView.subviews) {
            [subView removeFromSuperview];
        }
        
        PayTypeView *payTypeView = [PayTypeView createViewWithMethodList:payMethodList selectedMethod:self.selectedPayMethod delegate:self];
        [self.payTypeHolderView addSubview:payTypeView];
        [self.payTypeHolderView updateHeight:payTypeView.frame.size.height];
        [self.payTypeHolderView updateOriginY:y];
        y += self.payTypeHolderView.frame.size.height + SPACE;
    } else {
        self.payTypeHolderView.hidden = YES;
    }
    
    //倒计时提示
    self.tipsHolderView.hidden = NO;
    [self.tipsHolderView updateOriginY:y];
    y += self.tipsHolderView.frame.size.height + SPACE / 2;
    
    
    //支付按钮
    [self.payButton updateOriginY:y];
    y += self.payButton.frame.size.height + SPACE;
    if (_order.type == OrderTypeMembershipCard) {
        [self.payButton setTitle:@"确定订场" forState:UIControlStateNormal];
    } else {
        [self.payButton setTitle:@"支付" forState:UIControlStateNormal];
    }
    
    
    [self.unpayHolderView setContentSize:CGSizeMake(_unpayHolderView.frame.size.width, y)];
}

- (void)didClickPayTypeView:(PayMethod *)payMethod
{
    self.selectedPayMethod = payMethod;
}

- (void)updatePriceHoderView
{
    for (UIView *subView in self.priceHolderView.subviews) {
        [subView removeFromSuperview];
    }
    
    PayAmountView *view = [PayAmountView createViewWithOrder:_order
                                             isSelectedMoney:_isSelectedMoney
                                                    delegate:self];
    [self.priceHolderView addSubview:view];
    
    [self.priceHolderView updateHeight:view.frame.size.height];
}

- (void)didClickPayAmountViewMoneyButton:(BOOL)isSelectedMoney
{
    self.isSelectedMoney = isSelectedMoney;
    //[self updatePriceHoderView];
    [self updateUnpayOrderData];
}

- (void)didCalculateThirdPartyPayAmount:(double)thirdPartyPayAmount
{
    self.thirdPartyPayAmount = thirdPartyPayAmount;
}

- (void)queryHotTopic
{
    [ForumService hotTopic:self
                  venuesId:_order.businessId
                    userId:[[UserManager defaultManager]
                            readCurrentUser].userId];
}

- (void)didHotTopic:(ForumEntrance *)forumEntrance status:(NSString *)status msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS] && forumEntrance) {
        self.forumEntrance = forumEntrance;
    }
}

#define TAG_BACKGROUND_IMAGEVIEW    200
#define TAG_LINE                    100
#define TAG_LINE_VERTICAL           101
- (void)updateLineImageView:(UIView *)view
{
    if ([view isKindOfClass:[UIImageView class]]) {
        if (view.tag == TAG_LINE) {
            [(UIImageView *)view setImage:[SportImage lineImage]];
        } else if (view.tag == TAG_LINE_VERTICAL) {
            [(UIImageView *)view setImage:[SportImage lineVerticalImage]];
        } else if (view.tag == TAG_BACKGROUND_IMAGEVIEW) {
            [(UIImageView *)view setImage:[SportImage whiteBackgroundImage]];
        }
    }
}

- (void)updatePaySuccessHolderView
{
    //含保险订单
    if (_order.insuranceUrl.length > 0) {
        // status=1表示从支付成功页面进入
        NSString *warpUrlString = [NSString stringWithFormat:@"%@&status=1", _order.insuranceUrl];
        SportWebController *webController = [[SportWebController alloc] initWithUrlString:warpUrlString title:nil channelList:[NSArray arrayWithObjects:@(ShareChannelWeChatSession), @(ShareChannelQQ), @(ShareChannelSMS), nil]];
        [self.navigationController pushViewController:webController animated:NO];
    }
    
    [_paySuccessView removeFromSuperview];
    self.paySuccessView = [PaySuccessView createViewWithOrder:_order];
    objc_setAssociatedObject(_paySuccessView, &KEY_SELECTED_PAY_METHOD, _selectedPayMethod, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    //绑定todo
    _paySuccessView.paydelegate = self;
    [self.paySuccessHolderView addSubview:_paySuccessView];
    [self.paySuccessHolderView updateHeight:self.view.frame.size.height];
}

//代理方法；
-(void)PaySuccessViewBackToHome{

  [self.navigationController popToRootViewControllerAnimated:YES];

}
//代理方法；
-(void)shareOrderInfoWith:(Order *)order{

    [MobClickUtils event:umeng_event_pay_success_click_share];
    
    ShareContent *shareContent = [[ShareContent alloc] init] ;
    shareContent.thumbImage = [UIImage imageNamed:@"ForwardOrder"];
    shareContent.title = @"场地搞定了,就等你了!";
    
     NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
     [formatter setDateFormat:@"MM月dd日"];
    
     NSString *st = [formatter stringFromDate:order.useDate];
  
     NSString *s1=[[NSString alloc] init];
     for (Product * p in order.productList) {
   
          NSString *s=[NSString stringWithFormat:@"%@(%@)",p.courtName,p.startTimeToEndTime];
   
           s1=[s1 stringByAppendingString:s];
     }

    shareContent.content = [NSString stringWithFormat:@"场馆名:%@ ,使用日期:%@ 点击查看订单详情(含订单信息，注意信息安全)",order.businessName,st];
    shareContent.subTitle= [NSString stringWithFormat:@"场馆名:%@ ,使用日期:%@ 点击查看订单详情(含订单信息，注意信息安全)",order.businessName,st];
 
    shareContent.linkUrl = order.shareUrl;
    
    self.shareSource = @"order";
    
    [ShareView popUpViewWithContent:shareContent channelList:@[@(ShareChannelWeChatSession), @(ShareChannelQQ), @(ShareChannelSMS)] viewController:self delegate:self];
}

- (IBAction)clickPayButton:(id)sender {
    if (_order.type == OrderTypeMembershipCard) {
        [SportProgressView showWithStatus:@"请求确认中" hasMask:YES];
    }
    
    if ([self canPay] == NO) {
        [SportProgressView dismiss];
        return;
    }
    
    //有无选择支付方式
    if (_order.type != OrderTypeMembershipCard
        && _order.isClubPay != YES
        && [[PaymentAnimator shareAnimator] isNeedThirdPay:self.thirdPartyPayAmount]) {
        if (self.selectedPayMethod == nil) {
            [SportPopupView popupWithMessage:@"请选择支付方式"];
            [SportProgressView dismiss];
            return;
        }
    }
    
    //发起支付
    PayRequest *payRequest = [PayRequest requestWithOrder:_order payMethod:_selectedPayMethod password:_payPassword thirdPartyPayAmount:_thirdPartyPayAmount isUsedBalance:_isSelectedMoney];
    [self payRequest:(PayRequest *)payRequest];

}

- (void)payRequest:(PayRequest *)payRequest {
    [[PaymentAnimator shareAnimator] payRequest:payRequest sponser:self];
}

- (void)paymentAnimatorPayFail:(NSString *)msg {
    [SportProgressView dismissWithError:msg];
}

- (void)paymentAnimatorPaySuccess:(NSString *)msg {
    self.localPaySuccess = YES;
    [self queryOrderData];
}

- (void)paymentAnimatorHandleWebPayBack {
    [SportProgressView dismiss];
    //每次回来需刷新订单
    [self performSelector:@selector(webPayBackHandle) withObject:nil afterDelay:0.5];
}

- (void)queryOrderData
{
    [SportProgressView showWithStatus:@"正在请求支付" hasMask:YES];
    //一进来就记录开始的时间
    self.startTime =  mach_absolute_time();
    User *user = [[UserManager defaultManager] readCurrentUser];
    [OrderService queryOrderDetail:self
                           orderId:_order.orderId
                            userId:user.userId
                           isShare:@"1"
                        entrance:1];
}

- (void)configurePopupWindows {
    //红包
    if (self.order.shareInfo.count != 0) {
        [MobClickUtils event:umeng_event_show_share_red_packet_window];
        self.redPacketView = [PaySuccessWithRedPacketView createPaySuccessWithRedPacketView];
        self.redPacketView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        self.redPacketView.delegate = self;
        [self.view addSubview:self.redPacketView];
    }
    //分享场地意愿调查
    if (self.order.surveySwitchFlag == 1) {
        [ShareFieldWillingSurveyView showWithOrderId:self.order.orderId];
    }
}

#pragma mark - OrderServiceDelegate
- (void)didQueryOrderDetail:(NSString *)status
                        msg:(NSString *)msg
                resultOrder:(Order *)resultOrder {
    [SportProgressView dismiss];
    if ([status isEqualToString:STATUS_SUCCESS]) {
        self.order = resultOrder;
        self.isSelectedMoney = (self.order.money > 0);
        [self startTimer];
        if([_order.insurancePayTips length]>0){
            [self showShortTipsView:_order.insurancePayTips];
        }
        ////会员卡支付 || 会员卡支付
        if (_order.status == OrderStatusPaid || _order.status == OrderStatusCardPaid) {
            
            NSDictionary *dic = @{@"order_id":self.order.orderId};
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_FINISH_PAY_ORDER object:nil userInfo:dic];
            
            self.unpayHolderView.hidden = YES;
            self.paySuccessHolderView.hidden = NO;
            self.timeDelayHolderView.hidden = YES;
            
            //todo不放在刷新订单，放在支付成功回调
            if (_order.type == OrderTypeMembershipCard) {
                [MobClickUtils event:umeng_event_card_order_success];
            } else {
                [MobClickUtils event:umeng_event_pay_success];
            }
            
            [self configurePopupWindows];
            
            typeof(self) __weak weakSelf = self;
             SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
             [downloader downloadImageWithURL:[NSURL URLWithString:resultOrder.shareInfo[@"icon"]]
                                      options:0
                                     progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                         // progression tracking code
                                     }
                                    completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                        if (image && finished) {
                                            weakSelf.redBacketImage = image;
                                        }
                                    }];

            
            [self updatePaySuccessHolderView];
        } else {
            if (_localPaySuccess) {
                self.unpayHolderView.hidden = YES;
                self.timeDelayHolderView.hidden = NO;
                
                [self updateTimeDelayHolderView];
            } else {
                self.unpayHolderView.hidden = NO;
                self.timeDelayHolderView.hidden = YES;
                [self updateUnpayOrderData];
            }
            self.paySuccessHolderView.hidden = YES;
        }
        
        [self removeNoDataView];
    } else {
        /*
         if (_localPaySuccess) {
         self.unpayHolderView.hidden = YES;
         self.timeDelayHolderView.hidden = NO;
         
         [self updateTimeDelayHolderView];
         } */
        
        CGSize size = [UIScreen mainScreen].bounds.size;
        CGRect frame = CGRectMake(0, 0, size.width, size.height - 64);
        [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:msg];
    }
}
- (void)showShortTipsView:(NSString *)tips {
    if( ! self.isShowShortTips){
        self.tipsView = [ShortTipsView creatShortTipsView];
        CGRect tipsViewFrame = CGRectMake(0, -40, [UIScreen mainScreen].bounds.size.width, 40);
        [self.tipsView showWithContent:tips frame:tipsViewFrame durationDisplay:YES holderView:self.unpayHolderView];
        self.isShowShortTips = YES;
    }
    [self updateUnpayOrderData];
}

- (void)didClickNoDataViewRefreshButton
{
    [SportProgressView showWithStatus:@"加载中"];
    [self queryOrderData];
}

- (void)updateTimeDelayHolderView
{
    for (UIView *subView in self.timeDelayHolderView.subviews) {
        [subView removeFromSuperview];
    }
   PayDelayView *view = [PayDelayView createViewWithOrder:_order delegate:self];
    view.delegate=self;
    
    [self.timeDelayHolderView addSubview:view];
}

- (void)didClickPayDelayViewRefreshButton
{
    [SportProgressView showWithStatus:@"正在刷新订单" hasMask:YES];
    [self queryOrderData];
}

- (void)webPayBackHandle {
    [SportProgressView showWithStatus:@"正在刷新订单" hasMask:YES];
    [self queryOrderData];
}

#define TAG_CANCEL_ORDER 20160412
- (BOOL)canPay
{
    if (is_expire(self.startTime,self.order.payExpireLeftTime) == 1) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"订单已过期，请重新下单支付" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        alert.tag = TAG_CANCEL_ORDER;
        [alert show];
        
        return NO;
    } else {
        return YES;
    }
//    [OrderManager checkOrderStatus:_order];
//    if (_order.status == OrderStatusCancelled) {
//        [SportPopupView popupWithMessage:@"订单已过期，请重新下单支付"];
//        return NO;
//    } else {
//        return YES;
//    }
}

#pragma mark -- Alert View Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_CANCEL_ORDER) {
        [self cancelOrder];
        [self clickBackButton:nil];
    }
}

- (void)cancelOrder {
    User *user = [[UserManager defaultManager] readCurrentUser];
    [OrderService cancelOrder:self
                        order:self.order
                       userId:user.userId];
}

#pragma mark - PaySuccessWithRedPacketViewDelegate
- (void)didClickShareButton{
    ShareContent *shareContent = [[ShareContent alloc] init];
    shareContent.thumbImage = self.redBacketImage;
    shareContent.title = self.order.shareInfo[@"title"];
    shareContent.subTitle = self.order.shareInfo[@"content"];;
    shareContent.content = self.order.shareInfo[@"content"];
    shareContent.linkUrl = self.order.shareInfo[@"link"];
    
    self.shareSource = @"redPacket";
    
    [ShareView popUpViewWithContent:shareContent channelList:[NSArray arrayWithObjects:@(ShareChannelWeChatSession),@(ShareChannelWeChatTimeline), nil] viewController:self delegate:self];
    
}

- (void)didClickShareViewButton{
    [self.redPacketView removeFromSuperview];
}

- (void)pushOrderDetailController {
    UIViewController *orderDetailController = [SportOrderDetailFactory orderDetailControllerWithOrder:_order];
    if (nil != orderDetailController) {
        [self.navigationController pushViewController:orderDetailController animated:YES];
    }
}

- (void)pushImprovePersonalInfoController {
    ImprovePersonalInfoController *controller = [[ImprovePersonalInfoController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)updateShareContent:(NSNotification *)notify {
    _order.courtJoin.shareContent.imageUrL = [notify.userInfo objectForKey:PARA_AVATAR];
    SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
    [downloader downloadImageWithURL:[NSURL URLWithString:_order.courtJoin.shareContent.imageUrL]
                             options:0
                            progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                // progression tracking code
                            }
                           completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                               if (image && finished) {
                                   _order.courtJoin.shareContent.thumbImage = [image compressWithMaxLenth:80];
                               }
                           }];
    
}

- (void)didClickCJRegulationButton {
    SportWebController *constroller = [[SportWebController alloc] initWithUrlString:[[BaseConfigManager defaultManager] courtJoinInstructionUrl] title:@"什么是球局"];
    [self.navigationController pushViewController:constroller animated:YES];
}

- (void)shareCourtJoin:(NSNotification *)notify {
    
    [MobClickUtils event:umeng_event_court_join_sponsor_click_share_button];
    self.shareSource = @"courtJoin";
    [ShareView popUpViewWithContent:_order.courtJoin.shareContent channelList:[NSArray arrayWithObjects:@(ShareChannelWeChatSession), @(ShareChannelWeChatTimeline), @(ShareChannelSina), @(ShareChannelQQ), nil] viewController:self delegate:self];
}

- (void)sponsorCourtJoinSucceed:(NSNotification *)notify {
    self.order.courtJoin.shareContent = [notify.userInfo objectForKey:PARA_SHARE_CONTENT];
}


- (void)willShare:(ShareChannel)channel{
    if ([self.shareSource isEqualToString:@"order"]) {
        NSString *name = @"";
        if (channel == ShareChannelWeChatSession) {
            name = @"微信";
        }else if (channel == ShareChannelQQ){
            name = @"QQ";
        }else if (channel == ShareChannelSMS){
            name = @"短信";
        }
        [MobClickUtils event:umeng_event_notify_friends label:name];
    }
}

- (void)didShare:(ShareChannel)channel {
    if ([self.shareSource isEqualToString:@"redPacket"]) {
        if (channel == ShareChannelWeChatSession) {
            [MobClickUtils event:umeng_event_click_share_red_packet label:@"微信朋友圈"];
        }else if(channel == ShareChannelWeChatTimeline){
            [MobClickUtils event:umeng_event_click_share_red_packet label:@"微信好友"];
        }
    } else if ([self.shareSource isEqualToString:@"courtJoin"]) {
        if (channel == ShareChannelWeChatSession) {
            [MobClickUtils event:umeng_event_court_join_sponsor_share_success label:@"微信朋友圈"];
        }else if(channel == ShareChannelWeChatTimeline){
            [MobClickUtils event:umeng_event_court_join_sponsor_share_success label:@"微信好友"];
        } else if (channel == ShareChannelSina) {
            [MobClickUtils event:umeng_event_court_join_sponsor_share_success label:@"新浪"];
        } else if (channel == ShareChannelQQ) {
            [MobClickUtils event:umeng_event_court_join_sponsor_share_success label:@"QQ"];
            
        }
    }
}

@end