//
//  CourtJoin.m
//  Sport
//
//  Created by Huan on 16/6/7.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "CourtJoin.h"
#import "Product.h"
#import "PriceUtil.h"

@implementation CourtJoin
- (NSDictionary *)createCourtJoinGroup
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for (Product *product in self.productList) {
        NSString *key = product.courtName;
        NSMutableArray *value = [NSMutableArray arrayWithArray:(NSArray *)[dictionary objectForKey:key]];
        
        NSMutableString *oneItem = [NSMutableString stringWithString:[product startTimeToEndTime]];
        
        [oneItem appendFormat:@" %@元", [PriceUtil toValidPriceString:product.courtJoinPrice]];
        
        [value addObject:oneItem];
        
        [dictionary setObject:value forKey:key];
    }
    return dictionary;
}
@end
