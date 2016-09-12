//
//  WeChatPayManager.h
//  Sport
//
//  Created by haodong  on 14-7-3.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeChatPayManager : NSObject

+ (WeChatPayManager *)defaultManager;

/*
+ (NSString *)genPackageWithOrderNumber:(NSString *)orderNumber
                            orderAmount:(double)orderAmount
                              orderDesc:(NSString *)orderDesc
                              notifyUrl:(NSString *)notifyUrl;
+ (NSString *)genSign:(NSDictionary *)signParams;
+ (void)pay:(NSString *)prepayId timeStamp:(NSString *)timeStamp nonceStr:(NSString *)nonceStr;

 
- (void)payWithOrderNumber:(NSString *)orderNumber
               orderAmount:(double)orderAmount
                 orderDesc:(NSString *)orderDesc
                 notifyUrl:(NSString *)notifyUrl;
 */

+ (BOOL)isWXAppInstalled;

+ (void)payWithOpenID:(NSString *)openID
            partnerId:(NSString *)partnerId
             prepayId:(NSString *)prepayId
             nonceStr:(NSString *)nonceStr
            timeStamp:(NSString *)timeStamp
              package:(NSString *)package
                 sign:(NSString *)sign;

@end
