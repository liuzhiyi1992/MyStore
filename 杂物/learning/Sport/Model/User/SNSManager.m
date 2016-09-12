//
//  SNSManager.m
//  Sport
//
//  Created by haodong  on 13-9-30.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SNSManager.h"

static SNSManager *_globalSNSManager = nil;

@implementation SNSManager


+ (SNSManager *)defaultManager
{
    if (_globalSNSManager == nil) {
        _globalSNSManager  = [[SNSManager alloc] init];
    }
    return _globalSNSManager;
}

+ (void)sinaAuthorize
{
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = SINA_REDIRECT_URI;
    request.scope = @"email,direct_messages_write, direct_messages_read,invitation_write, friendships_groups_read, friendships_groups_write, statuses_to_me_read";
    request.userInfo = nil;
    //    request.userInfo = @{@"SSO_From": @"SendMessageToWeiboViewController",
    //                         @"Other_Info_1": [NSNumber numberWithInt:123],
    //                         @"Other_Info_2": @[@"obj1", @"obj2"],
    //                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    [WeiboSDK sendRequest:request];
}

+ (BOOL)isSinaAuthorize
{
    if ([self readSinaAccessToken] != nil)
        return YES;
    else
        return NO;
}

#define KEY_SINA_ACCESS_TOKEN  @"KEY_SINA_ACCESS_TOKEN"
+ (BOOL)saveSinaAccessToken:(NSString *)sinaAccessToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:sinaAccessToken forKey:KEY_SINA_ACCESS_TOKEN];
    return [defaults synchronize];
}

+ (NSString *)readSinaAccessToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults valueForKey:KEY_SINA_ACCESS_TOKEN];
}

@end


