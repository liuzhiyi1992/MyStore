//
//  NSDate+Correct.m
//  Sport
//
//  Created by qiuhaodong on 15/7/31.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "NSDate+Correct.h"
#import "AppGlobalDataManager.h"

@implementation NSDate (Correct)

+ (NSDate *)correctDate
{
    double timeDifference = [[AppGlobalDataManager defaultManager] timeDifference];
    return [NSDate dateWithTimeIntervalSinceNow:timeDifference];
}

@end
