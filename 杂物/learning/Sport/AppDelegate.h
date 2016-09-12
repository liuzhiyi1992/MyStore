//
//  AppDelegate.h
//  Sport
//
//  Created by haodong  on 13-6-4.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNSManager.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "UserService.h"
#import "BaseService.h"
#import "UITabBarController+SportTabBarController.h"

//提前更新间隔为10分钟
#define MIN_ACCESS_TOKEN_INTERVAL 60*10

//如果不足10分钟，按10分钟计算
#define REAL_EXPIRE_TIME(expire) (expire)-MIN_ACCESS_TOKEN_INTERVAL>0?((expire)-MIN_ACCESS_TOKEN_INTERVAL):MIN_ACCESS_TOKEN_INTERVAL
//#define REAL_EXPIRE_TIME(expire) expire*0.5 > 60 ? expire*0.5:60

@interface AppDelegate : UIResponder <UIApplicationDelegate, WeiboSDKDelegate, UIAlertViewDelegate, WXApiDelegate, UserServiceDelegate,BaseServiceDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;
-(void) requestAccessTokenWithTimerInterval:(int)interval;
-(void) logoutAndCleanView;
@end
