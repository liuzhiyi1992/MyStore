//
//  BusinessCategory.m
//  Sport
//
//  Created by haodong  on 13-6-20.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "BusinessCategory.h"

@implementation BusinessCategory

- (NSString *)sportName
{
    if ([_name hasSuffix:@"场"]
        || [_name hasSuffix:@"馆"]
        || [_name hasSuffix:@"房"]
        || [_name hasSuffix:@"室"]) {
        NSUInteger len = [_name length];
        NSString *sportName = [_name substringToIndex:len - 1];
        return sportName;
    } else {
        return _name;
    }
}

@end
