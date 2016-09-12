//
//  AppDelegate_Test.h
//  Sport
//
//  Created by 江彦聪 on 16/7/28.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "AppDelegate.h"
@class SportNavigationController;

@interface AppDelegate ()
-(void) initAppData;
-(void) requestQydToken;

@property (strong, nonatomic) SportNavigationController *mainNavigationController;
@end