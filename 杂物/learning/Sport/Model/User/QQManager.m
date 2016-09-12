//
//  QQManager.m
//  Sport
//
//  Created by haodong  on 13-10-21.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "QQManager.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import "SportPopupView.h"

typedef enum{
    NextOperateNull = 0,
    NextOperateShare = 1,
} NextOperate;

@interface QQManager()
@property (assign, nonatomic) id<QQManagerDelegate> delegate;
@property (assign, nonatomic) NextOperate nextOperate;
@property (copy, nonatomic) NSString *shareText;
@end



static QQManager *_globalQQManager = nil;

@implementation QQManager


+ (QQManager *)defaultManager
{
    if (_globalQQManager == nil) {
        _globalQQManager  = [[QQManager alloc] init];
        _globalQQManager.oauth = [[TencentOAuth alloc] initWithAppId:QQ_APP_ID andDelegate:_globalQQManager] ;
//        NSString *accessToken = [QQManager readAccessToken];
//        NSString *openId = [QQManager readOpenId];
//        _globalQQManager.oauth.accessToken = accessToken;
//        _globalQQManager.oauth.openId = openId;
    }
    return _globalQQManager;
}

+ (BOOL)isQQInstalled
{
    return [QQApiInterface isQQInstalled];
}

#define KEY_QQ_ACCESS_TOKEN  @"KEY_QQ_ACCESS_TOKEN"
+ (BOOL)saveAccessToken:(NSString *)accessToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:accessToken forKey:KEY_QQ_ACCESS_TOKEN];
    return [defaults synchronize];
}
+ (NSString *)readAccessToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults valueForKey:KEY_QQ_ACCESS_TOKEN];
}

#define KEY_QQ_OPEN_ID  @"KEY_QQ_OPEN_ID"
+ (BOOL)saveOpenId:(NSString *)openId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:openId forKey:KEY_QQ_ACCESS_TOKEN];
    return [defaults synchronize];
}

+ (NSString *)readOpenId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults valueForKey:KEY_QQ_OPEN_ID];
}



- (void)authorize:(id<QQManagerDelegate>)delegate
{
    self.delegate = delegate;
    NSArray* permissions = [NSArray arrayWithObjects:
                            kOPEN_PERMISSION_GET_USER_INFO,
                            kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                            kOPEN_PERMISSION_ADD_ALBUM,
                            kOPEN_PERMISSION_ADD_ONE_BLOG,
                            kOPEN_PERMISSION_ADD_SHARE,
                            kOPEN_PERMISSION_ADD_TOPIC,
                            kOPEN_PERMISSION_CHECK_PAGE_FANS,
                            kOPEN_PERMISSION_GET_INFO,
                            kOPEN_PERMISSION_GET_OTHER_INFO,
                            kOPEN_PERMISSION_LIST_ALBUM,
                            kOPEN_PERMISSION_UPLOAD_PIC,
                            kOPEN_PERMISSION_GET_VIP_INFO,
                            kOPEN_PERMISSION_GET_VIP_RICH_INFO,
                            //微云的api权限
                            @"upload_pic",
                            @"download_pic",
                            @"get_pic_list",
                            @"delete_pic",
                            @"upload_pic",
                            @"download_pic",
                            @"get_pic_list",
                            @"delete_pic",
                            @"get_pic_thumb",
                            @"upload_music",
                            @"download_music",
                            @"get_music_list",
                            @"delete_music",
                            @"upload_video",
                            @"download_video",
                            @"get_video_list",
                            @"delete_video",
                            @"upload_photo",
                            @"download_photo",
                            @"get_photo_list",
                            @"delete_photo",
                            @"get_photo_thumb",
                            @"check_record",
                            @"create_record",
                            @"delete_record",
                            @"get_record",
                            @"modify_record",
                            @"query_all_record",
                            nil];
    [self.oauth authorize:permissions inSafari:NO];
}

- (void)getQQUserInfo:(id<QQManagerDelegate>)delegate
{
    self.delegate = delegate;
    [self.oauth getUserInfo];
}



#pragma - mark deletate
- (void)tencentDidLogin
{
    [QQManager saveAccessToken:self.oauth.accessToken];
    [QQManager saveOpenId:self.oauth.openId];
    //[[NSNotificationCenter defaultCenter] postNotificationName:QQLoginSuccessed object:self];
    HDLog(@"tencentDidLogin");
    if ([_delegate respondsToSelector:@selector(didAuthorize:)]) {
        [_delegate didAuthorize:YES];
    }

    self.nextOperate = NextOperateNull;
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    //[[NSNotificationCenter defaultCenter] postNotificationName:QQLoginFailed object:self];
    HDLog(@"tencentDidNotLogin");
    if ([_delegate respondsToSelector:@selector(didAuthorize:)]) {
        [_delegate didAuthorize:NO];
    }
}

- (void)tencentDidNotNetWork
{
    //[[NSNotificationCenter defaultCenter] postNotificationName:QQLoginFailed object:self];
    HDLog(@"tencentDidNotNetWork");
    if ([_delegate respondsToSelector:@selector(didAuthorize:)]) {
        [_delegate didAuthorize:NO];
    }
}

- (void)getUserInfoResponse:(APIResponse*)response
{
    HDLog(@"getUserInfoResponse:%@", response.jsonResponse);
    if ([_delegate respondsToSelector:@selector(didGetQQUserInfo:)]) {
        [_delegate didGetQQUserInfo:response.jsonResponse];
    }
}

@end
