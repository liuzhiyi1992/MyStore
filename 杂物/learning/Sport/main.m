//
//  main.m
//  Sport
//
//  Created by haodong  on 13-6-4.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        Class appDelegateClass = NSClassFromString(@"TestingAppDelegate");
        if (!appDelegateClass)
                appDelegateClass = [AppDelegate class];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass(appDelegateClass));
        /*
         //出错时可用以下捕捉错误
         @try{
         
         }
         @catch(NSException *exception) {
         NSLog(@"exception:%@", exception);
         }
         @finally {
         
         }
         */
    }
}
