//
//  PriceUtil.h
//  Sport
//
//  Created by haodong  on 14-8-21.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PriceUtil : NSObject

//返回有效金额，如果是小数为零则不显示小数，如果有一位则只显示一位，最多只显示两位
+ (NSString *)toValidPriceString:(double)price;
+ (NSString *)toPriceStringWithYuan:(double)price;

@end
