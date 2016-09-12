//
//  UnionPayManager.m
//  Sport
//
//  Created by haodong  on 15/4/24.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "UnionPayManager.h"
#import "UPPayPlugin.h"
#import "UPPaymentControl.h"
#import "PaymentAnimator.h"

@implementation UnionPayManager

+ (BOOL)startPay:(NSString*)tn
            mode:(NSString*)mode
  viewController:(UIViewController*)viewController
        delegate:(id<UPPayPluginDelegate>)delegate
{
    return [UPPayPlugin startPay:tn
                            mode:mode
                  viewController:viewController
                        delegate:delegate];
}


+ (BOOL)startPay:(NSString *)tn
            mode:(NSString *)mode
  viewController:(UIViewController *)viewController {
    return [[UPPaymentControl defaultControl] startPay:tn
                                            fromScheme:UPPAY_PAIED_URL_TYPES
                                                  mode:mode
                                        viewController:viewController];
    
}

+ (void)handleUPPayResultWithUrl:(NSURL *)url {
    __weak __typeof(self) weakSelf = self;
    [[UPPaymentControl defaultControl] handlePaymentResult:url completeBlock:^(NSString *code, NSDictionary *data) {
        //结果code为成功时，先校验签名，校验成功后做后续处理
        if([code isEqualToString:@"success"]) {
            [[PaymentAnimator shareAnimator] sportUPPayResult:STATUS_SUCCESS];
            //判断签名数据是否存在
            if(data == nil){
                //如果没有签名数据，建议商户app后台查询交易结果
                return;
            }
            
            //数据从NSDictionary转换为NSString
            NSData *signData = [NSJSONSerialization dataWithJSONObject:data
                                                               options:0
                                                                 error:nil];
            NSString *sign = [[NSString alloc] initWithData:signData encoding:NSUTF8StringEncoding];
            
            //验签证书同后台验签证书
            //此处的verify，商户需送去商户后台做验签
            if([weakSelf verify:sign]) {
                //支付成功且验签成功，展示支付成功提示
            }
            else {
                //验签失败，交易结果数据被篡改，商户app后台查询交易结果
            }
        }
        else if([code isEqualToString:@"fail"]) {
            //交易失败
            [[PaymentAnimator shareAnimator] sportUPPayResult:@"fail"];
        }
        else if([code isEqualToString:@"cancel"]) {
            //交易取消
            [[PaymentAnimator shareAnimator] sportUPPayResult:@"cancel"];
        }
    }];
}

+ (BOOL)verify:(NSString *) resultStr {
    
    //验签证书同后台验签证书
    //此处的verify，商户需送去商户后台做验签
    return NO;
}

@end
