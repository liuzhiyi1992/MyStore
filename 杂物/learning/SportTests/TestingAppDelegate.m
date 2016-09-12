//
//  TestingAppDelegate.m
//  Sport
//
//  Created by 江彦聪 on 16/7/28.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "TestingAppDelegate.h"
#import "AppDelegate_Test.h"
#import "SportNavigationController.h"
#import "SportApplicationContext.h"
#import "AFNetworkActivityLogger.h"


@implementation TestingAppDelegate
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    return;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    id<AFNetworkActivityLoggerProtocol> logger = [AFNetworkActivityLogger sharedLogger].loggers.allObjects[0];
    [logger setLevel:AFLoggerLevelDebug];
    [[AFNetworkActivityLogger sharedLogger] startLogging];
    return TRUE;
}

//-(void) logoutAndCleanView {
//    
//    //返回encode错误时后台会返回一个已退出登录的token
//    
//    SportNavigationController *navController = self.tabBarController.selectedViewController;
//    
//    //首页不提示重新登录的信息
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        if (navController != nil && (navController != self.mainNavigationController || [navController.viewControllers count] > 1)){
//            
//            //关闭所有alertView
//            SportApplicationContext *context = [SportApplicationContext sharedContext];
//            [context dismissAllAlertViews];
//            [context dismissAllActionSheets];
//            
//            //remove 所有subView
//            UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
//            if ([[UIApplication sharedApplication].keyWindow isMemberOfClass:[UIWindow class]]) {
//                for (UIView *view in keyWindow.subviews) {
//                    if(![view isKindOfClass:[UIView class]]) {
//                        continue;
//                    }
//                    
//                    NSUInteger index = [keyWindow.subviews indexOfObject:view];
//                    if (index == 0) {
//                        continue;
//                    }
//                    
//                    [view removeFromSuperview];
//                }
//            }
//        }
//    });
//}

@end