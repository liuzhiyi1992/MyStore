//
//  Product.m
//  Sport
//
//  Created by haodong  on 13-7-17.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "Product.h"

@implementation Product

- (int)startTimeHour
{
    NSArray *timeValueList = [self.startTime componentsSeparatedByString:@":"];
    int hour = 0;
    if ([timeValueList count] == 2) {
        hour = [[timeValueList objectAtIndex:0] intValue];
    }
    return hour;
}

- (NSString *)startTimeMinuteString
{
    NSArray *timeValueList = [self.startTime componentsSeparatedByString:@":"];
    NSString *minuteString = nil;
    if ([timeValueList count] == 2) {
        minuteString = [timeValueList objectAtIndex:1];
    }
    return minuteString;
}

- (NSString *)startTimeToEndTime
{
    NSString *str = [NSString stringWithFormat:@"%@-%d:%@", self.startTime, [self startTimeHour] + 1, [self startTimeMinuteString]];
    return str;
}

- (BOOL)canBuy {
    if (self.status == ProductStatusCanOrder || self.courtJoinCanBuy) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isCourtJoinProduct {
    if (self.courtJoinId) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSString *) courtDetailString:(NSArray *)list {
    NSMutableString *courtTimeStr = [NSMutableString string];
    int index = 0;
    for (Product *product in list) {
        [courtTimeStr appendString:[NSString stringWithFormat:@"%@ %@", product.courtName, [product startTimeToEndTime]]];
        if (index < [list count] - 1) {
            [courtTimeStr appendString:@"\n"];
        }
        
        index++;
    }
    
    return courtTimeStr;
    
}

@end
