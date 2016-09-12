//
//  PointService.m
//  Sport
//
//  Created by haodong  on 14/11/12.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "PointService.h"
#import "PointGoods.h"
#import "User.h"
#import "UserManager.h"
#import "DrawRecord.h"
#import "PointRecord.h"
#import "GSNetwork.h"


@implementation PointService

+ (void)queryPointGoodsList:(id<PointServiceDelegate>)delegate
                     userId:(NSString *)userId
                       type:(NSString *)type
{
    
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_GET_GIFT_LIST forKey:PARA_ACTION];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        [inputDic setValue:type forKey:PARA_GIFT_TYPE];
        
        [GSNetwork getWithBasicUrlString:GS_URL_INDEX parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
            NSDictionary *resultDictionary = response.jsonResult;
            
            NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
            NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
            
            NSMutableArray *goodsList = nil;
            
            NSString *pointRuleUrl = nil;
            NSString *drawRuleUrl = nil;
            
            int myPoint = 0;
            int onceUsePoint = 0;
            
            if ([status isEqualToString:STATUS_SUCCESS]) {
                
                id data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
                id goodsSourceList = [data validArrayValueForKey:PARA_GIFT_LIST];
                
                if ([goodsSourceList isKindOfClass:[NSArray class]]) {
                    goodsList = [NSMutableArray array];
                    for (id one in (NSArray *)goodsSourceList) {
                        if ([one isKindOfClass:[NSDictionary class]] == NO) {
                            continue;
                        }
                        
                        PointGoods *goods = [[PointGoods alloc] init] ;
                        goods.goodsId = [one validStringValueForKey:PARA_GIFT_ID];
                        goods.title = [one validStringValueForKey:PARA_NAME];
                        goods.subTitle = [one validStringValueForKey:PARA_SHORT_DESCRIPTION];
                        goods.imageUrl = [one validStringValueForKey:@"images_url"]; //images_url
                        goods.originalPoint = [one validIntValueForKey:PARA_ORIGINAL_CREDIT];
                        goods.point = [one validIntValueForKey:PARA_CREDIT];
                        goods.type = [one validIntValueForKey:PARA_TYPE];
                        goods.desc = [one validStringValueForKey:PARA_DESCRIPTION];
                        goods.joinTimes = [one validIntValueForKey:PARA_CONVERT_TIME];
                        
                        [goodsList addObject:goods];
                    }
                }
                
                pointRuleUrl = [data validStringValueForKey:PARA_CREDIT_RULE_URL];
                drawRuleUrl = [data validStringValueForKey:PARA_LOTTERY_RULE_URL];
                
                myPoint = [data validIntValueForKey:PARA_CREDIT];
                onceUsePoint = [data validIntValueForKey:PARA_LOTTERY_CREDIT];
                
                User *user = [[UserManager defaultManager] readCurrentUser];
                user.point = myPoint;
                [[UserManager defaultManager] saveCurrentUser:user];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([delegate respondsToSelector:@selector(didQueryPointGoodsList:status:msg:myPoint:onceUsePoint:pointRuleUrl:drawRuleUrl:)]) {
                    [delegate didQueryPointGoodsList:goodsList
                                              status:status
                                                 msg:msg
                                             myPoint:myPoint
                                        onceUsePoint:onceUsePoint
                                        pointRuleUrl:pointRuleUrl
                                         drawRuleUrl:drawRuleUrl];
                }
            });
    }];
}

+ (void)convertGoods:(id<PointServiceDelegate>)delegate
              userId:(NSString *)userId
             goodsId:(NSString *)goodsId
              drawId:(NSString *)drawId
                type:(NSString *)type
               phone:(NSString *)phone
{

    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_CONVERT_GIFT forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:goodsId forKey:PARA_GIFT_ID];
    [inputDic setValue:drawId forKey:PARA_CONVERT_ID];
    [inputDic setValue:type forKey:PARA_GIFT_TYPE];
    [inputDic setValue:phone forKey:PARA_PHONE];
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        
        NSDictionary *resultDictionary = response.jsonResult;
       
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didConvertGoods:msg:)]) {
                [delegate didConvertGoods:status msg:msg];
            }
        });
    }];
}

+ (void)queryPointRecordList:(id<PointServiceDelegate>)delegate
                      userId:(NSString *)userId
                        page:(int)page
                       count:(int)count
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_USER_CREDIT_LIST forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:[NSString stringWithFormat:@"%d", page] forKey:PARA_PAGE];
    [inputDic setValue:[NSString stringWithFormat:@"%d", count] forKey:PARA_COUNT];
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        NSMutableArray *recordList = [NSMutableArray array];
        
        id data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSArray *list = [data validArrayValueForKey:PARA_LIST];
            for (id one in (NSArray *)list) {
                PointRecord *record = [[PointRecord alloc] init] ;
                
                record.point = [one validIntValueForKey:PARA_CREDIT];
                record.type = [one validIntValueForKey:PARA_TYPE];
                record.desc = [one validStringValueForKey:PARA_DESCRIPTION];
                
                int createDateInt = [one validIntValueForKey:PARA_ADD_TIME];
                record.createDate = [NSDate dateWithTimeIntervalSince1970:createDateInt];
                
                [recordList addObject:record];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didQueryPointRecordList:status:msg:)]) {
                [delegate didQueryPointRecordList:recordList status:status msg:msg];
            }
        });
    }];
}

+ (void)luckyDraw:(id<PointServiceDelegate>)delegate
           userId:(NSString *)userId
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_LUCKY_DRAW forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        
        NSDictionary *resultDictionary = response.jsonResult;
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        id data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        NSString *drawId = [data validStringValueForKey:PARA_CONVERT_ID];
        NSString *goodsId = [data validStringValueForKey:PARA_GIFT_ID];
        int point = [data validIntValueForKey:PARA_CREDIT];
        
        if ([status isEqualToString:STATUS_SUCCESS]) {
            User *user = [[UserManager defaultManager] readCurrentUser];
            user.point = point;
            [[UserManager defaultManager] saveCurrentUser:user];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didLuckyDraw:msg:drawId:goodsId:point:)]) {
                [delegate didLuckyDraw:status msg:msg drawId:drawId goodsId:goodsId point:point];
            }
        });
    }];
}

+ (void)queryDrawNewsList:(id<PointServiceDelegate>)delegate
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_LUCKY_TOP20 forKey:PARA_ACTION];
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        
        NSMutableArray *newsList = [NSMutableArray array];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        NSArray *list = [data validArrayValueForKey:PARA_LIST];
        for (id one in (NSArray *)list) {
            NSString *name = [one validStringValueForKey:PARA_NICK_NAME];
            NSString *desc = [one validStringValueForKey:PARA_DESCRIPTION];
            
            NSMutableString *mutableString = [NSMutableString stringWithString:@""];
            
            if ([name length] > 0) {
                [mutableString appendString:[name substringWithRange:NSMakeRange(0, 1)]];
                [mutableString appendString:@"*"];
                [mutableString appendString:[name substringWithRange:NSMakeRange([name length] - 1, 1)]];
            }
            
            [mutableString appendFormat:@"\t\t\t%@", desc];
            
            [newsList addObject:mutableString];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didQueryDrawNewsList:status:)]) {
                [delegate didQueryDrawNewsList:newsList status:status];
            }
        });
    }];
}

+ (void)queryDrawRecordList:(id<PointServiceDelegate>)delegate
                     userId:(NSString *)userId
                       page:(int)page
                      count:(int)count
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_LUCKY_LIST forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:[NSString stringWithFormat:@"%d", page] forKey:PARA_PAGE];
    [inputDic setValue:[NSString stringWithFormat:@"%d", count] forKey:PARA_COUNT];
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        
        NSDictionary *resultDictionary = response.jsonResult;
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        NSMutableArray *recordList = [NSMutableArray array];
        
        id data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSArray *list = [data validArrayValueForKey:PARA_LIST];
            for (id one in (NSArray *)list) {
                
                if (![one isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                
                DrawRecord *record = [[DrawRecord alloc] init] ;
                
                record.convertId = [one validStringValueForKey:PARA_CONVERT_ID];
                record.giftId = [one validStringValueForKey:PARA_GIFT_ID];
                record.desc = [one validStringValueForKey:PARA_DESCRIPTION];
                int createDataInt = [one validIntValueForKey:PARA_ADD_TIME];
                record.createDate = [NSDate dateWithTimeIntervalSince1970:createDataInt];
                record.status = [one validIntValueForKey:PARA_STATUS];

                [recordList addObject:record];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didQueryDrawRecordList:status:msg:)]) {
                [delegate didQueryDrawRecordList:recordList status:status msg:msg];
            }
        });
    }];
}

@end
