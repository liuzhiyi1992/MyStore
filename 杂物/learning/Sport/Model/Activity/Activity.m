//
//  Activity.m
//  Sport
//
//  Created by haodong  on 14-2-24.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "Activity.h"
#import "ActivityPromise.h"

@implementation Activity

+ (NSString *)themeName:(NSInteger)theme
{
    switch (theme) {
        case ActivityTheme0:
            return @"一起玩";
            break;
        case ActivityTheme1:
            return @"比一比";
            break;
        case ActivityTheme2:
            return @"教教我";
            break;
        case ActivityTheme3:
            return @"交朋友";
            break;
        default:
            return @"全部";
            break;
    }
}

+ (NSString *)costName:(CostType)costType
{
    switch (costType) {
        case CostTypeAA:
            return @"AA制";
            break;
        case CostTypeInitiator:
            return @"我请客";
            break;
        case CostTypeInvitees:
            return @"你买单";
            break;
        default:
            return @"AA制";
            break;
    }
}

+ (NSString *)sportLevelName:(NSInteger)sportLevel
{
    switch (sportLevel) {
        case SportLevel1:
            return @"菜鸟";
            break;
        case SportLevel2:
            return @"入门";
            break;
        case SportLevel3:
            return @"一般";
            break;
        case SportLevel4:
            return @"高手";
            break;
        default:
            return @"不限";
            break;
    }
}

- (NSString *)statusString
{
    switch (self.stauts) {
        case 0:
            return @"";
            break;
        case 1:
            return @"结束";
            break;
        case 2:
            return @"结束";
            break;
        case 3:
            return @"结束";
            break;
        default:
            return @"未知";
            break;
    }
}

- (int)agreePromiseCount
{
    int count = 0;
    for (ActivityPromise *promise in self.promiseList) {
        if (promise.status == ActivityPromiseStatusAgreed){
            count ++;
        }
    }
    return count;
}

@end
