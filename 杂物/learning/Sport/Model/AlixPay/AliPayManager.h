//
//  AliPayManager.h
//  Sport
//
//  Created by haodong  on 13-9-3.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AliPayOrder.h"

#define NOTIFICATION_ALIPAY_PAY_CALLBACK        @"NOTIFICATION_ALIPAY_PAY_CALLBACK"


@interface AliPayManager : NSObject

///*支付时调用
// *AlixPayOrder: 商品信息
// *appScheme: 在xxx-Info.plist定义URL types,用于安全支付成功后重新唤起商户应用
// *rsaPrivateKey: 商户私钥
// */
//+ (void)payWithOrder:(AlixPayOrder *)order
//           appScheme:(NSString *)appScheme
//       rsaPrivateKey:(NSString *)rsaPrivateKey;
//
///*从支付宝的<快捷支付>返回商户的应用时调用
// *在Appdelegate的application:handleOpenURL:中调用
// *alipayPublicKey:支付宝公钥
// */
//+ (BOOL)parseURL:(NSURL *)url
// alipayPublicKey:(NSString *)alipayPublicKey;


/*2014-06-12集成新的SDK
 *支付时调用
 *AlixPayOrder: 商品信息
 *appScheme: 在xxx-Info.plist定义URL types,用于安全支付成功后重新唤起商户应用
 *rsaPrivateKey: 商户私钥
 *seletor:
 *target:
 */
+ (void)payWithOrder:(AliPayOrder *)order
           appScheme:(NSString *)appScheme
       rsaPrivateKey:(NSString *)rsaPrivateKey;

+ (void)parseURL:(NSURL *)url;

//+ (void)checkResult:(AliPayResult *)result;

@end