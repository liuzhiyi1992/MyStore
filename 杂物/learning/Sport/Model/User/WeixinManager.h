//
//  WeixinManager.h
//  Sport
//
//  Created by haodong  on 13-10-18.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"
#import "SNSService.h"
#import "UserService.h"
#import "OpenInfo.h"

@interface WeixinManager : NSObject<SNSServiceDelegate, UserServiceDelegate>

+ (WeixinManager *)defaultManager;

+ (BOOL)isWXAppInstalled;

+ (void)sendLinkContent:(int)scene
                  title:(NSString *)title
                   desc:(NSString *)desc
                  image:(UIImage *)image
                    url:(NSString *)url;

+ (void)sendTextContent:(NSString *)text scene:(int)scene;

- (void)login:(NSString *)code;

- (void)bind:(NSString *)code;

@end
