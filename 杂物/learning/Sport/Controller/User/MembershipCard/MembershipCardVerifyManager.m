//
//  MembershipCardVerifyManager.m
//  Sport
//
//  Created by 江彦聪 on 15/4/17.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "MembershipCardVerifyManager.h"

static MembershipCardVerifyManager *_globalMembershipCardVerifyManager = nil;

@implementation MembershipCardVerifyManager


+ (MembershipCardVerifyManager *)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _globalMembershipCardVerifyManager = [[MembershipCardVerifyManager alloc] init];
    });
    return _globalMembershipCardVerifyManager;
}

@end
