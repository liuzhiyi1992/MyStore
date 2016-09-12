//
//  UIColor+HexColor.h
//  Coach
//
//  Created by qiuhaodong on 15/6/29.
//  Copyright (c) 2015年 ningmi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexColor)

+ (UIColor *)hexColor:(NSString *)hexColor;

+ (UIColor *)hexColor:(NSString *)hexColor withAlpha:(CGFloat)alpha;

@end
