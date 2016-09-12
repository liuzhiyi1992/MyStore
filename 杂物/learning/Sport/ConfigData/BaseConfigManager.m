//
//  BaseConfigManager.m
//  Sport
//
//  Created by haodong  on 14-6-3.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "BaseConfigManager.h"
#import "PayMethod.h"
#import "UIUtils.h"

static BaseConfigManager *_globalBaseConfigManager= nil;

@implementation BaseConfigManager

- (NSArray *)payMethodList
{
    if ([_payMethodList count] == 0) { //如果没有获取到支付方式，则默认三种支付方式
        PayMethod *method0 = [[PayMethod alloc] init] ;
        method0.payId = @"10";
        method0.payKey = PAY_METHOD_WEIXIN;
        method0.isRecommend = NO;
        
        PayMethod *method1 = [[PayMethod alloc] init] ;
        method1.payId = @"12";
        method1.payKey = PAY_METHOD_ALIPAY_CLIENT;
        method1.isRecommend = YES;
        
        PayMethod *method2 = [[PayMethod alloc] init] ;
        method2.payId = @"13";
        method2.payKey = PAY_METHOD_ALIPAY_WAP;
        method2.isRecommend = NO;
        
        //默认支付宝客户端在第一位，去掉支付宝网页支付，2016-05-17
        NSArray *list = [[NSArray alloc] initWithObjects:method1, method0, nil] ;
        return list;
    } else {
        return _payMethodList;
    }
}


+ (BaseConfigManager *)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _globalBaseConfigManager = [[BaseConfigManager alloc] init];
    });
    return _globalBaseConfigManager;
}

#define KEY_DOWNLOADED_STARTUP_IMAGE_URL    @"KEY_DOWNLOADED_STARTUP_IMAGE_URL"
+ (BOOL)saveDownloadedStartupImageUrl:(NSString *)downloadedStartupImageUrl
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:downloadedStartupImageUrl forKey:KEY_DOWNLOADED_STARTUP_IMAGE_URL];
    return [defaults synchronize];
}

+ (NSString *)readDownloadedStartupImageUrl
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:KEY_DOWNLOADED_STARTUP_IMAGE_URL];
}

+ (BOOL)currentVersionIsInReView
{
    NSString *currentVersion = [UIUtils getAppVersion];
    NSString *inReviewVersionString = [[BaseConfigManager defaultManager] inReviewVersion];
    if (inReviewVersionString == nil) { //如果获取配置数据为空，则默认当作是当前审核版本
        return YES;
    } else {
        return [currentVersion isEqualToString:inReviewVersionString];
    }
}

@end
