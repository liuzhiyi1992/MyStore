//
//  NSObject+TabTitleButton.m
//  Sport
//
//  Created by 江彦聪 on 15/6/6.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "NSObject+TabTitleButton.h"
#import <objc/runtime.h>

static const void *leftButtonKey = &leftButtonKey;
static const void *rightButtonKey = &rightButtonKey;
static const void *titleLabelKey = &titleLabelKey;
@implementation NSObject (TabTitleButton)

@dynamic leftTitleButton;
@dynamic rightTitleButton;
@dynamic titleLabel;

- (UIButton *)leftTitleButton {
    return objc_getAssociatedObject(self, leftButtonKey);
}

- (UIButton *)rightTitleButton {
    return objc_getAssociatedObject(self, rightButtonKey);
}

- (UILabel *)titleLabel {
    return objc_getAssociatedObject(self, titleLabelKey);
}

- (void)setLeftTitleButton:(UIButton *)leftTitleButton {
    objc_setAssociatedObject(self, leftButtonKey, leftTitleButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setRightTitleButton:(UIButton *)rightTitleButton {
    objc_setAssociatedObject(self, rightButtonKey, rightTitleButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setTitleLabel:(UILabel *)titleLabel {
    objc_setAssociatedObject(self, titleLabelKey, titleLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
