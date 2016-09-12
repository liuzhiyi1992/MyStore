//
//  UIUtils.m
//  
//
//  Created by haodong on 12-9-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIUtils.h"
#import "LogUtil.h"
#import "DeviceDetection.h"

@implementation UIUtils

+ (NSString*)getAppVersion
{
    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return version;
}

+ (NSString*)getAppName
{
    NSBundle* bundle = [NSBundle mainBundle];
    NSString *appName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if (!appName) {
        appName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
    }
    if (!appName) {
        return nil;
    }
    return appName;
}

+ (NSString*)getAppLink:(NSString*)appId
{
	NSString* iTunesLink = [NSString stringWithFormat:
							@"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&mt=8", appId];
    HDLog(@"<getAppLink> iTunes Link=%@", iTunesLink);
	return iTunesLink;
}

+ (void)openApp:(NSString*)appId
{
    NSString* iTunesLink = nil;
    if (DeviceSystemMajorVersion() < 7) {
        iTunesLink = [NSString stringWithFormat:
                      @"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&mt=8", appId];
    } else {
        iTunesLink = [NSString stringWithFormat:
                      @"itms-apps://itunes.apple.com/app/id%@", appId];
    }
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
}

+ (void)gotoReview:(NSString*)appId
{
    NSString* iTunesLink = nil;
    if (DeviceSystemMajorVersion() < 7) {
        iTunesLink = [NSString stringWithFormat:
							@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", appId];
    } else {
        iTunesLink = [NSString stringWithFormat:
                  @"itms-apps://itunes.apple.com/app/id%@", appId];
    }
    
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
}

+ (BOOL)makeCall:(NSString *)phoneNumber
{	
	NSString* numberAfterClear = [UIUtils cleanPhoneNumber:phoneNumber];
	NSURL *phoneNumberURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", numberAfterClear]];
    if ([[UIApplication sharedApplication] canOpenURL:phoneNumberURL] == NO)
    {
        HDLog(@"not can call");
        return NO;
	}
	return [[UIApplication sharedApplication] openURL:phoneNumberURL];
}


+ (BOOL)makePromptCall:(NSString *)phoneNumber
{
	NSString* numberAfterClear = [UIUtils cleanPhoneNumber:phoneNumber];
	NSURL *phoneNumberURL = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt:%@", numberAfterClear]];
    if ([[UIApplication sharedApplication] canOpenURL:phoneNumberURL] == NO)
    {
        HDLog(@"not can call");
        return NO;
	}
	return [[UIApplication sharedApplication] openURL:phoneNumberURL];
}


+ (NSString*)cleanPhoneNumber:(NSString*)phoneNumber
{
	NSString* number = [[[[[[phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""]
                            stringByReplacingOccurrencesOfString:@"-" withString:@""]
                           stringByReplacingOccurrencesOfString:@"(" withString:@""]
                          stringByReplacingOccurrencesOfString:@")" withString:@""]stringByReplacingOccurrencesOfString:@"+" withString:@""]
                            stringByReplacingOccurrencesOfString:@"\t" withString:@""];;
	return number;
}

+ (BOOL)checkHasNewVersionWithlocalVersion:(NSString *)localVersion
                             onlineVersion:(NSString *)onlineVersion
{
    NSArray *localNumberList = [localVersion componentsSeparatedByString:@"."];
    NSArray *onlineNumberList = [onlineVersion componentsSeparatedByString:@"."];
    int index = 0;
    for (NSString *online in onlineNumberList) {
        if (index < [localNumberList count]) {
            NSString *local = [localNumberList objectAtIndex:index];
            if ([online integerValue] > [local integerValue]) {
                return YES;
            }else if ([online integerValue] < [local integerValue]) {
                return NO;
            }
        } else {
            return YES;
        }
        index ++;
    }
    return NO;
}

+ (BOOL) adjustScreenToShowOrHideKeyBoard:(UIView *)view
                               flag:(BOOL) flag
                             offset:(CGFloat)offset
{
    if ([UIScreen mainScreen].bounds.size.height == 480) {
        if (flag == YES)
        {
            [UIView animateWithDuration:0.2 animations:^{
                CGPoint point = view.center;
                point.y = ([UIScreen mainScreen].bounds.size.height/2) - offset;
                [view setCenter:point];
            }];
            return YES;
        }
        else
        {
            [UIView animateWithDuration:0.1 animations:^{
                CGPoint point = view.center;
                point.y = ([UIScreen mainScreen].bounds.size.height/2);
                [view setCenter:point];
            }];
            
            return NO;
        }
    }
    
    return flag;
}

@end
