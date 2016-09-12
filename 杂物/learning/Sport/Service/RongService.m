//
//  RongService.m
//  Sport
//
//  Created by 江彦聪 on 15/7/23.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "RongService.h"
#import "UserManager.h"
#import <RongIMLib/RCUserInfo.h>
#import "AppDelegate.h"
#import "TipNumberManager.h"
#import "GSNetwork.h"

@implementation RongService
static RongService *_globalRongService = nil;

#define ShareApplicationDelegate [[UIApplication sharedApplication] delegate]

+ (RongService *)defaultService
{
    if (_globalRongService == nil) {
        _globalRongService = [[RongService alloc] init];
    }
    return _globalRongService;
}

//融云获取教练详情
- (void)getRongIMUserInfo:(id)delegate
                    rongId:(NSString *)rongId
                completion:(void (^)(RCUserInfo *user))completion
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_RONGIM_AVATAR_INFO forKey:PARA_ACTION];
    [inputDic setValue:rongId forKey:PARA_V_USER_ID];
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    [GSNetwork getWithBasicUrlString:GS_URL_IM parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        //NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        RCUserInfo *rcUser = nil;
        if ([status isEqualToString:STATUS_SUCCESS]) {
            NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
            rcUser = [RCUserInfo new];
            rcUser.userId = rongId;
            rcUser.portraitUri = [data validStringValueForKey:PARA_AVATAR];
            rcUser.name = [data validStringValueForKey:PARA_NICK_NAME];
        }
        else {
            RCUserInfo *user = [RCUserInfo new];
            
            user.userId = rongId;
            user.portraitUri = @"";
            user.name = [NSString stringWithFormat:@"qyd%@", rongId];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(user);
            });
        }
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(rcUser);
            });
        }
    }];
 }


//融云获取Token
- (void)getRongIMToken:(id<RongServiceDelegate>)delegate
                    userId:(NSString *)userId
                      type:(RONG_USER_TYPE)type
                 isRefresh:(BOOL)isRefresh
                completion:(void (^)(NSString *token))completion
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_IM_TOKEN forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:[NSString stringWithFormat:@"%ld", (long)type] forKey:PARA_TYPE];
    [inputDic setValue:[@(isRefresh) stringValue] forKey:PARA_REFRESH];
    
    [GSNetwork getWithBasicUrlString:GS_URL_IM parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
   
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        //NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        NSString *token = nil;
        
        if ([status isEqualToString:STATUS_SUCCESS]) {
            token = [data validStringValueForKey:PARA_TOKEN];
            User *user = [[UserManager defaultManager] readCurrentUser];
            user.rongToken = token;
            [[UserManager defaultManager] saveCurrentUser:user];
        }
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(token);
            });
        }
    }];
}

#define MAX_RETRY_TIMES 100
int retryTimes = 0;
-(void)connectRongIM
{
    __weak __typeof(self) weakSelf = self;
    User *user = [[UserManager defaultManager] readCurrentUser];
    if (user == nil || user.rongId == nil) {
        HDLog(@"Not login. Failed to connect Rong IM");
        return;
    }
    

    if ([user.rongToken length] == 0) {

        [[RongService defaultService] getRongIMToken:self userId:user.userId type:RONG_USER_TYPE_SPORT isRefresh:YES completion:^(NSString *token){
            //避免死循环
            if (retryTimes < MAX_RETRY_TIMES) {

                [weakSelf performSelector:@selector(connectRongIM) withObject:nil afterDelay:2];
                
                return;
            }
        }];
        
        retryTimes++;
        return;
    }
    
    retryTimes = 0;
   
    if (self.isRongReady == YES) {
        //如果已经加载过，不重复加载
        return;
    }

    RCUserInfo *_currentUserInfo =
    [[RCUserInfo alloc] initWithUserId:user.rongId
                                  name:user.nickname
                              portrait:user.avatarUrl];
    [RCIMClient sharedRCIMClient].currentUserInfo = _currentUserInfo;
    
    //标示融云已经加载
    self.isRongReady = YES;
    
    [[RCIM sharedRCIM] connectWithToken:user.rongToken
                                success:^(NSString *userId) {
                
                                    //设置当前的用户信息
                                    [[RCIM sharedRCIM]
                                     refreshUserInfoCache:_currentUserInfo
                                     withUserId:userId];
                                    
                                    NSInteger count = [[RCIMClient sharedRCIMClient] getUnreadCount:@[@(ConversationType_PRIVATE),@(ConversationType_SYSTEM)]];
                                    
                                    [[TipNumberManager defaultManager] setImReceiveMessageCount:count];
                                }
                                  error:^(RCConnectErrorCode status) {
                                      
                                      HDLog(@"connect error %ld", (long)status);
                                      RCUserInfo *_currentUserInfo =
                                      [[RCUserInfo alloc] initWithUserId:user.rongId
                                                                    name:user.nickname
                                                                portrait:user.avatarUrl];
                                      [RCIMClient sharedRCIMClient].currentUserInfo = _currentUserInfo;
                                      
                                  }
                         tokenIncorrect:^{
                             [[RongService defaultService]getRongIMToken:self userId:user.userId type:RONG_USER_TYPE_SPORT isRefresh:YES completion:^(NSString *token){
                                 //获取Token成功后，重新登录
                                 if (token) {
                                     
                                     weakSelf.isRongReady = NO;
                                     [weakSelf connectRongIM];
                                 }
                             }];
                         }];
}

-(void)setDeviceToken:(NSString *)deviceToken
{
    [[RCIMClient sharedRCIMClient] setDeviceToken:deviceToken];
}

-(void)disconnect
{
    self.isRongReady = NO;
    [[RCIM sharedRCIM] logout];
    [[RCIMClient sharedRCIMClient] logout];
    [RCIMClient sharedRCIMClient].currentUserInfo = nil;
}

-(BOOL)checkRongReady
{
    return self.isRongReady;
}

@end
