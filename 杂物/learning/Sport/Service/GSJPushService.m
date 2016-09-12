//
//  GSJPushService.m
//  Sport
//
//  Created by Maceesti on 16/1/5.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "GSJPushService.h"
#import "SportNetworkContent.h"
#import "GSNetwork.h"


@implementation GSJPushService

+ (void)addJpushTag:(id<GSJPushServiceDelegate>)delegate
             userId:(NSString *)userId
               tags:(NSString *)tags
     registrationId:(NSString *)registrationId
           deviceId:(NSString *)deviceId{
    
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_GET_ADD_JPUSH_TAG forKey:PARA_ACTION];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        [inputDic setValue:tags forKey:PARA_PARK_TAGS];
        [inputDic setValue:registrationId forKey:PARA_REGISTRATION_ID];
        [inputDic setValue:deviceId forKey:PARA_DEVICE_ID];
        
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler: ^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didAddJpushTagWithStatus:msg:)]) {
                [delegate didAddJpushTagWithStatus:status msg:msg];
            }
        });
    }];
}

+ (void)updatePushToken:(id<GSJPushServiceDelegate>)delegate
                 userId:(NSString *)userId
           iosPushToken:(NSString *)iosPushToken
         registrationId:(NSString *)registrationId
               deviceId:(NSString *)deviceId {
    
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_UPDATE_PUSH_TOKEN forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:iosPushToken forKey:PARA_IOS_PUSH_TOKEN];
    
    if ([registrationId length] > 0) {
        [inputDic setValue:registrationId forKey:PARA_REGISTRATION_ID];
    }
    
    [inputDic setValue:deviceId forKey:PARA_DEVICE_ID];
    [inputDic setValue:@"ios" forKey:PARA_DEVICE];
    
    [GSNetwork getWithBasicUrlString:GS_URL_INDEX parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didUpdatePushTokenWithStatus:msg:)]) {
                [delegate didUpdatePushTokenWithStatus:status msg:msg];
            }
        });
    }];

}

@end
