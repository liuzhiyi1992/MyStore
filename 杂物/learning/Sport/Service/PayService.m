//
//  PayService.m
//  Sport
//
//  Created by haodong  on 15/4/23.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "PayService.h"
#import "DesUtil.h"
#import "GSNetwork.h"

@implementation PayService

+ (void)payRequest:(id<PayServiceDelegate>)delegate
            userId:(NSString *)userId
           orderId:(NSString *)orderId
             payId:(NSString *)payId
         useWallet:(BOOL)useWallet
          password:(NSString *)password
          payToken:(NSString *)payToken
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_PAY_REQUEST forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:orderId forKey:PARA_ORDER_ID];
    [inputDic setValue:payId forKey:PARA_PAY_ID];
    [inputDic setValue:(useWallet ? @"1" : @"0") forKey:PARA_USE_WALLET];
    [inputDic setValue:[DesUtil encryptUseDES:password key:SPORT_DES_KEY iv:SPORT_DES_IV]  forKey:PARA_PASSWORD];
    [inputDic setValue:payToken forKey:PARA_PAY_TOKEN];
    [GSNetwork getWithBasicUrlString:GS_URL_PAY parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
    
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];

        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didPayRequest:status:msg:)]) {
                [delegate didPayRequest:data status:status msg:msg];
            }
        });
    }];
}

+ (void)userCardPay:(id<PayServiceDelegate>)delegate
             userId:(NSString *)userId
            orderId:(NSString *)orderId
           password:(NSString *)password
         cardNumber:(NSString *)cardNumber
           payToken:(NSString *)payToken
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_USER_CARD_PAY forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:orderId forKey:PARA_ORDER_ID];
    [inputDic setValue:[@(PayIdMember) stringValue] forKey:PARA_PAY_ID];
    if (password) {
        [inputDic setValue:[DesUtil encryptUseDES:password key:SPORT_DES_KEY iv:SPORT_DES_IV]  forKey:PARA_PASSWORD];
    }
    [inputDic setValue:cardNumber forKey:PARA_CARD_NO];
    [inputDic setValue:payToken forKey:PARA_PAY_TOKEN];
    
    [GSNetwork getWithBasicUrlString:GS_URL_PAY parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didUserCardPay:msg:)]) {
                [delegate didUserCardPay:status msg:msg];
            }
        });
    }];
}


+ (void)clubPay:(id<PayServiceDelegate>)delegate
         userId:(NSString *)userId
        orderId:(NSString *)orderId
       payToken:(NSString *)payToken
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_PAY_REQUEST forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:orderId forKey:PARA_ORDER_ID];
    [inputDic setValue:[@(PayIdClub) stringValue] forKey:PARA_PAY_ID];
    [inputDic setValue:payToken forKey:PARA_PAY_TOKEN];
    [GSNetwork getWithBasicUrlString:GS_URL_PAY parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didClubPay:msg:)]) {
                [delegate didClubPay:status msg:msg];
            }
        });
    }];
}

@end
