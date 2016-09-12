//
//  UserManager.h
//  Sport
//
//  Created by haodong  on 13-6-7.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import <CoreLocation/CoreLocation.h>

@interface UserManager : NSObject
//@property (strong, nonatomic) CLLocation *userLocation;

+ (UserManager *)defaultManager;

- (BOOL)saveUserLocation:(CLLocation *)userLocation;
- (CLLocation *)readUserLocation;

- (BOOL)saveCurrentUser:(User *)user;
- (User *)readCurrentUser;
- (void)clearCurrentUser;

+ (void)savePushToken:(NSString *)pushToken;
+ (NSString *)readPushToken;

+ (void)saveHasUploadPushToken:(BOOL)hasUploadPushToken;
+ (BOOL)readHasUploadPushToken;

+ (void)saveHasUploadDeviceId:(BOOL)hasUploadDeviceId;
+ (BOOL)readHasUploadDeviceId;

+ (void)saveLoginEncode:(NSString *)loginEncode;
+ (NSString *)readLoginEncode;

+ (BOOL)getFirstLoginPage;
+ (void)hasShowFirstLoginPage;
+ (void)didLoginSuccessWithPhoneNumber:(NSString *) phoneNumber;
+ (void)didLogOut;

+ (void)saveLoginPhone:(NSString *)phone;
+ (NSString *)readLoginPhone;

+ (void)saveIsClickedSurvey:(BOOL)isClickedSurvey; //保存是否已经点击问卷调查
+ (BOOL)readIsClickedSurvey;                       //读取是否已经点击问卷调查
+ (BOOL)isLogin;

@end
