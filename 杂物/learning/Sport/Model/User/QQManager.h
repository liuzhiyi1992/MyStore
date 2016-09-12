//
//  QQManager.h
//  Sport
//
//  Created by haodong  on 13-10-21.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

#import <TencentOpenAPI/TencentOAuth.h>

#define QQLoginSuccessed    @"QQLoginSuccessed"
#define QQLoginFailed       @"QQLoginFailed"

@protocol QQManagerDelegate <NSObject>
@optional
- (void)didAuthorize:(BOOL)isSuccess;
- (void)didGetQQUserInfo:(NSDictionary *)jsonResponse;


@end


@interface QQManager : NSObject <TencentSessionDelegate, TCAPIRequestDelegate>

@property (nonatomic, retain)TencentOAuth *oauth;

+ (QQManager *)defaultManager;

+ (BOOL)isQQInstalled;

+ (BOOL)saveAccessToken:(NSString *)accessToken;
+ (NSString *)readAccessToken;

+ (BOOL)saveOpenId:(NSString *)openId;
+ (NSString *)readOpenId;


- (void)authorize:(id<QQManagerDelegate>)delegate;

- (void)getQQUserInfo:(id<QQManagerDelegate>)delegate;



@end
