//
//  SNSService.h
//  Sport
//
//  Created by haodong  on 13-10-1.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SNSServiceDelegate <NSObject>

@optional
- (void)didSendSinaWeibo:(BOOL)succ errorText:(NSString *)errorText;
- (void)didGetSinaWeiboUserInfo:(NSDictionary *)userInfoDic;
- (void)didQueryWeChatAccessToken:(NSString *)accessToken
                        expiresIn:(int)expiresIn
                     refreshToken:(NSString *)refreshToken
                           openId:(NSString *)openId
                            scope:(NSString *)scope
                        errorCode:(int)errorCode
                     errorMessage:(NSString *)errorMessage;
- (void)didQueryWeChatUserInfo:(NSString *)openId
                   accessToken:(NSString *)accessToken
                       unionId:(NSString *)unionId
                      nickname:(NSString *)nickname
                           sex:(int)sex
                        avatar:(NSString *)avatar
                     errorCode:(int)errorCode
                  errorMessage:(NSString *)errorMessage;
@end


@interface SNSService : NSObject

+ (void)sendSinaImageWeibo:(id<SNSServiceDelegate>)delegate
                     image:(UIImage *)image
                      text:(NSString *)text;

+ (void)sendSinaWeibo:(id<SNSServiceDelegate>)delegate
                 text:(NSString *)text
             imageUrl:(NSString *)imageUrl
        isShowSending:(BOOL)isShowSending;

+ (void)getSinaWeiboUserInfo:(id<SNSServiceDelegate>)delegate
                      userId:(NSString *)userId;

//微信登录
+ (void)queryWeChatAccessToken:(id<SNSServiceDelegate>)delegate
                          code:(NSString *)code;

+ (void)queryWeChatUserInfo:(id<SNSServiceDelegate>)delegate
                     openId:(NSString *)openId
                accessToken:(NSString *)accessToken;

@end
