//
//  WeixinManager.m
//  Sport
//
//  Created by haodong  on 13-10-18.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "WeixinManager.h"
#import "SportProgressView.h"
#import "SportPopupView.h"
#import "UserManager.h"

static WeixinManager *_globalWeixinManager = nil;

@interface WeixinManager()
@property (nonatomic, copy)NSString *wxType;
@end

@implementation WeixinManager

+ (WeixinManager *)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _globalWeixinManager = [[WeixinManager alloc] init];
    });
    return _globalWeixinManager;
}

+ (BOOL)isWXAppInstalled
{
    return [WXApi isWXAppInstalled];
}

+ (void)sendLinkContent:(int)scene
                  title:(NSString *)title
                   desc:(NSString *)desc
                  image:(UIImage *)image
                    url:(NSString *)url
{
    if ([WXApi isWXAppInstalled] == NO) {
        [SportPopupView popupWithMessage:@"您尚未安装微信"];
        return;
    }
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = desc;
    [message setThumbImage:image];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = url;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    [WXApi sendReq:req];
}

+ (void)sendTextContent:(NSString *)text scene:(int)scene
{
    if ([WXApi isWXAppInstalled] == NO) {
        [SportPopupView popupWithMessage:@"您尚未安装微信"];
        return;
    }
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.text = text;
    req.bText = YES;
    req.scene = scene;
    [WXApi sendReq:req];
}

- (void)login:(NSString *)code
{
    self.wxType = @"login";
    [SportProgressView showWithStatus:@"登陆中" hasMask:YES];
    [SNSService queryWeChatAccessToken:self
                                  code:code];
}

- (void)bind:(NSString *)code{
    self.wxType = @"bind";
    [SNSService queryWeChatAccessToken:self
                                  code:code];
}


- (void)didQueryWeChatAccessToken:(NSString *)accessToken
                        expiresIn:(int)expiresIn
                     refreshToken:(NSString *)refreshToken
                           openId:(NSString *)openId
                            scope:(NSString *)scope
                        errorCode:(int)errorCode
                     errorMessage:(NSString *)errorMessage
{
    if (accessToken) {
        [SNSService queryWeChatUserInfo:self
                                 openId:openId
                            accessToken:accessToken];
    } else {
        [SportProgressView dismiss];
    }
}

- (void)didQueryWeChatUserInfo:(NSString *)openId
                   accessToken:(NSString *)accessToken
                       unionId:(NSString *)unionId
                      nickname:(NSString *)nickname
                           sex:(int)sex
                        avatar:(NSString *)avatar
                     errorCode:(int)errorCode
                  errorMessage:(NSString *)errorMessage
{
    if (unionId) {
        
        NSString *gender = nil;
        if (sex == 1) {
            gender = @"m";
        } else if (sex == 2) {
            gender = @"f";
        }
        if ([self.wxType isEqualToString:@"login"]) {
            [UserService unionLogin:self openId:openId unionId:unionId accessToken:accessToken openType:OPEN_TYPE_WX nickName:nickname gender:gender avatar:avatar];
            
        }else{
            [SportProgressView dismiss];

            User *user = [[UserManager defaultManager] readCurrentUser];
            [SportProgressView showWithStatus:@"正在绑定..."];

            [UserService unionBind:self
                            userId:user.userId
                            openId:openId
                           unionId:unionId
                       accessToken:accessToken
                          openType:OPEN_TYPE_WX
                          nickName:nickname];
        }
    } else {
        [SportProgressView dismiss];
    }
}

/**
 *  绑定之后的回调
 *
 */
- (void)didUnionBindWithStatus:(NSString *)status msg:(NSString *)msg {
    if ([status isEqualToString:STATUS_SUCCESS]) {
        User *user = [[UserManager defaultManager] readCurrentUser];
        [UserService queryUserProfileInfo:self userId:user.userId];
    } else {
        [SportProgressView dismissWithError:msg];
    }
}

- (void)didQueryUserProfileInfo:(User *)user status:(NSString *)status msg:(NSString *)msg{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismissWithSuccess:@"绑定成功"];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_WECHAT_BIND_SUCCESS object:nil userInfo:nil];
    } else {
        [SportProgressView dismissWithError:@"绑定失败"];
    }
}


//登录成功之后的回调
- (void)didUnionLogin:(NSString *)status msg:(NSString *)msg data:(NSDictionary *)data openId:(NSString *)openId unionId:(NSString *)unionId accessToken:(NSString *)accessToken openType:(NSString *)openType avatar:(NSString *)avatar nickName:(NSString *)nickName gender:(NSString *)gender {
    
    NSMutableDictionary *didUnionLoginDict = [NSMutableDictionary dictionary];
    [didUnionLoginDict setValue:status forKey:PARA_STATUS];
    [didUnionLoginDict setValue:msg forKey:PARA_MSG];
    [didUnionLoginDict setValue:data forKey:PARA_DATA];
    [didUnionLoginDict setValue:openId forKey:PARA_OPEN_ID];
    [didUnionLoginDict setValue:unionId forKey:PARA_UNION_ID];
    [didUnionLoginDict setValue:accessToken forKey:PARA_ACCESS_TOKEN];
    [didUnionLoginDict setValue:openType forKey:PARA_OPEN_TYPE];
    [didUnionLoginDict setValue:avatar forKey:PARA_AVATAR];
    [didUnionLoginDict setValue:nickName forKey:PARA_NICK_NAME];
    [didUnionLoginDict setValue:gender forKey:PARA_GENDER];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_WECHAT_LOGIN_SUCCESS object:didUnionLoginDict userInfo:nil];
    
}

@end
