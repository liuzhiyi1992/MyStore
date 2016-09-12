//
//  PaymentAnimator.m
//  Sport
//
//  Created by lzy on 16/4/25.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCHamcrest/OCHamcrest.h>
#import <OCMock/OCMock.h>
#import <objc/NSObjCRuntime.h>

#import "PayController+Test.h"
#import "PaymentAnimator+Test.h"

#import "UserService.h"
#import "UserManager.h"
#import "PayService.h"
#import "MembershipCardVerifyPhoneController.h"
#import "SportProgressView.h"
#import "TestingAppDelegate.h"

static NSString * const TestOrderId = @"1234";

@interface PaymentAnimatorTest : XCTestCase

@end

@implementation PaymentAnimatorTest
{
    PayController *_sutPayController;
    PayRequest *_payRequest;
    Order *_order;
    PaymentAnimator<PayServiceDelegate> *_paymentAnimator;
    UIWindow *_keyWindow;
}

+ (void)setUp {
}

- (void)setUp {
    [super setUp];
    
    _order = [[Order alloc] init];
    _order.type = OrderTypeDefault;
    _order.orderId = TestOrderId;
    
    _sutPayController = OCMClassMock([PayController class]);
    User *user = [[User alloc]init];
    user.userId = @"3358";
    user.hasPayPassWord = YES;
    [[UserManager defaultManager] saveCurrentUser:user];
    _payRequest = [PayRequest requestWithOrder:_order payMethod:nil password:nil thirdPartyPayAmount:0.0f isUsedBalance:YES];
    
    _paymentAnimator = [PaymentAnimator shareAnimator];
    
    _keyWindow = [[UIApplication sharedApplication] keyWindow];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    _sutPayController = nil;
    
    [[UserManager defaultManager] saveCurrentUser:nil];
    InputPasswordView<UserServiceDelegate> *inputPassWordView = (InputPasswordView *)[self containViewWithFather:_keyWindow sonClass:[InputPasswordView class]];
    if (inputPassWordView != nil) {
        [inputPassWordView removeFromSuperview];
    }

}

- (void)testInputPasswordViewPresentAndDismiss {
    //调起支付
    [_paymentAnimator payRequest:_payRequest sponser:_sutPayController];
    
    //验证密码框出现
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    InputPasswordView<UserServiceDelegate> *inputPassWordView = (InputPasswordView *)[self containViewWithFather:keyWindow sonClass:[InputPasswordView class]];
    InputPasswordType inputType = [[inputPassWordView valueForKey:@"inputType"] intValue];
    assertThatInt(inputType, equalToInt(InputPasswordTypeVerify));
    assertThat(inputPassWordView, notNilValue());
    
    //密码验证通过
    [inputPassWordView didVerifyPayPassword:STATUS_SUCCESS msg:nil payPassword:nil];
    inputPassWordView = (InputPasswordView *)[self containViewWithFather:keyWindow sonClass:[InputPasswordView class]];
    assertThat(inputPassWordView, nilValue());
}

- (void)testInputPasswordViewSetPassword {
    [[UserManager defaultManager].readCurrentUser setHasPayPassWord:NO];
    //调起支付
    [_paymentAnimator payRequest:_payRequest sponser:_sutPayController];
    //验证密码框出现
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    InputPasswordView<UserServiceDelegate> *inputPassWordView = (InputPasswordView *)[self containViewWithFather:keyWindow sonClass:[InputPasswordView class]];
    InputPasswordType inputType = [[inputPassWordView valueForKey:@"inputType"] intValue];
    assertThatInt(inputType, equalToInt(InputPasswordTypeSet));
    assertThat(inputPassWordView, notNilValue());
    //设置密码
    [inputPassWordView didSetPayPassword:STATUS_SUCCESS msg:nil];
    inputPassWordView = (InputPasswordView *)[self containViewWithFather:keyWindow sonClass:[InputPasswordView class]];
    assertThat(inputPassWordView, nilValue());
}

- (void)testPasswordWrongAndInputAgain {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    _payRequest = [PayRequest requestWithOrder:_order payMethod:[[PayMethod alloc] init]  password:nil thirdPartyPayAmount:0 isUsedBalance:YES];
    
    //调起支付
    [_paymentAnimator payRequest:_payRequest sponser:_sutPayController];
    
    //存在InputPasswordView
    InputPasswordView<UserServiceDelegate> *inputPassWordView = (InputPasswordView *)[self containViewWithFather:keyWindow sonClass:[InputPasswordView class]];
    assertThat(inputPassWordView, notNilValue());
    [inputPassWordView removeFromSuperview];
    
    //输入密码错误
    UIAlertView *alertView = (UIAlertView *)[_paymentAnimator didFinishVerifyPayPassword:nil status:STATUS_PAY_PASSWORD_WRONG];
    
    //不存在InputPasswordView
    inputPassWordView = (InputPasswordView *)[self containViewWithFather:keyWindow sonClass:[InputPasswordView class]];
    assertThat(inputPassWordView, nilValue());
    
    //选择重试
    [alertView dismissWithClickedButtonIndex:1 animated:NO];
    
    XCTestExpectation *existInputPassWordViewExpectation = [self expectationWithDescription:@"existInputPassWordViewExpectation"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (true) {
            [NSThread sleepForTimeInterval:0.5f];
            if ([self containViewWithFather:keyWindow sonClass:[InputPasswordView class]] != nil) {
                [existInputPassWordViewExpectation fulfill];
                break;
            }
        }
    });
    
    [self waitForExpectationsWithTimeout:5.0f handler:^(NSError * _Nullable error) {
        if (error) {
            HDLog(@"\n%@", error);
        }
    }];
    
}

- (void)testPasswordPay {

    [_paymentAnimator setValue:_sutPayController forKey:@"sponser"];
    //强制成功
    [_paymentAnimator didPayRequest:nil status:STATUS_BALANCE_PAY_SUCCESS msg:nil];
    
    OCMVerify([_sutPayController paymentAnimatorPaySuccess:nil]);
}

- (void)testMembershipCardPaySucess {

    [_paymentAnimator setValue:_sutPayController forKey:@"sponser"];
    
    //强制成功
    [_paymentAnimator didUserCardPay:STATUS_SUCCESS msg:nil];
    
    OCMVerify([_sutPayController paymentAnimatorPaySuccess:@"正在刷新订单"]);
}

- (void)testMembershipCardPayFailed {
    id progressMock = OCMClassMock([SportProgressView class]);
    [_paymentAnimator setValue:_sutPayController forKey:@"sponser"];
    
    //强制失败
    [_paymentAnimator didUserCardPay:@"-1" msg:@"交易失败"];

//    OCMVerify([progressMock dismissWithError:@"交易失败"]);
    OCMVerify([_sutPayController paymentAnimatorPayFail:@"会员卡支付失败"]);
}

//- (void)testApplePayDiscount {
//    UPPayResult *result = [[UPPayResult alloc] init];
//    result.otherInfo = @"currency=元&order_amt=20.00&pay_amt=15.00";
//    [_paymentAnimator UPAPayPluginResult:result];
//    UIView *currentKeyWindow = [UIApplication sharedApplication].keyWindow;
//    //todo 临时test，UI设计弹窗后需验证折扣内容
//    assertThatBool([currentKeyWindow isMemberOfClass:[UIWindow class]], isFalse());
//}

#pragma mark - func
- (UIView *)containViewWithFather:(UIView *)father sonClass:(Class)sonClass {
    for (UIView *view in father.subviews) {
        if ([view isKindOfClass:sonClass]) {
            return view;
        }
    }
    return nil;
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
