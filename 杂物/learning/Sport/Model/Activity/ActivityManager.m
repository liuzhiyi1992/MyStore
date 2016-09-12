//
//  ActivityManager.m
//  Sport
//
//  Created by haodong  on 14-4-29.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "ActivityManager.h"
#import "Activity.h"

static ActivityManager *_globalActivityManager = nil;

@implementation ActivityManager

+ (id)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_globalActivityManager == nil) {
            _globalActivityManager = [[ActivityManager alloc] init];
        }
    });
    return _globalActivityManager;
}

- (NSDictionary *)themeDictionary
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[Activity themeName:ActivityTheme0] forKey:[NSString stringWithFormat:@"%d", ActivityTheme0]];
    [dic setObject:[Activity themeName:ActivityTheme1] forKey:[NSString stringWithFormat:@"%d", ActivityTheme1]];
    [dic setObject:[Activity themeName:ActivityTheme2] forKey:[NSString stringWithFormat:@"%d", ActivityTheme2]];
    [dic setObject:[Activity themeName:ActivityTheme3] forKey:[NSString stringWithFormat:@"%d", ActivityTheme3]];
    return dic;
}

- (NSDictionary *)activitySortDictionary
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"默认" forKey:@"0"];
    [dic setObject:@"离我最近" forKey:@"1"];
    [dic setObject:@"最受欢迎" forKey:@"2"];
    return dic;
}

- (NSDictionary *)peopleSortDictionary
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"默认" forKey:@"0"];
    [dic setObject:@"距离" forKey:@"1"];
    [dic setObject:@"热门" forKey:@"2"];
    return dic;
}

@end
