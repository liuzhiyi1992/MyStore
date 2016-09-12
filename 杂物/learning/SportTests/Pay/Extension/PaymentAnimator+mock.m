//
//  PaymentAnimator+mock.m
//  Sport
//
//  Created by lzy on 16/4/27.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "PaymentAnimator+mock.h"
#import <OCMock/OCMock.h>

@implementation PaymentAnimator (mock)

static PaymentAnimator *_mockPaymentAnimator = nil;
static PaymentAnimator *_paymentAnimator = nil;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
+ (PaymentAnimator *)shareAnimator {
    if (_mockPaymentAnimator) {
        return _mockPaymentAnimator;
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _paymentAnimator = [[PaymentAnimator alloc] init];
    });
    return _paymentAnimator;
}
#pragma clang diagnostic pop

+ (void)createMock {
    _mockPaymentAnimator = OCMClassMock([PaymentAnimator class]);
}

+ (void)releaseMock {
    _mockPaymentAnimator = nil;
}

@end
