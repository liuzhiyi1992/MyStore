//
//  SportProgressView.h
//  Sport
//
//  Created by haodong  on 13-6-8.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVProgressHUD.h"

@interface SportProgressView : NSObject
+ (void)showWithStatus:(NSString *)status;
+ (void)showWithStatus:(NSString *)status hasMask:(BOOL)hasMask;

+ (void)dismiss;
+ (void)dismissWithSuccess:(NSString*)successString;
+ (void)dismissWithSuccess:(NSString*)successString afterDelay:(NSTimeInterval)seconds;
+ (void)dismissWithError:(NSString*)errorString;
+ (void)dismissWithError:(NSString*)errorString afterDelay:(NSTimeInterval)seconds;
@end