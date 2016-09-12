//
//  RCDRCIMDelegateImplementation.m
//  RongCloud
//
//  Created by Liv on 14/11/11.
//  Copyright (c) 2014年 胡利武. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>
//#import "AFHttpTool.h"
#import "SportRCIMDataSource.h"
//#import "RCDLoginInfo.h"
//#import "RCDGroupInfo.h"
//#import "RCDUserInfo.h"
//#import "RCDHttpTool.h"
//#import "DBHelper.h"
//#import "RCDataBaseManager.h"
//#import "CoachCommonDefine.h"

@interface SportRCIMDataSource ()

@end

@implementation SportRCIMDataSource
static int retryCount = 0;
- (instancetype)init
{
    self = [super init];
    if (self) {
        //设置信息提供者
        [[RCIM sharedRCIM] setUserInfoDataSource:self];
        
        //同步群组
        //[self syncGroups];
        

    }
    return self;
}

+ (SportRCIMDataSource*)shareInstance
{
    static SportRCIMDataSource* instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];

    });
    return instance;
}

#define MAX_RETRY_TIMES 10
-(void) startServiceWithAppKey:(NSString *) appKey
                     userToken:(NSString *) userToken
{
    //初始化RongCloud SDK
    [[RCIM sharedRCIM] initWithAppKey:appKey];
    
    //登陆RongCloud Server
    [[RCIM sharedRCIM] connectWithToken:userToken
    
       success:^(NSString *userId) {
           NSAssert(userId, @"connect success!");
      } error:^(RCConnectErrorCode status) {
        HDLog(@"startServiceWithAppKey error status %ld",(long)status);
    }
     tokenIncorrect:^{
         HDLog(@"startServiceWithAppKey token InCorrect %d",retryCount);
         if (retryCount < MAX_RETRY_TIMES) {
             [self startServiceWithAppKey:appKey userToken:userToken];
             retryCount++;
         }
     }];
}

#pragma mark - RCIMUserInfoDataSource
- (void)getUserInfoWithUserId:(NSString*)userId completion:(void (^)(RCUserInfo*))completion
{
    if (userId == nil || [userId length] == 0 )
    {
        completion(nil);
        return ;
    }

    [[RongService defaultService] getRongIMUserInfo:self
                                rongId:userId
                               completion:^(RCUserInfo *user) {
                                   if (user) {
                                       completion(user);
                                   }
                                   else {
                                       completion(nil);
                                   }
                               }];
  
}


@end
