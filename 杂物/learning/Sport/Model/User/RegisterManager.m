//
//  RegisterManager.m
//  Sport
//
//  Created by haodong  on 13-6-7.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "RegisterManager.h"

#define KEY_VERIFICATION    @"KEY_VERIFICATION"
#define KEY_CODE            @"KEY_CODE"
#define KEY_TIME            @"KEY_TIME"
#define KEY_PHONE_NUMBER    @"KEY_PHONE_NUMBER"

#define MAX_VALID_SECONDS   (20 * 60)

static RegisterManager *_globalRegisterManager = nil;

@implementation RegisterManager


+ (RegisterManager *)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _globalRegisterManager = [[RegisterManager alloc] init];
    });
    return _globalRegisterManager;
}

+ (BOOL)saveVerification:(NSString *)verification
{
    NSDictionary *dic = nil;
    if ([verification length] > 0) {
         dic = @{KEY_CODE: verification,
                 KEY_TIME: [NSDate date] 
                 };
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:dic forKey:KEY_VERIFICATION];
    
    return [defaults synchronize];
}


#define VERIFICATION_ERROR_DOMAIN   @"VERIFICATION_ERROR_DOMAIN"
+ (NSString *)readVerification:(NSError **)error
{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_VERIFICATION];
    
    if (dic == nil || [dic objectForKey:KEY_CODE] == nil) {
        if (error) {
            NSDictionary *userInfo  = [NSDictionary dictionaryWithObjectsAndKeys:@"kVerificationUnknow",NSLocalizedDescriptionKey, nil];
            *error = [NSError errorWithDomain:VERIFICATION_ERROR_DOMAIN code:VerificationErrorUnknow userInfo:userInfo];
        }
        return nil;
    }
    NSDate * saveDate = [dic objectForKey:KEY_TIME];
    if (saveDate != nil
        && [[NSDate date] timeIntervalSince1970] - [saveDate timeIntervalSince1970] > MAX_VALID_SECONDS) {
        if (error) {
            NSDictionary *userInfo  = [NSDictionary dictionaryWithObjectsAndKeys:@"kVerificationInvalid",NSLocalizedDescriptionKey, nil];
            *error = [NSError errorWithDomain:VERIFICATION_ERROR_DOMAIN code:VerificationErrorInvalid userInfo:userInfo];
        }
        return nil;
    }
    
    if (error) {
        *error = [NSError errorWithDomain:VERIFICATION_ERROR_DOMAIN code:VerificationErrorSucc userInfo:nil];
    }
    NSString *verification = [dic objectForKey:KEY_CODE];
    return verification;
}

#define KEY_SEND_VERIFICATION_COUNT    @"KEY_SEND_VERIFICATION_COUNT"
+ (BOOL)addOneSendVerificationCount:(int)type
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *todayString = [dateFormatter stringFromDate:[NSDate date]];
    NSString *key = [NSString stringWithFormat:@"%d_%@", type, todayString];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *tempDic = (NSDictionary *)[defaults objectForKey:KEY_SEND_VERIFICATION_COUNT];
    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionaryWithDictionary:tempDic];
    if (mutableDic == nil) {
        mutableDic = [NSMutableDictionary dictionary];
        [mutableDic setObject:[NSNumber numberWithUnsignedInteger:1] forKey:key];
    } else {
        NSNumber *countNumber = [mutableDic objectForKey:key];
        NSUInteger count = [countNumber unsignedIntegerValue];
        count ++;
        [mutableDic setObject:[NSNumber numberWithUnsignedInteger:count] forKey:key];
    }
    [defaults setObject:mutableDic forKey:KEY_SEND_VERIFICATION_COUNT];
    return [defaults synchronize];
}

+ (NSUInteger)hasSendVerificationCount:(int)type
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *todayString = [dateFormatter stringFromDate:[NSDate date]];
    NSString *key = [NSString stringWithFormat:@"%d_%@", type, todayString];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dic = [defaults objectForKey:KEY_SEND_VERIFICATION_COUNT];
    NSNumber *countNumber = [dic objectForKey:key];
    NSUInteger count = [countNumber unsignedIntegerValue];
    
    HDLog(@"today send count:%d", (int)count);
    return count;
}

@end
