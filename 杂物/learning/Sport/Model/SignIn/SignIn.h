//
//  SignIn.h
//  Sport
//
//  Created by xiaoyang on 16/6/14.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SignIn : NSObject
@property (assign, nonatomic) int daySignInStatus;
@property (assign, nonatomic) int versionSignInStatus;//打卡功能上线以来，有无打卡记录
@property (strong, nonatomic) NSArray *fourWeekSignInList;

@end
