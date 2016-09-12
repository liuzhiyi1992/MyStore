//
//  PaymentAnimator.h
//  Sport
//
//  Created by lzy on 16/3/18.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PayRequest.h"
#import "PayService.h"

@protocol PaymentAnimatorDelegate <NSObject>

- (void)paymentAnimatorPaySuccess:(NSString *)msg;
- (void)paymentAnimatorPayFail:(NSString *)msg;
- (void)paymentAnimatorHandleWebPayBack;

@end

@interface PaymentAnimator : NSObject <PayServiceDelegate>
+ (PaymentAnimator *)shareAnimator;
- (BOOL)isNeedThirdPay:(double)thirdPartyPayAmount;
- (void)payRequest:(PayRequest *)payRequest sponser:(UIViewController<PaymentAnimatorDelegate> *)sponser;
- (void)sportUPPayResult:(NSString *)status;
@end