//
//  UIViewController+Sport.m
//  Sport
//
//  Created by haodong  on 13-9-18.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "UIViewController+Sport.h"

@implementation UIViewController (Sport)

- (UILabel *)createNoDataTipsLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, (416 - 30)/2, [UIScreen mainScreen].bounds.size.width, 30)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:87.0/255.0 green:97.0/255.0 blue:113.0/255.0 alpha:1];
    label.font = [UIFont systemFontOfSize:15];
    return label;
}

@end
