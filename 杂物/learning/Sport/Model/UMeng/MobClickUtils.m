//
//  MobClickUtils.m
//  Sport
//
//  Created by haodong  on 13-8-1.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "MobClickUtils.h"
#import "MobClick.h"

@implementation MobClickUtils

//+ (int)getIntValueByKey:(NSString*)key defaultValue:(int)defaultValue
//{
//    NSString* value = [MobClick getConfigParams:key];
//    if (value == nil || [value length] == 0){
//        return defaultValue;
//    }
//    
//    return [value intValue];
//}
//
//+ (double)getDoubleValueByKey:(NSString*)key defaultValue:(double)defaultValue
//{
//    NSString* value = [MobClick getConfigParams:key];
//    if (value == nil || [value length] == 0){
//        return defaultValue;
//    }
//    return [value doubleValue];
//}
//
//+ (CGFloat)getFloatValueByKey:(NSString*)key defaultValue:(CGFloat)defaultValue
//{
//    NSString* value = [MobClick getConfigParams:key];
//    if (value == nil || [value length] == 0){
//        return defaultValue;
//    }
//    return [value floatValue];
//}
//
//+ (NSString*)getStringValueByKey:(NSString*)key defaultValue:(NSString*)defaultValue
//{
//    NSString* value = [MobClick getConfigParams:key];
//    if (value == nil || [value length] == 0){
//        return defaultValue;
//    }
//    
//    return value;
//}
//
//+ (int)getBoolValueByKey:(NSString*)key defaultValue:(BOOL)defaultValue
//{
//    NSString* value = [MobClick getConfigParams:key];
//    if (value == nil || [value length] == 0){
//        return defaultValue;
//    }
//    
//    return ([value intValue] != 0);
//}

+ (void)event:(NSString *)eventId
{
    [self event:eventId label:nil];
}



+ (void)event:(NSString *)eventId label:(NSString *)label
{
    
#ifdef DEBUG
    HDLog(@"MobClick Event Debug:%@-%@", eventId, label);
#else
  //  NSLog(@"MobClick Event:%@-%@", eventId, label);
    
    //友盟统计
    [MobClick event:eventId label:label];
    
#endif
}

+ (void)beginLogPageView:(NSString *)pageName
{
    
#ifdef DEBUG
    
#else
    [MobClick beginLogPageView:pageName];
#endif
    
}

+ (void)endLogPageView:(NSString *)pageName
{
    
#ifdef DEBUG
    
#else
    [MobClick endLogPageView:pageName];
#endif
    
}

+ (void)beginEvent:(NSString *)eventId label:(NSString *)label {
#ifdef DEBUG
    HDLog(@"MobClick EventBegin Debug:%@-%@", eventId, label);
#else
    [MobClick beginEvent:eventId label:label];
#endif
}

+ (void)beginEvent:(NSString *)eventId {
    [self beginEvent:eventId label:nil];
}

+ (void)endEvent:(NSString *)eventId label:(NSString *)label {
#ifdef DEBUG
    HDLog(@"MobClick EventEnd Debug:%@-%@", eventId, label);
#else
    [MobClick endEvent:eventId label:label];
#endif
}

+ (void)endEvent:(NSString *)eventId {
    [self endEvent:eventId label:nil];
}

@end
