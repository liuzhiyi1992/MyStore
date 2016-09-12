//
//  UIView+SportBackground.m
//  Sport
//
//  Created by qiuhaodong on 15/6/10.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "UIView+SportBackground.h"

@implementation UIView (SportBackground)

- (void)sportUpdateAllBackground
{
    [self updateAllBackgroundWithView:self];
}

#define TAG_LINE_IMAGE_VIEW             100 //横线
#define TAG_LINE_VERTICAL_IMAGE_VIEW    101 //竖线
#define TAG_BACKGROUND_IMAGE_VIEW       200 //白色方角背景，上下有横线

- (void)updateAllBackgroundWithView:(UIView *)view
{
    NSString *className = NSStringFromClass(view.class);
    if (view == self
        || [className isEqualToString:@"UIView"]
        || [className isEqualToString:@"UIScrollView"]
        || [className isEqualToString:@"UIControl"]) {
        for (UIView *subView in view.subviews) {
            [self updateAllBackgroundWithView:subView];
        }
    } else if ([className isEqualToString:@"UIImageView"]) {
        if (view.tag == TAG_LINE_IMAGE_VIEW) {
            [(UIImageView *)view setImage:[SportImage lineImage]];
        } else if (view.tag == TAG_LINE_VERTICAL_IMAGE_VIEW) {
            [(UIImageView *)view setImage:[SportImage lineVerticalImage]];
        } else if (view.tag == TAG_BACKGROUND_IMAGE_VIEW) {
            [(UIImageView *)view setImage:[SportImage whiteBackgroundImage]];
        }
    }
}

@end
