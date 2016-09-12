//
//  XQueryComponents.m
//  Sport
//
//  Created by haodong  on 13-9-3.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "XQueryComponents.h"
#import "NSString+Utils.h"

@implementation NSString (XQueryComponents)
- (NSString *)stringByDecodingURLFormat
{
//    NSString *result = [self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
//    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *result = [self decodeURLString];
    
    return result;
}

- (NSString *)stringByEncodingURLFormat
{
//    NSString *result = [self stringByReplacingOccurrencesOfString:@" " withString:@"+"];
//    result = [result stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *result = [self encodedURLParameterString];
    
    return result;
}

- (NSMutableDictionary *)dictionaryFromQueryComponents
{
    NSMutableDictionary *queryComponents = [NSMutableDictionary dictionary];
    for(NSString *keyValuePairString in [self componentsSeparatedByString:@"&"])
    {
        NSArray *keyValuePairArray = [keyValuePairString componentsSeparatedByString:@"="];
        if ([keyValuePairArray count] < 2) continue; // Verify that there is at least one key, and at least one value.  Ignore extra = signs
        NSString *key = [[keyValuePairArray objectAtIndex:0] stringByDecodingURLFormat];
        NSString *value = nil;
        if ([keyValuePairArray count] == 2)
        {
            value = [[keyValuePairArray objectAtIndex:1] stringByDecodingURLFormat];
        }
        else
        {
            NSRange range = [keyValuePairString rangeOfString:@"="];
            if (range.location != NSNotFound) {
                NSInteger index = range.location + 1;
                if (index >= 0 && index < [keyValuePairString length]) {
                    value = [keyValuePairString substringFromIndex:range.location+1];
                }
            }
        }
        if (key.length != 0 &&  value.length != 0) {
            [queryComponents setObject:value forKey:key];
        }
        
    }
    return queryComponents;
}
@end

@implementation NSURL (XQueryComponents)
- (NSMutableDictionary *)queryComponents
{
    return [[self query] dictionaryFromQueryComponents];
}
@end

@implementation NSDictionary (XQueryComponents)
- (NSString *)stringFromQueryComponents
{
    NSString *result = nil;
    for(__strong NSString *key in [self allKeys])
    {
        key = [key stringByEncodingURLFormat];
        NSArray *allValues = [self objectForKey:key];
        if([allValues isKindOfClass:[NSArray class]])
            for(__strong NSString *value in allValues)
            {
                value = [[value description] stringByEncodingURLFormat];
                if(!result)
                    result = [NSString stringWithFormat:@"%@=%@",key,value];
                else
                    result = [result stringByAppendingFormat:@"&%@=%@",key,value];
            }
        else {
            NSString *value = [[allValues description] stringByEncodingURLFormat];
            if(!result)
                result = [NSString stringWithFormat:@"%@=%@",key,value];
            else
                result = [result stringByAppendingFormat:@"&%@=%@",key,value];
        }
    }
    return result;
}
@end

