//
//  NSDictionary+JsonValidValue.h
//  Coach
//
//  Created by qiuhaodong on 15/6/27.
//  Copyright (c) 2015年 ningmi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JsonValidValue)

- (NSString *)validStringValueForKey:(NSString *)key;

- (int)validIntValueForKey:(NSString *)key;

- (float)validFloatValueForKey:(NSString *)key;

- (double)validDoubleValueForKey:(NSString *)key;

- (NSArray *)validArrayValueForKey:(NSString *)key;

- (NSDictionary *)validDictionaryValueForKey:(NSString *)key;

- (NSDate *)validDateValueForKey:(NSString *)key;

- (BOOL)validBoolValueForKey:(NSString *)key;


@end
