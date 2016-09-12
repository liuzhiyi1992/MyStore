//
//  SportProgressView.m
//  Sport
//
//  Created by haodong  on 13-6-8.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SportProgressView.h"

@implementation SportProgressView

+ (void)onceSetColor
{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    [SVProgressHUD setMinimumDismissTimeInterval:2];
}

+ (void)showWithStatus:(NSString *)status
{
    [self showWithStatus:status hasMask:NO];
}

+ (void)showWithStatus:(NSString *)status hasMask:(BOOL)hasMask
{
    [self onceSetColor];
    if (hasMask) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    }
    
    [SVProgressHUD showWithStatus:status];
}

+ (void)dismiss
{
    [SVProgressHUD dismiss];
}

+ (void)dismissWithSuccess:(NSString*)successString
{
    [self onceSetColor];
    [SVProgressHUD showSuccessWithStatus:successString];
}

+ (void)dismissWithSuccess:(NSString*)successString afterDelay:(NSTimeInterval)seconds
{
    [self onceSetColor];
    [SVProgressHUD performSelector:@selector(showSuccessWithStatus:) withObject:successString afterDelay:seconds];
}

+ (void)dismissWithError:(NSString*)errorString
{
    [self onceSetColor];
    [SVProgressHUD showErrorWithStatus:errorString];
}

+ (void)dismissWithError:(NSString*)errorString afterDelay:(NSTimeInterval)seconds
{
    [self onceSetColor];
    [SVProgressHUD performSelector:@selector(showErrorWithStatus:) withObject:errorString afterDelay:seconds];
}

@end
