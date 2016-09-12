//
//  TypeConversion.m
//  Sport
//
//  Created by qiuhaodong on 16/5/14.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "TypeConversion.h"

@implementation TypeConversion

+ (NSString *)toStringFromDictionary:(NSDictionary *)dictionary
{
    if (dictionary == nil) {
        return nil;
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return string;
}

+ (NSDictionary *)toDictionaryFromString:(NSString *)string
{
    if (string.length == 0) {
        return nil;
    }
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:nil];
    return dictionary;
}

@end
