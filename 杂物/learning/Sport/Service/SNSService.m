//
//  SNSService.m
//  Sport
//
//  Created by haodong  on 13-10-1.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SNSService.h"
#import "SNSManager.h"
#import "SportProgressView.h"
#import "NSString+Utils.h"
#import "WBHttpRequest.h"
#import "DDNetwork.h"
#import "SportNetworkContent.h"
#import "NSDictionary+JsonValidValue.h"

@implementation SNSService

+ (NSDictionary *)errorDictionary
{
    NSDictionary *dic = @{@"20016":@"发布内容过于频繁",
                          @"20017":@"提交相似的信息",
                          @"20018":@"包含非法网址",
                          @"20019":@"请不要重复发送同样的内容",
                          @"20020":@"包含广告信息",
                          @"20021":@"包含非法内容",
                          @"20022":@"此IP地址上的行为异常",
                          @"21602":@"含有敏感词"
                          };
    return dic;
}

+ (void)sendSinaImageWeibo:(id<SNSServiceDelegate>)delegate
                     image:(UIImage *)image
                      text:(NSString *)text
{
    if (![SNSManager isSinaAuthorize]) {
        [SNSManager sinaAuthorize];
        return;
    }
    
    WBImageObject *wbImageObject = [WBImageObject object];
    wbImageObject.imageData = UIImagePNGRepresentation(image);
    
    [WBHttpRequest requestForShareAStatus:[text encodedURLParameterString]
                        contatinsAPicture:wbImageObject
                             orPictureUrl:nil
                          withAccessToken:[SNSManager readSinaAccessToken]
                       andOtherProperties:nil
                                    queue:nil
                    withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                        if ([delegate respondsToSelector:@selector(didSendSinaWeibo:errorText:)]) {
                            [delegate didSendSinaWeibo:(error == nil) errorText:result];
                        }
    }];
}

+ (void)sendSinaWeibo:(id<SNSServiceDelegate>)delegate
                 text:(NSString *)text
             imageUrl:(NSString *)imageUrl
        isShowSending:(BOOL)isShowSending
{
    BOOL toSend = NO;
    if ([SNSManager isSinaAuthorize]) {
        toSend = YES;
        if (isShowSending) {
            [SportProgressView showWithStatus:@"正在发送到新浪微博..."];
        }
    } else{
        toSend = NO;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL succ = NO;
        NSString *errorText = nil;
        
        if (toSend) {
            //send
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setValue:[SNSManager readSinaAccessToken] forKey:@"access_token"];
            [dic setValue:text forKey:@"status"];
            
            NSString *urlString = @"https://api.weibo.com/2/statuses/update.json";
            if ([imageUrl length] > 0) {
                urlString = @"https://api.weibo.com/2/statuses/upload_url_text.json";
                [dic setValue:imageUrl forKey:@"url"];
            }
            
            NSDictionary *resultDictionary = [DDNetwork postReturnJsonWithBasicUrlString:urlString parameterDictionary:dic postType:PostTypeString];
            
            //NSDictionary *resultDictionary  = [SportNetwrok postReturnJsonWithPrameterDictionary:dic urlString:urlString isAddSign:NO postType:PostTypeString];
            
            
            succ = ([resultDictionary validStringValueForKey:@"id"] != nil ? YES : NO);
            
            if (succ == NO) {
                int error_code = [resultDictionary validIntValueForKey:@"error_code"];
                
                errorText = [[self errorDictionary] objectForKey:[@(error_code) stringValue]];
                if (errorText == nil) {
                    errorText = @"发送失败";
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didSendSinaWeibo:errorText:)]) {
                if (toSend == NO) {
                    [SNSManager sinaAuthorize];
                } else {
                    if (isShowSending) {
                        if (succ) {
                            [SportProgressView dismissWithSuccess:@"发送成功"];
                        } else {
                            [SportProgressView dismissWithError:errorText];
                        }
                    }
                }
                [delegate didSendSinaWeibo:succ errorText:errorText];
            }
        });
    });
}



+ (void)getSinaWeiboUserInfo:(id<SNSServiceDelegate>)delegate
                      userId:(NSString *)userId
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //send
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:[SNSManager readSinaAccessToken] forKey:@"access_token"];
        [dic setValue:userId forKey:@"uid"];
        
        NSDictionary *resultDictionary =[DDNetwork getReturnJsonWithBasicUrlString:@"https://api.weibo.com/2/users/show.json" parameterDictionary:dic];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didGetSinaWeiboUserInfo:)]) {
                [delegate didGetSinaWeiboUserInfo:resultDictionary];
            }
        });
    });
}

+ (void)queryWeChatAccessToken:(id<SNSServiceDelegate>)delegate
                          code:(NSString *)code
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:WEIXIN_APP_ID forKey:@"appid"];
        [dic setValue:WEIXIN_APP_SECRET forKey:@"secret"];
        [dic setValue:code forKey:@"code"];
        [dic setValue:@"authorization_code" forKey:@"grant_type"];
        
        NSDictionary *resultDictionary =[DDNetwork getReturnJsonWithBasicUrlString:@"https://api.weixin.qq.com/sns/oauth2/access_token" parameterDictionary:dic];
        
        NSString *accessToken = [resultDictionary validStringValueForKey:@"access_token"];
        int expiresIn = [resultDictionary validIntValueForKey:@"expires_in"];
        NSString *refreshToken = [resultDictionary validStringValueForKey:@"refresh_token"];
        NSString *openId = [resultDictionary validStringValueForKey:@"openid"];
        NSString *scope = [resultDictionary validStringValueForKey:@"scope"];
        
        int errorCode = [resultDictionary validIntValueForKey:@"errcode"];
        NSString *errorMessage = [resultDictionary validStringValueForKey:@"errmsg"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([delegate respondsToSelector:@selector(didQueryWeChatAccessToken:expiresIn:refreshToken:openId:scope:errorCode:errorMessage:)]) {
                [delegate didQueryWeChatAccessToken:accessToken
                                          expiresIn:expiresIn
                                       refreshToken:refreshToken
                                             openId:openId
                                              scope:scope
                                          errorCode:errorCode
                                       errorMessage:errorMessage];
            }
        });
    });
}

+ (void)queryWeChatUserInfo:(id<SNSServiceDelegate>)delegate
                     openId:(NSString *)openId
                accessToken:(NSString *)accessToken
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:accessToken forKey:@"access_token"];
        [dic setValue:openId forKey:@"openid"];
        
         NSDictionary *resultDictionary =[DDNetwork getReturnJsonWithBasicUrlString:@"https://api.weixin.qq.com/sns/userinfo" parameterDictionary:dic];
        
        NSString *openId = [resultDictionary validStringValueForKey:@"openid"];
        NSString *nickname = [resultDictionary validStringValueForKey:@"nickname"];
        int sex = [resultDictionary validIntValueForKey:@"sex"];
        //NSString *province = [resultDictionary validStringValueForKey:@"province"];
        //NSString *city = [resultDictionary validStringValueForKey:@"city"];
        //NSString *country = [resultDictionary validStringValueForKey:@"country"];
        //NSString *privilege = [resultDictionary validStringValueForKey:@"privilege"];
        NSString *unionId = [resultDictionary validStringValueForKey:@"unionid"];
        NSString *headimgurl = [resultDictionary validStringValueForKey:@"headimgurl"];
        
        int errorCode = [resultDictionary validIntValueForKey:@"errcode"];
        NSString *errorMessage = [resultDictionary validStringValueForKey:@"errmsg"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didQueryWeChatUserInfo:accessToken:unionId:nickname:sex:avatar:errorCode:errorMessage:)]) {
                [delegate didQueryWeChatUserInfo:openId
                                     accessToken:accessToken
                                         unionId:unionId
                                        nickname:nickname
                                             sex:sex
                                          avatar:headimgurl
                                       errorCode:errorCode
                                    errorMessage:errorMessage];
            }
        });
    });
}

@end
