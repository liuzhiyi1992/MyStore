//
//  PaymentAnimator.m
//  Sport
//
//  Created by lzy on 16/3/18.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "PaymentAnimator.h"
#import "UserManager.h"
#import "InputPasswordView.h"
#import "BaseConfigManager.h"
#import "WeChatPayManager.h"
#import "SportPopupView.h"
#import "SportProgressView.h"
#import "MembershipCardVerifyPhoneController.h"
#import "NSDictionary+JsonValidValue.h"
#import "AliPayOrder.h"
#import "AliPayManager.h"
#import "WebPayController.h"
#import "UnionPayManager.h"
#import "OrderService.h"
#import "MobClickUtils.h"
#import "OrderManager.h"
#import "Order.h"
#import "PayMethod.h"
#import "UPAPayPlugin.h"
#import <PassKit/PassKit.h>

static PaymentAnimator *_paymentAnimator = nil;

NSString * const KEY_APPLEPAY_DISCOUNT_CURRENCY = @"currency";
NSString * const KEY_APPLEPAY_DISCOUNT_ORDER_AMT = @"order_amt";
NSString * const KEY_APPLEPAY_DISCOUNT_PAY_AMT = @"pay_amt";

@interface PaymentAnimator() <InputPasswordViewDelegate, UIAlertViewDelegate, WebPayControllerrDelegate, UPAPayPluginDelegate>

@property (strong, nonatomic) PayRequest *payRequest;
@property (weak, nonatomic) UIViewController<PaymentAnimatorDelegate> *sponser;

@end

@implementation PaymentAnimator

+ (PaymentAnimator *)shareAnimator {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _paymentAnimator = [[PaymentAnimator alloc] init];
    });
    return _paymentAnimator;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self registerObserver];
    }
    return self;
}

//option
- (void)dealloc {
    [self resignObserver];
}

- (void)registerObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAlipayCallBack:)
                                                 name:NOTIFICATION_ALIPAY_PAY_CALLBACK
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWeChatCallBack:)
                                                 name:NOTIFICATION_NAME_FINISH_WECHAT_PAY
                                               object:nil];
}

- (void)resignObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_ALIPAY_PAY_CALLBACK object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NAME_FINISH_WECHAT_PAY object:nil];
}

//请求支付
- (void)payRequest:(PayRequest *)payRequest sponser:(UIViewController<PaymentAnimatorDelegate> *)sponser{
    
    self.payRequest = payRequest;
    self.sponser = sponser;
    
    if (payRequest.isUsedBalance == YES) {
        //Verify(仅当余额支付)
        if ([[UserManager defaultManager] readCurrentUser].hasPayPassWord) {
            //验证密码
            [InputPasswordView popUpViewWithType:InputPasswordTypeVerify
                                        delegate:self
                                         smsCode:nil];                                                  
        } else {
            //设置密码
            [InputPasswordView popUpViewWithType:InputPasswordTypeSet
                                        delegate:self
                                         smsCode:nil];
        }
    } else {
        [self paymentConnect:payRequest];
    }
}

//链接后台支付
- (void)paymentConnect:(PayRequest *)payRequest {
    //检测是否安装微信(if need)
    if ([payRequest.paymethod.payKey isEqualToString:PAY_METHOD_WEIXIN]
        && ![WeChatPayManager isWXAppInstalled]
        && [self isNeedThirdPay:payRequest.thirdPartyPayAmount]) {
        [SportPopupView popupWithMessage:@"您未安装微信"];
        return;
    }
    
    //会员卡支付(直接向后台请求扣款）
    User *user = [[UserManager defaultManager] readCurrentUser];
    if (payRequest.order.type == OrderTypeMembershipCard) {
        [PayService userCardPay:self
                         userId:user.userId
                        orderId:payRequest.order.orderId
                       password:nil
                     cardNumber:payRequest.order.cardNumber
                       payToken:payRequest.order.payToken];
    } else {
        [SportProgressView showWithStatus:@"正在请求支付" hasMask:YES];
        //动Club支付
        if (payRequest.order.isClubPay == YES) {
            [PayService clubPay:self
                         userId:user.userId
                        orderId:payRequest.order.orderId
                       payToken:payRequest.order.payToken];
            
        } else {
            //支付宝，微信，银联，余额
            [PayService payRequest:self
                            userId:user.userId
                           orderId:payRequest.order.orderId
                             payId:payRequest.paymethod.payId
                         useWallet:payRequest.isUsedBalance
                          password:payRequest.password
                          payToken:payRequest.order.payToken];
        }
    }
    
    //umeng
    [self umentStatisticsWithOrder:payRequest.order payMethod:payRequest.paymethod];
}

- (void)showInputPasswordWithTypeValue:(NSNumber *)typeValue
{
    InputPasswordType type = (InputPasswordType)[typeValue intValue];
    
    [InputPasswordView popUpViewWithType:type
                                delegate:self
                                 smsCode:nil];
}

- (BOOL)isNeedThirdPay:(double)thirdPartyPayAmount {
    //如果计算后的金额0.01, 浮点型表示为0.00999，以下计算会出错
    //if ((int)(payRequest.thirdPartyPayAmount * 100) > 0) {
    if (thirdPartyPayAmount > 0) {
        return YES;
    } else {
        return NO;
    }
}

//umeng
- (void)umentStatisticsWithOrder:(Order *)order payMethod:(PayMethod *)payMethod {
    if (order.type == OrderTypeMembershipCard) {
        [MobClickUtils event:umeng_event_click_pay label:@"会员卡支付"];
    } else if (order.isClubPay) {
        [MobClickUtils event:umeng_event_click_pay label:@"动club支付"];
    } else if ([payMethod.payKey isEqualToString:PAY_METHOD_ALIPAY_CLIENT]) {
        [MobClickUtils event:umeng_event_click_pay label:@"支付宝客户端支付"];
    } else if ([payMethod.payKey isEqualToString:PAY_METHOD_ALIPAY_WAP]) {
        [MobClickUtils event:umeng_event_click_pay label:@"支付宝网页支付"];
    } else if ([payMethod.payKey isEqualToString:PAY_METHOD_WEIXIN]) {
        [MobClickUtils event:umeng_event_click_pay label:@"微信支付"];
    } else if ([payMethod.payKey isEqualToString:PAY_METHOD_UNION_CLIENT]) {
        [MobClickUtils event:umeng_event_click_pay label:@"银联支付"];
    } else if ([payMethod.payKey isEqualToString:PAY_METHOD_APPLE_PAY]) {
        [MobClickUtils event:umeng_event_click_pay label:@"ApplePay"];
    }
}

- (void)paySucceed:(NSString *)msg {
    if ([self.sponser respondsToSelector:@selector(paymentAnimatorPaySuccess:)]) {
        [self.sponser paymentAnimatorPaySuccess:msg];
    }
    [self releaseSponser];
}

- (void)payFail:(NSString *)msg {
    if ([self.sponser respondsToSelector:@selector(paymentAnimatorPayFail:)]) {
        [self.sponser paymentAnimatorPayFail:msg];
    }
    [self releaseSponser];
}

- (void)releaseSponser {
    self.sponser = nil;
    self.payRequest = nil;
}

#pragma mark - Payment
- (void)payWithAlipayClient:(double)payAmount
                    tradeNO:(NSString *)tradeNO
                  notifyURL:(NSString *)notifyURL
{
    AliPayOrder *aliPayOrder = [[AliPayOrder alloc] init] ;
    aliPayOrder.partner = ALIPAY_PARTNER;
    aliPayOrder.seller = ALIPAY_SELLER;
    aliPayOrder.tradeNO =  tradeNO;                         //要唯一
    aliPayOrder.productName = @"趣运动订单";                  //商品标题
    aliPayOrder.productDescription = @"desc";               //商品描述
    aliPayOrder.amount = [NSString stringWithFormat:@"%.2f", payAmount]; //商品价格
    aliPayOrder.notifyURL = notifyURL;        //回调URL
    aliPayOrder.itBPay = @"12m";
    
    [AliPayManager payWithOrder:aliPayOrder
                      appScheme:ALIPAY_CALL_BACK_SCHEME
                  rsaPrivateKey:ALIPAY_RSA_PRIVATE_KEY];
}

- (void)payWithAlipayWap:(NSString *)urlString
{
    HDLog(@"urlString:%@", urlString);
    
    WebPayController *controller = [[WebPayController alloc] initWithUrlString:urlString title:@"支付"] ;
    controller.delegate = self;
    [self.sponser.navigationController pushViewController:controller animated:YES];
}

- (void)handleAlipayCallBack:(NSNotification *)note
{
    HDLog(@"receive message: %@", NOTIFICATION_ALIPAY_PAY_CALLBACK);
    NSDictionary *userInfo = note.userInfo;
    NSString *resultCode = [userInfo objectForKey:@"result_code"];
    NSString *resultMessage = [userInfo objectForKey:@"result_message"];
    
    NSInteger resultCodeInt = [resultCode integerValue];
    
    if (resultCodeInt == 9000) {
        [self paySucceed:@"正在刷新订单"];
    }else{
        
        if (resultCodeInt == 6001) { //取消支付
            [MobClickUtils event:umeng_event_pay_cancel label:@"支付宝客户端支付"];
        } else {
            [MobClickUtils event:umeng_event_pay_failure label:@"支付宝客户端支付"];
        }
        
        [self payFail:[NSString stringWithFormat:@"支付失败:%@", resultMessage]];
    }
}

- (void)handleWeChatCallBack:(NSNotification *)note
{
    HDLog(@"handleWeChatCallBack");
    NSDictionary *userInfo = note.userInfo;
    int errorCode = [[userInfo valueForKey:@"error_code"] intValue];
    NSString *errorMessage = [userInfo valueForKey:@"error_message"];
    
    if (errorCode == 0) {
        [self paySucceed:@"正在刷新订单"];
    } else {
        if (errorMessage) {
            [self payFail:[NSString stringWithFormat:@"%@", errorMessage]];
        } else {
            if (errorCode == -2) {
                [MobClickUtils event:umeng_event_pay_cancel label:@"微信支付"];
                [self payFail:@"取消支付"];
            } else {
                [MobClickUtils event:umeng_event_pay_failure label:@"微信支付"];
                [self payFail:@"支付失败"];
            }
        }
    }
}

#pragma mark - Delegate
- (void)didFinishSetPayPassword:(NSString *)payPassword status:(NSString *)status {
    if ([status isEqualToString:STATUS_SUCCESS]) {
        self.payRequest.password = payPassword;
        [self paymentConnect:self.payRequest];
    } else {
        [SportPopupView popupWithMessage:@"系统错误,请稍后再试"];
    }
}

#define TAG_PAY_PASSWORD_WRONG 20151001
- (id)didFinishVerifyPayPassword:(NSString *)payPassword status:(NSString *)status {
    if ([status isEqualToString:STATUS_SUCCESS]) {
        self.payRequest.password = payPassword;
        [self paymentConnect:self.payRequest];
        return nil;
    } else if([status isEqualToString:STATUS_PAY_PASSWORD_WRONG]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil
                                                           message:@"支付密码错误"
                                                          delegate:self
                                                 cancelButtonTitle:@"返回"
                                                 otherButtonTitles:@"重试",@"忘记密码",nil];
        alertView.tag = TAG_PAY_PASSWORD_WRONG;
        [alertView show];
        return alertView;
    }
    return nil;
}

- (void)didUserCardPay:(NSString *)status msg:(NSString *)msg {
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [self paySucceed:@"正在刷新订单"];
    } else {
        [self payFail:@"会员卡支付失败"];
    }
}

- (void)didClubPay:(NSString *)status msg:(NSString *)msg {
    if ([status isEqualToString:STATUS_MONTH_CARD_PAY_SUCCESS]) {
        [self paySucceed:@"正在刷新订单"];
    } else {
        [self payFail:@"动club支付失败"];
    }
}

- (void)sportUPPayResult:(NSString *)status {
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [self paySucceed:@"正在刷新订单"];
    } else {
        [self payFail:@"银联支付失败"];
    }
}

- (void)didPayRequest:(NSDictionary *)data status:(NSString *)status msg:(NSString *)msg {
    if ([status isEqualToString:STATUS_SUCCESS]) {
        //支付宝客户端
        if ([self.payRequest.paymethod.payKey isEqualToString:PAY_METHOD_ALIPAY_CLIENT]) {
            [SportProgressView dismiss];
            NSString *paySn = [data validStringValueForKey:@"pay_sn"];
            NSString *notifyUrl = [data validStringValueForKey:@"notify_url"];
            float money = [data validFloatValueForKey:@"money"];
            
            self.payRequest.order.amount = money;
            self.payRequest.order.alipayNotifyUrlString = notifyUrl;
            
            [self payWithAlipayClient:money tradeNO:paySn notifyURL:notifyUrl];
        //支付宝网页
        } else if ([self.payRequest.paymethod.payKey isEqualToString:PAY_METHOD_ALIPAY_WAP]) {
            [SportProgressView dismiss];
            NSString *redirectUrl = [data validStringValueForKey:@"redirect_url"];
            [self payWithAlipayWap:redirectUrl];
        //微信
        } else if ([self.payRequest.paymethod.payKey isEqualToString:PAY_METHOD_WEIXIN]) {
            [SportProgressView dismiss];
            NSString *openId        = [data validStringValueForKey:@"appid"];
            NSString *partnerId     = [data validStringValueForKey:@"partnerid"];
            NSString *prepayId      = [data validStringValueForKey:@"prepayid"];
            NSString *nonceStr      = [data validStringValueForKey:@"noncestr"];
            NSString *timeStamp     = [data validStringValueForKey:@"timestamp"];
            NSString *package       = [data validStringValueForKey:@"weixinpackage"];
            NSString *sign          = [data validStringValueForKey:@"sign"];
            [WeChatPayManager payWithOpenID:openId
                                  partnerId:partnerId
                                   prepayId:prepayId
                                   nonceStr:nonceStr
                                  timeStamp:timeStamp
                                    package:package
                                       sign:sign];
        //银联
        }  else if ([self.payRequest.paymethod.payKey isEqualToString:PAY_METHOD_UNION_CLIENT]) {
            NSString *tn = [data validStringValueForKey:@"tn"];
            NSString *mode = [data validStringValueForKey:@"mode"];
            
            BOOL result = [UnionPayManager startPay:tn mode:mode viewController:(UIViewController *)self];
            if (result == NO) {
                [SportProgressView dismissWithError:@"调用银联失败"];
            } else {
                [SportProgressView dismiss];
            }
        } else if ([self.payRequest.paymethod.payKey isEqualToString:PAY_METHOD_APPLE_PAY]) {
            [SportProgressView dismiss];
            NSString *tn = [data validStringValueForKey:@"tn"];
            NSString *mode = [data validStringValueForKey:@"mode"];
            [self payWithApplePayWithTn:tn mode:mode];
        }
    //余额支付 / 之前支付过
    } else if ([status isEqualToString:STATUS_BALANCE_PAY_SUCCESS]
               || [status isEqualToString:STATUS_HAVE_BEEN_PAID_BEFORE]) {
        [self paySucceed:msg];
    //支付失败
    } else {
        [self payFail:msg];
    }
}

- (void)payWithApplePayWithTn:(NSString *)tn mode:(NSString *)mode {
    if (tn.length > 0 && [self verifyApplePayCapacity]) {
        BOOL result = [UPAPayPlugin startPay:tn mode:mode viewController:self.sponser delegate:self andAPMechantID:AppleMechantId];
        if (!result) {
           [SportPopupView popupWithMessage:@"支付调用失败"];
        }
    }
}

- (BOOL)verifyApplePayCapacity {
    NSString *msg;
    BOOL canPay = false;
    if (![PKPaymentAuthorizationViewController class]) {
        msg = @"ApplyPay最低支持iOS9.2";
    } else if (![PKPaymentAuthorizationViewController canMakePayments]) {
        msg = @"ApplyPay权限被关闭";
    } else {
        NSArray *supportedNetwork = @[PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkChinaUnionPay, PKPaymentNetworkAmex, PKPaymentNetworkDiscover];
        if (![PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:supportedNetwork]) {
//            PKMerchantCapability merchantCapabilities = PKMerchantCapabilityDebit;//借记卡  PKMerchantCapabilityCredit//信用卡
            msg = @"没有绑定支付卡片";
        } else {
            canPay = true;
        }
    }
    if (msg.length > 0) {
        [SportPopupView popupWithMessage:msg];
    }
    return canPay;
}

//applePay 回调
- (void)UPAPayPluginResult:(UPPayResult *)payResult {
    NSString *msg;
    
    switch (payResult.paymentResultStatus) {
        case UPPaymentResultStatusSuccess:
            //成功
            msg = @"支付成功";
            if (payResult.otherInfo.length > 0) {//包含优惠信息
                msg = @"支付成功，包含支付优惠信息";
                //格式:"currency=元&order_amt=20.00&pay_amt=15.00“
                //弃用
                //[self showDiscountWithOtherInfo:payResult.otherInfo];
            }
            [self paySucceed:msg];
            break;
        case UPPaymentResultStatusFailure:
            msg = payResult.errorDescription;
            [self payFail:msg];
            break;
        case UPPaymentResultStatusCancel:
            msg = @"支付取消";
            [self payFail:msg];
            break;
        case UPPaymentResultStatusUnknownCancel:
            msg = @"支付出错，请刷新订单再试";
            [self payFail:msg];
            break;
    }
}

- (NSDictionary *)analysisApplePayDiscount:(NSString *)infoString {
    NSMutableDictionary *discountDict = [NSMutableDictionary dictionary];
    NSArray *discountArray = [infoString componentsSeparatedByString:@"&"];
    for (NSString *item in discountArray) {
        NSArray *keyValueArray = [item componentsSeparatedByString:@"="];
        if (2 == keyValueArray.count) {
            [discountDict setObject:keyValueArray.lastObject forKey:keyValueArray.firstObject];
        }
    }
    return discountDict;
}

//- (void)showDiscountWithOtherInfo:(NSString *)otherInfo {
//    NSDictionary *discountDict = [self analysisApplePayDiscount:otherInfo];
//    NSString *currency = discountDict[KEY_APPLEPAY_DISCOUNT_CURRENCY];
//    CGFloat orderAmt = [discountDict validFloatValueForKey:KEY_APPLEPAY_DISCOUNT_ORDER_AMT];
//    CGFloat payAmt = [discountDict validFloatValueForKey:KEY_APPLEPAY_DISCOUNT_PAY_AMT];
//    CGFloat discount = orderAmt - payAmt;
    
//    NSString *discountMsg = [NSString stringWithFormat:@"本次交易银联云闪付优惠%.2f%@,实收%.2f%@", discount, currency, payAmt, currency];
//    UIAlertView *discountAlert = [[UIAlertView alloc] initWithTitle:@"云闪付优惠" message:discountMsg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//    [discountAlert show];
//}

//欺骗银联SDK
- (UIView *)view {
    return [self.sponser view];
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    [self.sponser presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (void)didClickWebPayControllerBackButton:(BOOL)isFinishPay {
    if (YES == isFinishPay) {
        [self paySucceed:@"正在刷新订单"];
    } else {
        //不确保是真正失败
        [self.sponser paymentAnimatorHandleWebPayBack];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == TAG_PAY_PASSWORD_WRONG) {
        if (buttonIndex == 1) {
            [self performSelector:@selector(showInputPasswordWithTypeValue:) withObject:@(InputPasswordTypeVerify) afterDelay:0.2];
        }
        else if(buttonIndex == 2) {
            
            MembershipCardVerifyPhoneController *controller =[[MembershipCardVerifyPhoneController alloc]initWithType:VerifyPhoneTypeForgotPayPassword];
            
            [self.sponser.navigationController pushViewController:controller animated:YES];
            [self releaseSponser];
        }
    }
}
@end
