//
//  SNSManager.h
//  Sport
//
//  Created by haodong  on 13-9-30.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboSDK.h"

#define NOTIFICATION_SINA_WEIBO_AUTHORIZE_CALLBACK   @"NOTIFICATION_SINA_WEIBO_AUTHORIZE_CALLBACK"


#define SINA_WEIBO_AUTHORIZE_CALLBACK_RESULT  @"WEIBO_AUTHORIZE_CALLBACK_CALLBACK_RESULT"

@interface SNSManager : NSObject
//sina
@property (copy, nonatomic) NSString *sinaUserId;
@property (copy, nonatomic) NSString *sinaNickName;

+ (SNSManager *)defaultManager;

//sina
+ (BOOL)saveSinaAccessToken:(NSString *)sinaAccessToken;
+ (NSString *)readSinaAccessToken;
+ (void)sinaAuthorize;
+ (BOOL)isSinaAuthorize; //是否已授权

@end
