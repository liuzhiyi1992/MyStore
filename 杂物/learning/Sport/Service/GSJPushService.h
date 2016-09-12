//
//  GSJPushService.h
//  Sport
//
//  Created by Maceesti on 16/1/5.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SportNetworkContent.h"

@protocol GSJPushServiceDelegate <NSObject>

@optional
- (void)didAddJpushTagWithStatus:(NSString *)status msg:(NSString *)msg;

-(void)didUpdatePushTokenWithStatus:(NSString *)status msg:(NSString *)msg;

@end

@interface GSJPushService : NSObject

+ (void)addJpushTag:(id<GSJPushServiceDelegate>)delegate
             userId:(NSString *)userId
               tags:(NSString *)tags
     registrationId:(NSString *)registrationId
           deviceId:(NSString *)deviceId;

+ (void)updatePushToken:(id<GSJPushServiceDelegate>)delegate
                 userId:(NSString *)userId
           iosPushToken:(NSString *)iosPushToken
         registrationId:(NSString *)registrationId
               deviceId:(NSString *)deviceId;

@end
