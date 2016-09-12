//
//  PriceUtil.m
//  Sport
//
//  Created by haodong  on 14-8-21.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "PriceUtil.h"

@implementation PriceUtil

//返回有效金额，如果是小数为零则不显示小数，如果有一位则只显示一位，最多只显示两位
+ (NSString *)toValidPriceString:(double)price
{
    if (price - (int)price == 0) {
        return [NSString stringWithFormat:@"%d", (int)price];
    } else {
        float decimal = price - (int)price;
        float tem = decimal * 10.0;
        if (tem - (int)tem == 0) {
            return [NSString stringWithFormat:@"%.1f", price];
        } else {
            return [NSString stringWithFormat:@"%.2f", price];
        }
    }
}

+ (NSString *) toPriceStringWithYuan:(double)price
{
    return [NSString stringWithFormat:@"%@元", [PriceUtil toValidPriceString:price]];
}

@end
