//
//  SignInService.m
//  Sport
//
//  Created by lzy on 16/6/7.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "SignInService.h"
#import "GSNetwork.h"
#import "SignInWeeklyModel.h"
#import "ShareContent.h"

@implementation SignInService

+ (void)getNearbyVenuesWithLatitude:(double)latitude
                          longitude:(double)longitude
                         completion:(void (^)(NSString *, NSString *, NSArray *))completion {
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_SIGN_IN_VENUES  forKey:PARA_ACTION];
    [inputDic setValue:[@(latitude) stringValue]  forKey:PARA_LATITUDE];
    [inputDic setValue:[@(longitude) stringValue] forKey:PARA_LONGITUDE];
    
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        NSArray *venuesArray = [data validArrayValueForKey:PARA_NEARBY_VENUES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(status, msg, venuesArray);
        });
    }];
}

+ (void)signInWithUserID:(NSString *)userId
                venuesId:(NSString *)venuesId
              completion:(void (^)(NSString *, NSString *, NSDictionary *, ShareContent *))completion {
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_SIGN_IN  forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:venuesId forKey:PARA_VENUES_ID];
    
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        ShareContent *shareContent = [[ShareContent alloc] init];
        shareContent.title = [data validStringValueForKey:PARA_SHARE_TITLE];
        shareContent.subTitle = [data validStringValueForKey:PARA_SHARE_CONTENT];
        shareContent.content = [data validStringValueForKey:PARA_SHARE_CONTENT];
        shareContent.linkUrl = [data validStringValueForKey:PARA_SHARE_URL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(status, msg, data, shareContent);
        });
    }];
}

+ (void)writeSignInDiaryWithUserId:(NSString *)userId
                          signInId:(NSString *)signInId
                           content:(NSString *)content
                         attachIds:(NSString *)attachIds
                         coterieId:(NSString *)coterieId
                        completion:(void (^)(NSString *, NSString *))completion {
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_WRITE_SIGN_IN_DIARY  forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:signInId forKey:PARA_SIGN_IN_ID];
    [inputDic setValue:content forKey:PARA_CONTENT];
    [inputDic setValue:attachIds forKey:PARA_ATTACH_IDS];
    if ([coterieId length] > 0) {
        [inputDic setValue:coterieId forKey:PARA_COTERIE_ID];
    }
    
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];

        dispatch_async(dispatch_get_main_queue(), ^{
            completion(status, msg);
        });
    }];
}

+ (void)getSignInDiaryListWithUserId:(NSString *)userId
                                page:(int)page
                               count:(int)count
                          completion:(void (^)(NSString *, NSString *, NSDictionary *))completion {
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_SIGN_IN_DIARY  forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:@(page) forKey:PARA_PAGE];
    [inputDic setValue:@(count) forKey:PARA_COUNT];
    
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(status, msg, data);
        });
    }];
}

+ (void)getSignInRecordsWithUserId:(NSString *)userId
                        completion:(void (^)(NSString *, NSString *, NSArray *, NSString *, NSString *, NSString *))completion {
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_MOTION_RECORDS  forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        NSString *tips = [data validStringValueForKey:PARA_TIPS];
        NSArray *signRecordsArray = [data validArrayValueForKey:PARA_TEN_WEEK_DATA];
        NSMutableArray *weeklyModelArray = [NSMutableArray array];
        for (NSDictionary *dict in signRecordsArray) {
            //model
            SignInWeeklyModel *model = [[SignInWeeklyModel alloc] init];
            model.status = [dict validStringValueForKey:PARA_SIGN_IN_STATUS];
            model.integral = [dict validStringValueForKey:PARA_INTEGRAL];
            model.coupon = [dict validStringValueForKey:PARA_COUPON];
            model.weekName = [dict validStringValueForKey:PARA_WEEK_NAME];
            [weeklyModelArray addObject:model];
        }
        
        NSString *wisdomAuthor = [[data validDictionaryValueForKey:PARA_WISDOM] validStringValueForKey:PARA_AUTHOR];
        NSString *wisdomContent = [[data validDictionaryValueForKey:PARA_WISDOM] validStringValueForKey:PARA_CONTENT];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(status, msg, weeklyModelArray, tips, wisdomAuthor, wisdomContent);
        });
    }];
}

@end
