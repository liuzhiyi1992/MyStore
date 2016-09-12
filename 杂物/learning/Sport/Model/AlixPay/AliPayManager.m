//
//  AliPayManager.m
//  Sport
//
//  Created by haodong  on 13-9-3.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "AliPayManager.h"
#import <AlipaySDK/AlipaySDK.h>

#import "DataSigner.h"
#import "DataVerifier.h"
//#import "JSON.h"
#import "NSString+Utils.h"
#import "XQueryComponents.h"


@interface AliPayManager()
@end

@implementation AliPayManager

/*
 9000 订单支付成功
 8000 正在处理中
 4000 订单支付失败
 6001 用户中途取消
 6002 网络连接出错
 */

+ (void)payWithOrder:(AliPayOrder *)order
           appScheme:(NSString *)appScheme
       rsaPrivateKey:(NSString *)rsaPrivateKey
{
    NSString* orderInfo = [order description];
    
    id<DataSigner> signer;
    signer = CreateRSADataSigner(rsaPrivateKey);
    NSString *signedStr = [signer signString:orderInfo];
    
    NSString *orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                             orderInfo, signedStr, @"RSA"];

    [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        HDLog(@"<payWithOrder> reslut = %@",resultDic);
        [self postResultNotification:resultDic];
    }];
}

+ (void)parseURL:(NSURL *)url
{
    
//    AliPayResult * result = nil;
//	
//	if (url != nil && [[url host] compare:@"safepay"] == 0) {
//        NSString * query = [[url query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        result = [[[AliPayResult alloc] initWithString:query] autorelease];
//	}
//    [self checkResult:result];

    [[AlipaySDK defaultService]
     processOrderWithPaymentResult:url
     standbyCallback:^(NSDictionary *resultDic) {
         HDLog(@"<parseURL> parseURL: result = %@", resultDic);
         [self postResultNotification:resultDic];
     }];
}

+ (void)postResultNotification:(NSDictionary *)resultDic
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    int resultStatus = [[resultDic valueForKey:@"resultStatus"] intValue];
    
    [dic setValue:[NSString stringWithFormat:@"%d", resultStatus] forKey:@"result_code"];
    
    NSString *message = nil;
    switch (resultStatus) {
        case 9000:
            message = @"订单支付成功";
            break;
            
        case 8000:
            message = @"正在处理中";
            break;
            
        case 4000:
            message = @"订单支付失败";
            break;
            
        case 6001:
            message = @"用户中途取消";
            break;
            
        case 6002:
            message = @"网络连接出错";
            break;
            
        default:
            message = @"支付异常";
            break;
    }
    
    [dic setValue:message forKey:@"result_message"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ALIPAY_PAY_CALLBACK
                                                        object:self
                                                      userInfo:dic];
}

//+ (void)checkResult:(AliPayResult *)result
//{
//    if (result)
//    {
//		if (result.statusCode == 9000)
//        {
//			/*
//			 *用公钥验证签名 严格验证请使用result.resultString与result.signString验签
//			 */
//            //交易成功
//            id<DataVerifier> verifier;
//            verifier = CreateRSADataVerifier(ALIPAY_ALIPAY_PUBLIC_KEY);
//            if ([verifier verifyString:result.resultString withSign:result.signString])
//            {
//                //验证签名成功，交易结果无篡改
//                HDLog(@"--<%s>--: pay success, verifier success", __FUNCTION__);
//            }
//            else
//            {
//                HDLog(@"--<%s>--: signature error", __FUNCTION__);
//            }
//        }
//        else
//        {
//            //交易失败
//            HDLog(@"--<%s>--: pay error code: %d", __FUNCTION__, result.statusCode);
//        }
//    }
//    else
//    {
//        //失败
//        HDLog(@"--<%s>--: pay result is nil", __FUNCTION__);
//    }
//    
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    [dic setValue:result forKey:@"result"];
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ALIPAY_PAY_CALLBACK
//                                                        object:self
//                                                      userInfo:dic];
//}

@end
