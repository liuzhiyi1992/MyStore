//
//  CLLocation+Util.m
//  Sport
//
//  Created by qiuhaodong on 15/7/17.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CLLocation+Util.h"

@implementation CLLocation (Util)

- (NSString *)distanceStringValueFromLocation:(CLLocation *)location
{
    CLLocationDistance distance = [self distanceFromLocation:location];
    if (self == nil || location == nil || [self isCoordinateZero] || [location isCoordinateZero] || ![self isValid] || ![location isValid]) {
        return nil;
    } else {
        if (distance <= 9.4) {
            return [NSString stringWithFormat:@"%.0fm", distance];
        }else if (distance <= 994){
            return [NSString stringWithFormat:@"%.0fm", roundf(distance / 10) * 10];
        }else if (distance <= 99400){
            return [NSString stringWithFormat:@"%.1fkm", round(distance / 1000 * 10) / 10];
        }else{
            return @">100km";
        }
    }
}

//坐标是否为0
- (BOOL)isCoordinateZero
{
    return ((int)self.coordinate.latitude == 0
            && (int)self.coordinate.longitude == 0);
}

//判断是否有效位置
- (BOOL)isValid
{
    return (-90 <= self.coordinate.latitude && self.coordinate.latitude <= 90
            && -180 <= self.coordinate.longitude && self.coordinate.longitude <= 180);
}

@end
