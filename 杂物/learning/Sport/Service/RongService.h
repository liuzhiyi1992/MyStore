//
//  RongService.h
//  Sport
//
//  Created by 江彦聪 on 15/7/23.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SportNetworkContent.h"
#import <RongIMKit/RongIMKit.h>
#import "SportRCIMDataSource.h"

@class RCUserInfo;

typedef NS_ENUM(NSInteger, RONG_USER_TYPE)
{
    RONG_USER_TYPE_SPORT = 0,
    RONG_USER_TYPE_COACH = 1,
};

@protocol RongServiceDelegate <NSObject>
@optional

@end

@interface RongService : NSObject
@property (assign,nonatomic) BOOL isRongReady;

+ (RongService *)defaultService;

//融云获取教练信息
- (void)getRongIMUserInfo:(id)delegate
                    rongId:(NSString *)rongId
                completion:(void (^)(RCUserInfo *user))completion;

//获取融云Token
- (void)getRongIMToken:(id)delegate
                userId:(NSString *)userId
                  type:(RONG_USER_TYPE)type
             isRefresh:(BOOL)isRefresh
            completion:(void (^)(NSString *token))completion;
-(BOOL)checkRongReady;
-(void)connectRongIM;
-(void)disconnect;
-(void)setDeviceToken:(NSString *)deviceToken;

@end
