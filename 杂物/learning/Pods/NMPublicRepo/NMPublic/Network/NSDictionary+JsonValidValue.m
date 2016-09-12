//
//  NSDictionary+JsonValidValue.m
//  Coach
//
//  Created by qiuhaodong on 15/6/27.
//  Copyright (c) 2015年 ningmi. All rights reserved.
//

#import "NSDictionary+JsonValidValue.h"

@implementation NSDictionary (JsonValidValue)

- (NSString *)validStringValueForKey:(NSString *)key
{
    id object = [self objectForKey:key];
    if ([object isKindOfClass:[NSString class]]) {
        return (NSString *)object;
    } else if ([object isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)object stringValue];
    } else {
        return nil;
    }
}

- (int)validIntValueForKey:(NSString *)key
{
    id object = [self objectForKey:key];
    if ([object isKindOfClass:[NSString class]]) {
        return [(NSString *)object intValue];
    } else if ([object isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)object intValue];
    } else {
        return 0;
    }
}

- (float)validFloatValueForKey:(NSString *)key
{
    id object = [self objectForKey:key];
    if ([object isKindOfClass:[NSString class]]) {
        return [(NSString *)object floatValue];
    } else if ([object isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)object floatValue];
    } else {
        return 0;
    }
}

- (double)validDoubleValueForKey:(NSString *)key
{
    id object = [self objectForKey:key];
    if ([object isKindOfClass:[NSString class]]) {
        return [(NSString *)object doubleValue];
    } else if ([object isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)object doubleValue];
    } else {
        return 0;
    }
}

- (NSArray *)validArrayValueForKey:(NSString *)key
{
    id object = [self objectForKey:key];
    if ([object isKindOfClass:[NSArray class]]) {
        return (NSArray *)object;
    } else {
        return nil;
    }
}

- (NSDictionary *)validDictionaryValueForKey:(NSString *)key
{
    id object = [self objectForKey:key];
    if ([object isKindOfClass:[NSDictionary class]]) {
        return (NSDictionary *)object;
    } else {
        return nil;
    }
}

- (NSDate *)validDateValueForKey:(NSString *)key
{
    int dateInt = [self validIntValueForKey:key];
    return [NSDate dateWithTimeIntervalSince1970:dateInt];
}

- (BOOL)validBoolValueForKey:(NSString *)key
{
    return ([self validIntValueForKey:key] != 0);
}


@end
