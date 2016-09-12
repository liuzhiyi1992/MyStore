//
//  MembershipCardService.m
//  Sport
//
//  Created by haodong  on 15/4/16.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "MembershipCardService.h"
#import "SportNetwork.h"
#import "MembershipCard.h"
#import "UserService.h"
#import "UserManager.h"
#import "MembershipCardRecord.h"
#import "DesUtil.h"
#import "MembershipCardRechargeGoods.h"
#import "Order.h"
#import "OrderService.h"
#import "GSNetwork.h"

@implementation MembershipCardService

+ (MembershipCard *)parseMembershipCardFromDictionary:(NSDictionary *)dic
{
    MembershipCard *card = [[MembershipCard alloc] init] ;
    card.cardNumber = [dic validStringValueForKey:PARA_CARD_NO];
    card.businessId = [dic validStringValueForKey:PARA_VENUES_ID];
    card.categoryId = [dic validStringValueForKey:PARA_CAT_ID];
    card.businessName = [dic validStringValueForKey:PARA_NAME];
    card.money = [dic validFloatValueForKey:PARA_BALANCE];
    card.phone = [dic validStringValueForKey:PARA_CARD_MOBILE_PHONE];
    card.phoneEncode = [dic validStringValueForKey:PARA_CARD_MOBILE_ENCODE];
    card.status = [dic validIntValueForKey:PARA_CARD_STATUS];
    card.oldPhone = [dic validStringValueForKey:PARA_OWNER_MOBILE];
    card.oldPhoneEncode = [dic validStringValueForKey:PARA_OWNER_MOBILE_ENCODE];
    return card;
}

+ (void)scanCard:(id<MembershipCardServiceDelegate>)delegate
      cardNumber:(NSString *)cardNumber
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_SCAN_CARD forKey:PARA_ACTION];
        [inputDic setValue:cardNumber forKey:PARA_CARD_NO];

        NSDictionary *resultDictionary  = [SportNetwork getJsonWithPrameterDictionary:inputDic urlString:SPORT_URL_DEFAULT_APP_USERCARD];
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        MembershipCard *card = nil;
        NSString *title = nil;
        NSString *content = nil;
        
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        if ([status isEqualToString:STATUS_SUCCESS]) {
            card = [MembershipCardService parseMembershipCardFromDictionary:data];
        } else {
            title = [data validStringValueForKey:PARA_TITLE];
            content = [data validStringValueForKey:PARA_CONTENT];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didScanCard:status:msg:title:content:)]) {
                [delegate didScanCard:card status:status msg:msg title:title content:content];
            }
        });
    });
}

+ (void)scanCardLogined:(id<MembershipCardServiceDelegate>)delegate
             cardNumber:(NSString *)cardNumber
                 userId:(NSString *)userId
                  phone:(NSString *)phone
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_SCAN_CARD_LOGINED forKey:PARA_ACTION];
        [inputDic setValue:cardNumber forKey:PARA_CARD_NO];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        [inputDic setValue:phone forKey:PARA_PHONE];
        
        NSDictionary *resultDictionary  = [SportNetwork getJsonWithPrameterDictionary:inputDic urlString:SPORT_URL_DEFAULT_APP_USERCARD];
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        MembershipCard *card = nil;
        NSString *title = nil;
        NSString *content = nil;
        
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        if ([status isEqualToString:STATUS_SUCCESS]) {
            card = [MembershipCardService parseMembershipCardFromDictionary:data];
        } else {
            title = [data validStringValueForKey:PARA_TITLE];
            content = [data validStringValueForKey:PARA_CONTENT];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didScanCardLogined:status:msg:title:content:)]) {
                [delegate didScanCardLogined:card status:status msg:msg title:title content:content];
            }
        });
    });
}

+ (void)cardLogin:(id<MembershipCardServiceDelegate>)delegate
       cardNumber:(NSString *)cardNumber
            phone:(NSString *)phone
          smsCode:(NSString *)smsCode
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_CARD_LOGIN forKey:PARA_ACTION];
        [inputDic setValue:cardNumber forKey:PARA_CARD_NO];
        [inputDic setValue:phone forKey:PARA_PHONE];
        [inputDic setValue:smsCode forKey:PARA_SMS_CODE];
        
        NSDictionary *resultDictionary  = [SportNetwork getJsonWithPrameterDictionary:inputDic urlString:SPORT_URL_DEFAULT_APP_USERCARD];
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        if ([status isEqualToString:STATUS_SUCCESS]) {
            User *user = [UserService userByDictionary:resultDictionary];
            [[UserManager defaultManager] saveCurrentUser:user];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didCardLogin:msg:)]) {
                [delegate didCardLogin:status msg:msg];
            }
        });
    });
}

+ (void)getCardList:(id<MembershipCardServiceDelegate>)delegate
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_CARD_LIST forKey:PARA_ACTION];
    User *user = [[UserManager defaultManager] readCurrentUser];

    [inputDic setValue:user.userId forKey:PARA_USER_ID];
    [inputDic setValue:user.phoneNumber forKey:PARA_PHONE];
    [inputDic setValue:user.phoneEncode forKey:PARA_PHONE_ENCODE];

    // v2.0
    [inputDic setValue:@"2.1" forKey:PARA_VER];
        
    [GSNetwork getWithBasicUrlString:GS_URL_USERCARD parameters:inputDic responseHandler:^(GSNetworkResponse *response){
        NSDictionary *resultDictionary = response.jsonResult;
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSMutableArray *cardList = [NSMutableArray array];
        
        if ([status isEqualToString:STATUS_SUCCESS]) {
            NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
            NSArray *list = [data validArrayValueForKey:PARA_LIST];
            for (NSDictionary *one in list) {
                MembershipCard *card = [MembershipCardService parseMembershipCardFromDictionary:one];
                //添加会员卡的时候，全部默认为已绑定状态
//                card.status = 1;
                [cardList addObject:card];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didGetCardList:status:msg:)]) {
                [delegate didGetCardList:cardList status:status msg:msg];
            }
        });
    }];
}

+ (void)getCardDetail:(id<MembershipCardServiceDelegate>)delegate
           cardNumber:(NSString *)cardNumber
               userId:(NSString *)userId
                phone:(NSString *)phone
           businessId:(NSString *)businessId
{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_GET_CARD_DETAIL forKey:PARA_ACTION];
        [inputDic setValue:cardNumber forKey:PARA_CARD_NO];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        [inputDic setValue:phone forKey:PARA_PHONE];
        
        // v2.0
        [inputDic setValue:@"2.0" forKey:PARA_VER];
        [inputDic setValue:businessId forKey:PARA_VENUES_ID];
        
        [GSNetwork getWithBasicUrlString:GS_URL_USERCARD parameters:inputDic responseHandler:^(GSNetworkResponse *response){
            NSDictionary *resultDictionary = response.jsonResult;
            NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
            NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
            
            MembershipCard *card = nil;
            
            if ([status isEqualToString:STATUS_SUCCESS]) {
                NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
                card = [MembershipCardService parseMembershipCardFromDictionary:data];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([delegate respondsToSelector:@selector(didGetCardDetail:status:msg:)]) {
                    [delegate didGetCardDetail:card status:status msg:msg];
                }
            });
        }];
}


+ (void)bindCard:(id<MembershipCardServiceDelegate>)delegate
      cardNumber:(NSString *)cardNumber
          userId:(NSString *)userId
           phone:(NSString *)phone
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_CARD_BIND forKey:PARA_ACTION];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        [inputDic setValue:cardNumber forKey:PARA_CARD_NO];
        [inputDic setValue:phone forKey:PARA_PHONE];
        
        NSDictionary *resultDictionary  = [SportNetwork getJsonWithPrameterDictionary:inputDic urlString:SPORT_URL_DEFAULT_APP_USERCARD];
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didBindCard:msg:)]) {
                [delegate didBindCard:status msg:msg];
            }
        });
    });
}

+ (void)unbindCard:(id<MembershipCardServiceDelegate>)delegate
      cardNumber:(NSString *)cardNumber
            userId:(NSString *)userId
       payPassword:(NSString *)payPassword
    isSetPayPassword:(int) isSetPayPassword
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_CARD_UNBIND forKey:PARA_ACTION];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        [inputDic setValue:cardNumber forKey:PARA_CARD_NO];
        [inputDic setValue:[DesUtil encryptUseDES:payPassword key:SPORT_DES_KEY iv:SPORT_DES_IV] forKey:PARA_PAY_PASSWORD];
        [inputDic setValue:[@(isSetPayPassword) stringValue] forKey:PARA_IS_SET_PAY_PASSWORD];
        
        NSDictionary *resultDictionary  = [SportNetwork getJsonWithPrameterDictionary:inputDic urlString:SPORT_URL_DEFAULT_APP_USERCARD];
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didUnbindCard:msg:)]) {
                [delegate didUnbindCard:status msg:msg];
            }
        });
    });
}

+ (void)getCardUseRecordList:(id<MembershipCardServiceDelegate>)delegate
                  cardNumber:(NSString *)cardNumber
                      userId:(NSString *)userId
                        page:(NSUInteger)page
                       count:(NSUInteger)count
                     venueId:(NSString *)venueId
                mobileNumber:(NSString *)mobileNumber
{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_CARD_CONSUME forKey:PARA_ACTION];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        [inputDic setValue:cardNumber forKey:PARA_CARD_NO];
        [inputDic setValue:[@(page) stringValue] forKey:PARA_PAGE];
        [inputDic setValue:[@(count) stringValue] forKey:PARA_COUNT];
        [inputDic setValue:venueId forKey:PARA_VENUE_ID];
        [inputDic setValue:mobileNumber forKey:PARA_MOBILE];
        [inputDic setValue:@"2.0" forKey:PARA_VER];
    
        [GSNetwork getWithBasicUrlString:GS_URL_USERCARD parameters:inputDic responseHandler:^(GSNetworkResponse *response){
            NSDictionary *resultDictionary = response.jsonResult;
            NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
            NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
            NSMutableArray *list = [NSMutableArray array];
            
            if ([status isEqualToString:STATUS_SUCCESS]) {
                NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
                NSArray *dataList = [NSArray array];
                dataList = [data validArrayValueForKey:PARA_LIST];
                for (NSDictionary *one in dataList) {
                    MembershipCardRecord *record = [[MembershipCardRecord alloc] init] ;
                    record.amount = [one validFloatValueForKey:PARA_MONEY];
                    record.desc = [one validStringValueForKey:PARA_DESCRIPTION];
                    record.addTime = [NSDate dateWithTimeIntervalSince1970:[one validIntValueForKey:PARA_ADD_TIME]];
                    record.type = [one validIntValueForKey:PARA_TYPE];
                    [list addObject:record];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([delegate respondsToSelector:@selector(didGetCardUseRecordList:status:msg:)]) {
                    [delegate didGetCardUseRecordList:list status:status msg:msg];
                }
            });
        }];
}

+ (void)getUserCardGoodsList:(id<MembershipCardServiceDelegate>)delegate
                  cardNumber:(NSString *)cardNumber
                      userId:(NSString *)userId
{
    
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_USER_CARD_GOODS_LIST forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:cardNumber forKey:PARA_CARD_NO];
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
       NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        NSMutableArray *rechargeGoodsList = nil;
        if ([status isEqualToString:STATUS_SUCCESS]) {
            rechargeGoodsList = [NSMutableArray array];
            NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
            NSArray *list = [data validArrayValueForKey:PARA_LIST];
            for (NSDictionary *one in list) {
                MembershipCardRechargeGoods *goods = [[MembershipCardRechargeGoods alloc] init] ;
                goods.goodsId = [one validStringValueForKey:PARA_GOODS_ID];
                goods.amount = [one validFloatValueForKey:PARA_AMOUNT];
                goods.giftAmount = [one validFloatValueForKey:PARA_GIFT_AMOUNT];
                goods.message = [one validStringValueForKey:PARA_MSG];
                [rechargeGoodsList addObject:goods];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didGetUserCardGoodsList:status:msg:)]) {
                [delegate didGetUserCardGoodsList:rechargeGoodsList status:status msg:msg];
            }
        });
    }];
}

+ (void)addUserCardOrder:(id<MembershipCardServiceDelegate>)delegate
                  userId:(NSString *)userId
              cardNumber:(NSString *)cardNumber
                 goodsId:(NSString *)goodsId
                  cityId:(NSString *)cityId
               venuesId:(NSString *)venuesId
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_ADD_USER_CARD_ORDER forKey:PARA_ACTION];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        [inputDic setValue:cardNumber forKey:PARA_CARD_NO];
        [inputDic setValue:@"4" forKey:PARA_ORDER_TYPE];
        [inputDic setValue:goodsId forKey:PARA_GOODS_ID];
        [inputDic setValue:cityId forKey:PARA_CITY_ID];
        
        // 1.4 增加venues_id
        [inputDic setValue:@"1.4" forKey:PARA_VER];
        [inputDic setValue:venuesId forKey:PARA_VENUES_ID];
        
        NSDictionary *resultDictionary  = [SportNetwork getJsonWithPrameterDictionary:inputDic urlString:SPORT_URL_DEFAULT_APP_USERCARD];
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        Order *order = nil;
        if ([status isEqualToString:STATUS_SUCCESS]) {
            NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
            order = [OrderService orderByOneOrderDictionary:data];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didAddUserCardOrder:status:msg:)]) {
                [delegate didAddUserCardOrder:order status:status msg:msg];
            }
        });
    });
}

+ (void)applyUserCardRefund:(id<MembershipCardServiceDelegate>)delegate
                     userId:(NSString *)userId
                    orderId:(NSString *)orderId
{
    
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_APPLY_USER_CARD_REFUND forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:orderId forKey:PARA_ORDER_ID];
        
    [GSNetwork getWithBasicUrlString:GS_URL_ORDER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didApplyUserCardRefund:msg:)]) {
                [delegate didApplyUserCardRefund:status msg:msg];
            }
        });
    }];
}

+ (void)confirmUserCardWithUserId:(NSString *)userId
                           cardNo:(NSString *)cardNo
                       businessId:(NSString *)businessId
                      phoneEncode:(NSString *)phoneEncode
                          smsCode:(NSString *)smsCode
                       completion:(void(^)(NSString *status,NSString *msg))completion{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_SET_USERCARD_CONFIRM forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:cardNo forKey:PARA_CARD_NO];
    [inputDic setValue:businessId forKey:PARA_VENUES_ID];
    [inputDic setValue:phoneEncode forKey:PARA_MOBILE];
    [inputDic setValue:smsCode forKey:PARA_SMS_CODE];
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    
    [GSNetwork getWithBasicUrlString:GS_URL_USERCARD parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(status,msg);
            }
        });
    }];
}

+ (void)setUserCardBindWithUserId:(NSString *)userId
                           cardNo:(NSString *)cardNo
                       businessId:(NSString *)businessId
                      phoneEncode:(NSString *)phoneEncode
                          smsCode:(NSString *)smsCode
                       completion:(void(^)(NSString *status,NSString *msg))completion{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_SET_USERCARD_BIND forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:cardNo forKey:PARA_CARD_NO];
    [inputDic setValue:businessId forKey:PARA_VENUES_ID];
    [inputDic setValue:phoneEncode forKey:PARA_MOBILE];
    [inputDic setValue:smsCode forKey:PARA_SMS_CODE];
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    
    [GSNetwork getWithBasicUrlString:GS_URL_USERCARD parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(status,msg);
            }
        });
    }];
}

@end
