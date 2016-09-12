//
//  ConfigData.m
//  Sport
//
//  Created by haodong  on 13-8-1.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "ConfigData.h"
#import "MobClickUtils.h"
#import "BaseConfigManager.h"

@implementation ConfigData

+ (NSString *)defaultHost
{
    return API_SERVER_ADDRESS;
}

+ (NSString *)gsDefaultHost
{
    return GS_API_SERVER_ADDRESS;
}

+ (NSString *)forumHost
{
    return FORUM_SERVER_ADDRESS;
}

+ (NSString *)defaultAppKey
{
    return RONGCLOUD_IM_APPKEY;
}

+ (NSString *)businessCooperation
{
    return @"business@ningmi.net";
    //return [MobClickUtils getStringValueByKey:UMENG_ONLINE_BUSINESS_COOPERATION defaultValue:@"business@ningmi.net"];
}

+ (NSString *)shareAppText
{
    //return [MobClickUtils getStringValueByKey:UMENG_ONLINE_SHARE_APP_TEXT defaultValue:@"我在用<趣运动>手机客户端，随时随地订场、查看场馆优惠信息，想运动就用趣运动。推荐你试试哟"];
    return @"我在用<趣运动>手机客户端，随时随地订场、查看场馆优惠信息，想运动就用趣运动。推荐你试试哟";
}

+ (NSString *)website
{
    return @"http://www.quyundong.com";
//    return [MobClickUtils getStringValueByKey:UMENG_ONLINE_WEBSITE defaultValue:@"http://www.quyundong.com"];
}

+ (NSString *)customerServicePhone
{
    return @"4000-410-480";
//    return [MobClickUtils getStringValueByKey:UMENG_ONLINE_CUSTOMER_SERVICE_PHONE defaultValue:@"4000-410-480"];
}

//mark
+ (BOOL)isShowThirdPartyLogin
{
    return [BaseConfigManager defaultManager].isShowThirdPartyLogin;
//    return [MobClickUtils getBoolValueByKey:UMENG_ONLINE_IS_SHOW_THIRD_PARTY_LOGIN defaultValue:NO];
}

//+ (BOOL)currentVersionIsInReView
//{
//    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
//    NSString *inReviewVersionString = [MobClickUtils getStringValueByKey:UMENG_ONLINE_IN_REVIEW_APP_VERSION defaultValue:currentVersion];
//    return [currentVersion isEqualToString:inReviewVersionString];
//}

//mark
+ (BOOL)isCheckNewVersion
{
    return [BaseConfigManager defaultManager].isCheckNewVersion;
//    return [MobClickUtils getBoolValueByKey:UMENG_ONLINE_IS_CHECK_NEW_VERSION defaultValue:NO];
}



@end


/*
 @return @"ej34uk46"
 */
NSString *yi1g41gbicb74uci1u()
{
    char a[] = "f4v5"; //参照ascii码，"e3u4"每个加1;
    char b[] = "i3j5"; //参照ascii码，"j4k6"每个减1;
    char c[9] = {0};
    for (int i = 0 ; i < strlen(a) * 2 ; i ++ ) {
        int y = i % 2;
        int f = i / 2;
        if (y == 0) {
            c[i] = a[f] - 1;
        } else {
            c[i] = b[f] + 1;
        }
    }
    return [NSString stringWithUTF8String:c];
}


/*
 @return @"27wsp85p"
 */
NSString *feuyug1347hfjfh13j()
{
    char a[9] = {0};
    NSString *cl = NSStringFromClass([NSOperation class]);
    NSString *sub = [cl substringWithRange:NSMakeRange(9, 1)];
    const char *f = [sub cStringUsingEncoding:NSUTF8StringEncoding];
    char r[9] = "FIorvHC";
    char s[9] = {0}; //"CHvroIFo"->"27wsp85p" 大写代表数字，相对于A的偏移量就是值; 小写的都减1
    for (int i = 0, j = (int)(strlen(r)) - 1; j >=0; i ++, j --) {
        s[i] = r[j];
    }
    strcat(s, f);
    for (int i = 0; i < strlen(s); i++) {
        char e = s[i];
        if (e >= 'A' && e <= 'Z') {
            a[i] = '0' + (e - 'A');
        } else {
            a[i] = e + 1;
        }
    }
    return [NSString stringWithUTF8String:a];
}
