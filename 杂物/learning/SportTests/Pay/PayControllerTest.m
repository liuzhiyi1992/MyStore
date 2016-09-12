//
//  PayControllerTest.m
//  Sport
//
//  Created by lzy on 16/4/15.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCHamcrest/OCHamcrest.h>
#import <OCMock/OCMock.h>

#import <OCMock/OCMock.h>
#import "PayController+Test.h"
#import "PaymentAnimator+mock.h"
#import "ShortTipsView.h"
#import "ShareFieldWillingSurveyView+Test.h"
#import "UserManager+mock.h"
#import "TestingAppDelegate.h"

@interface PayControllerTest : XCTestCase
@property (strong, nonatomic) ShareFieldWillingSurveyView *surveyView;
@end

@implementation PayControllerTest
{
    PayController *_sut;
}

+ (void)setUp {
    [super setUp];
}

- (void)setUp {
    [super setUp];
    _sut = [[PayController alloc] init];
    [PaymentAnimator createMock];
    
}

-(void)tearDown {
    [super tearDown];
    [self.surveyView removeFromSuperview];
    _sut = nil;
    [PaymentAnimator releaseMock];
}

#pragma makr - ShareFieldWillingSurveyView
- (void)testShareFieldWillingSurveyViewExist {
    self.surveyView = [self showAndCreateShareFieldWillingSurveyView];
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    
    BOOL containFlag = [self containViewWithFather:keyWindow son:_surveyView];
    assertThatBool(containFlag, isTrue());
}

//该功能已经废弃
//- (void)testShareFieldWillingSurveyViewRespondAndDismiss {
//    ShareFieldWillingSurveyView *surveyView = [self showAndCreateShareFieldWillingSurveyView];
//    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
//    UIButton *refuseButtonl;
//    for (UIButton *button in surveyView.itemButtons) {
//        if (button.tag == 15) {
//            refuseButtonl = button;
//            break;
//        }
//    }
//    assertThat(refuseButtonl, notNilValue());
//    assertThat([refuseButtonl actionsForTarget:surveyView
//                               forControlEvent:UIControlEventTouchUpInside],
//               contains(@"clickCountButton:", nil));
//    
//    [surveyView clickCountButton:refuseButtonl];
//    
//    
//    XCTestExpectation *expectation = [self expectationWithDescription:@"receiveNetwork"];
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        while (true) {
//            [NSThread sleepForTimeInterval:0.5f];
//            if ( ! [self containViewWithFather:keyWindow son:surveyView]) {
//                [expectation fulfill];
//                break;
//            }
//        }
//    });
//
//    [self waitForExpectationsWithTimeout:3.0f handler:^(NSError * _Nullable error) {
//        if (error) {
//            HDLog(@"\n%@", error);
//        }
//    }];
//}
//
//- (void)testShareFieldWillingSurveyViewCancelButtonRespond {
//    ShareFieldWillingSurveyView *surveyView = [self showAndCreateShareFieldWillingSurveyView];
//    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
//
//    UIButton *cancelButton = surveyView.cancelButton;
//    assertThat(cancelButton, notNilValue());
//    assertThat([cancelButton actionsForTarget:surveyView
//                               forControlEvent:UIControlEventTouchUpInside],
//               contains(@"clickCancelButton:", nil));
//    
//    [surveyView performSelector:@selector(clickCancelButton:) withObject:nil];
//    XCTestExpectation *cancelButtonExpectation = [self expectationWithDescription:@"cancelButtonExpectation"];
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        while (true) {
//            [NSThread sleepForTimeInterval:0.5f];
//            if ( ! [self containViewWithFather:keyWindow son:surveyView]) {
//                [cancelButtonExpectation fulfill];
//                break;
//            }
//        }
//    });
//    
//    [self waitForExpectationsWithTimeout:3.0f handler:^(NSError * _Nullable error) {
//        if (error) {
//            HDLog(@"\n%@", error);
//        }
//    }];
//}

- (void)testShowShortTips{
    // 测试后台有显示tips的指令时，有没有存在这个tips的视图
    ShortTipsView *surveyView = [self showAndCreateShortTipsView];
    XCTAssertNotNil(surveyView,@"view应该非空");
    //验证showTips行为
    NSString *tip = @"为感谢支持，活动期间保险免费送";
    PayController *payController = OCMClassMock([PayController class]);
    [payController showShortTipsView:tip];
    OCMVerify([payController showShortTipsView:tip]);
    //验证showTips调用次数
    PayController *payControllerTwo = OCMClassMock([PayController class]);
    [payControllerTwo showShortTipsView:tip];
    OCMVerify([payControllerTwo showShortTipsView:tip]);
}


#pragma mark - payRequest
- (void)testPayRequestBalancePay {
    [PaymentAnimator createMock];
    
    Order *order = [[Order alloc] init];
    order.type = OrderTypeDefault;
    
    PayController *payController = [[PayController alloc] init];
    PayRequest *payRequest = [PayRequest requestWithOrder:order payMethod:nil password:nil thirdPartyPayAmount:0.0f isUsedBalance:YES];
    [payController payRequest:payRequest];
    
    OCMVerify([[PaymentAnimator shareAnimator] payRequest:payRequest sponser:payController]);
}




#pragma mark - func
- (BOOL)containViewWithFather:(UIView *)father son:(UIView *)son {
    for (UIView *view in father.subviews) {
        if (view == son) {
            return YES;
        }
    }
    return NO;
}

- (ShareFieldWillingSurveyView *)showAndCreateShareFieldWillingSurveyView {
//    NSString *currentOrderId = @"1830";
    ShareFieldWillingSurveyView *surveyView = [ShareFieldWillingSurveyView showWithOrderId:nil];
    return surveyView;
}
- (ShortTipsView *)showAndCreateShortTipsView{
    ShortTipsView *surveyView = [ShortTipsView creatShortTipsView];
    return surveyView;
}

-(void) testqueryOrderData {
    id OrderServiceMock = OCMClassMock([OrderService class]);
    Order *order = [[Order alloc]init];
    order.orderId = @"123";
    [_sut setValue:order forKey:@"order"];
    [UserManager createMock];
    User *user = [[User alloc]init];
    user.userId = @"3518";
    UserManager *manager = [UserManager defaultManager];
    OCMStub([manager readCurrentUser]).andReturn(user);

    [_sut performSelector:@selector(queryOrderData) withObject:nil];
    OCMVerify([OrderServiceMock queryOrderDetail:_sut
                                         orderId:@"123"
                                          userId:@"3518"
                                         isShare:@"1"
                                        entrance:0]);
    [UserManager releaseMock];
}

-(void) testDidQueryOrderDetail{
    Order *order = [[Order alloc]init];
    order.orderId = @"456";
    NSString *msg;
    [_sut didQueryOrderDetail:STATUS_SUCCESS msg:msg resultOrder:order];
    
    assertThat([_sut valueForKey:@"order"], equalTo(order));
    assertThat([_sut valueForKey:@"countDownTimer"], notNilValue());
    
}

@end
