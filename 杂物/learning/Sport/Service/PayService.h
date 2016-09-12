//
//  PayService.h
//  Sport
//
//  Created by haodong  on 15/4/23.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SportNetworkContent.h"

typedef enum{
    PayIdWeixin         = 10,
    PayIdUnionPay       = 11,
    PayIdAlipayClient   = 12,
    PayIdAlipayWap      = 13,
    PayIdMember         = 14,
    PayIdClub           = 17,
} PayId;

@protocol PayServiceDelegate <NSObject>
@optional
- (void)didPayRequest:(NSDictionary *)data
               status:(NSString *)status
                  msg:(NSString *)msg;

- (void)didUserCardPay:(NSString *)status
                   msg:(NSString *)msg;

- (void)didClubPay:(NSString *)status msg:(NSString *)msg;

@end


@interface PayService : NSObject

//支付请求
+ (void)payRequest:(id<PayServiceDelegate>)delegate
            userId:(NSString *)userId
           orderId:(NSString *)orderId
             payId:(NSString *)payId
         useWallet:(BOOL)useWallet
          password:(NSString *)password
          payToken:(NSString *)payToken;

//会员卡支付
+ (void)userCardPay:(id<PayServiceDelegate>)delegate
             userId:(NSString *)userId
            orderId:(NSString *)orderId
           password:(NSString *)password
         cardNumber:(NSString *)cardNumber
           payToken:(NSString *)payToken;

//动Club支付
+ (void)clubPay:(id<PayServiceDelegate>)delegate
         userId:(NSString *)userId
        orderId:(NSString *)orderId
       payToken:(NSString *)payToken;

@end
