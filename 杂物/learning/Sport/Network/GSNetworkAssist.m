//
//  GSNetworkAssist.m
//  Sport
//
//  Created by qiuhaodong on 16/6/1.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "GSNetworkAssist.h"
#import "SportNetworkContent.h"
#import "NSDictionary+JsonValidValue.h"
#import "CityManager.h"
#import "UUIDManager.h"
#import "AppGlobalDataManager.h"
#import "DesUtil.h"
#import "NSDate+Correct.h"
#import "SportGAS.h"
#import "NSString+Utils.h"
#import <libkern/OSAtomic.h>
#import "TypeConversion.h"
#import "UserManager.h"
#import "NSURLResponse+ReceivedData.h"
#import "UIUtils.h"

@implementation GSNetworkAssist

static volatile int32_t networkQueueCount = 0;

+ (NSDictionary *)addCommonParameters:(NSDictionary *)dictionary
{
    OSAtomicIncrement32Barrier(&networkQueueCount);
    
    if (dictionary == nil) {
        return nil;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    
    //添加操作系统、app版本号、渠道、系统版本号、屏幕宽高、deviceId
    [dic setValue:@"ios" forKey:PARA_UTM_MEDIUM];
    [dic setValue:[UIUtils getAppVersion] forKey:PARA_APP_VERSION];
    [dic setValue:API_CHANNEL forKey:PARA_UTM_SOURCE];
    [dic setValue:[[UIDevice currentDevice] systemVersion] forKey:PARA_SYSTEM_VERSION];
    [dic setValue:[CityManager readCurrentCityId] forKey:PARA_CITY_ID];
    [dic setValue:[@([UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].scale) stringValue] forKey:PARA_DISPLAY_WIDTH];
    [dic setValue:[@([UIScreen mainScreen].bounds.size.height * [UIScreen mainScreen].scale) stringValue] forKey:PARA_DISPLAY_HEIGHT];
    [dic setValue:[[UUIDManager defaultManager] readUUID] forKey:PARA_DEVICE_ID];
    
    // 每个接口访问需要AccessToken
    if ([[AppGlobalDataManager defaultManager].qydToken length] > 0){
        [dic setValue:[DesUtil decryptUseDES:[[AppGlobalDataManager defaultManager] qydToken] key:SPORT_DES_KEY iv:SPORT_DES_IV] forKey:PARA_QYD_TOKEN];
    }
    
    //添加时间戳
    NSString *timestamp = [NSString stringWithFormat:@"%.f", [[NSDate correctDate] timeIntervalSince1970]];
    [dic setValue:timestamp forKey:PARA_CLIENT_TIME];
    
    //随机数保证每个请求唯一
    [dic setValue:[@(arc4random() % 10000) stringValue] forKey:@"mgsz"];
    
    NSArray *keyList = [dic allKeys];
    NSArray *sortedKeyList = [keyList sortedArrayWithOptions:NSSortStable
                                             usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                                 NSString *item1 = (NSString *)obj1;
                                                 NSString *item2 = (NSString *)obj2;
                                                 return [item1 compare:item2];
                                             }];
    
    //添加签名
    NSMutableString *source = [NSMutableString stringWithString:@""];
    for (NSString *key in sortedKeyList) {
        [source appendFormat:@"%@=%@&", key, [dic objectForKey:key]];
    }
    
    [source appendString:[SportGAS mogui]];
    //HDLog(@"source:%@", source);
    NSString *sign = [source md5];
    [dic setValue:sign forKey:PARA_API_SIGN];
    return dic;
}

+ (NSDictionary *)checkResult:(NSDictionary *)dic response:(NSURLResponse *)response
{
    OSAtomicDecrement32Barrier(&networkQueueCount);
        
    if (dic == nil) {
        NSDictionary *reDic = @{PARA_MSG:@"网络不给力，请稍后再试"};
        return reDic;
    } else if (![dic isKindOfClass:[NSDictionary class]]) {
        NSDictionary *reDic = @{PARA_MSG:@"系统错误，请稍后再试"};
        return reDic;
    }
    
    //校验response-sign
    if (response && [response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSString *responseSign = [((NSHTTPURLResponse *)response).allHeaderFields valueForKey:@"response-sign"];
        NSData *data = response.receivedData;
        
        if ([responseSign length] > 0 && data) {
            
            NSMutableString *dicString = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            [dicString appendString:[SportGAS mogui]];
            NSString *localSign = [dicString md5];
            if (![responseSign isEqualToString:localSign]) {
                NSDictionary *reDic = @{PARA_MSG:@"返回的数据校验错误"};
                return reDic;
            }
        }
    }
    
    if ([[dic validStringValueForKey:PARA_MSG] length] == 0) {
        NSMutableDictionary *mutableDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        if ([[dic validStringValueForKey:PARA_STATUS] isEqualToString:STATUS_SUCCESS]) {
            [mutableDic setValue:@"" forKey:PARA_MSG];
        } else {
            [mutableDic setValue:@"网络请求出错" forKey:PARA_MSG];
        }
        return mutableDic;
    } else {
        if ([[dic validStringValueForKey:PARA_STATUS] isEqualToString:STATUS_ACCESS_TOKEN_ERROR]){
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_ACCESS_TOKEN_FAILED object:nil];
        }
        
        return dic;
    }
}

+ (BOOL)checkTokenNetworkReq:(NSMutableDictionary *)parameterDictionary {
    
    //所有接口会返回token的都做以下处理:
    //1. 等待其他网络接口返回再请求
    //2. 如果正在处理token，其他网络接口开子线程等待

    NSString *action = [parameterDictionary valueForKey:PARA_ACTION];
    
    BOOL isQydTokenReq = [[AppGlobalDataManager defaultManager] isTokenRequest:action];
    
    if (isQydTokenReq) {
        
        int retryTimeout = 0;
        //当前有网络请求，且重试时间不超过30s,需要保证在子线程等待
        if(![NSThread isMainThread]) {
            while (networkQueueCount > 0 && retryTimeout < 30) {
                HDLog(@"action: %@,wait for network %d retryTimeout %d in sub thread", action,networkQueueCount,retryTimeout);
                retryTimeout++;
                [NSThread sleepForTimeInterval:1];
            }
        } else if (networkQueueCount > 0){
            HDLog(@"action: %@,wait for network %d retryTimeout %d in main thread", action,networkQueueCount,retryTimeout);
            return NO;
        }
    } else {

        //如果正在请求token，禁止其他网络请求,等待30s后
        //不能在主线程等待
        if(![NSThread isMainThread]) {
            int retryTimeout = 0;
            while([AppGlobalDataManager defaultManager].isProcessingToken == YES && retryTimeout < 30) {
                HDLog(@"action: %@,wait for token %d retryTimeout %d", action,[AppGlobalDataManager defaultManager].isProcessingToken,retryTimeout);
                //先延时，再操作
                [NSThread sleepForTimeInterval:2];

                retryTimeout++;
            }
            
            User *user = [[UserManager defaultManager] readCurrentUser];
            if ([action isEqualToString:VALUE_ACTION_GET_MESSAGE_COUNT_LIST] &&
                (user == nil || [user.userId length] == 0) &&
                [[parameterDictionary valueForKey:PARA_USER_ID] length] > 0) {
                HDLog(@"action: %@, already logout,delete user id", action);
                
                [parameterDictionary removeObjectForKey:PARA_USER_ID];
            }
            
        } else if([AppGlobalDataManager defaultManager].isProcessingToken == YES){
            
            HDLog(@"action: %@, wait for token %d ,deny the request", parameterDictionary,[AppGlobalDataManager defaultManager].isProcessingToken);
            return NO;
        }

    }
    
    return YES;
}

@end
