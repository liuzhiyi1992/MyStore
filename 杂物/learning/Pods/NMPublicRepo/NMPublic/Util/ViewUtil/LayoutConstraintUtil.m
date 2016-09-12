//
//  LayoutConstraintUtil.m
//  Sport
//
//  Created by xiaoyang on 16/5/18.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "LayoutConstraintUtil.h"

@implementation LayoutConstraintUtil

+ (void)view:(UIView *)view addConstraintsWithSuperView:(UIView *)superView {
    
    [superView addSubview:view];
    
    view.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *l1 =[NSLayoutConstraint
     constraintWithItem:view
     attribute:NSLayoutAttributeLeading
     relatedBy:NSLayoutRelationEqual
     toItem:superView
     attribute:NSLayoutAttributeLeading
     multiplier:1
     constant:0];
//    l1.priority = 1;
    
    [superView addConstraint:l1];
    
    NSLayoutConstraint *l2 =[NSLayoutConstraint
                             constraintWithItem:view
                             attribute:NSLayoutAttributeTrailing
                             relatedBy:NSLayoutRelationEqual
                             toItem:superView
                             attribute:NSLayoutAttributeTrailing
                             multiplier:1
                             constant:0];
//    l2.priority = 250;
    [superView addConstraint:l2];
    
    NSLayoutConstraint *l3 = [NSLayoutConstraint
                              constraintWithItem:view
                              attribute:NSLayoutAttributeTop
                              relatedBy:NSLayoutRelationEqual
                              toItem:superView
                              attribute:NSLayoutAttributeTop
                              multiplier:1
                              constant:0];
    l3.priority = 250;
    [superView addConstraint:l3];
    
    NSLayoutConstraint *l4 = [NSLayoutConstraint
                              constraintWithItem:view
                              attribute:NSLayoutAttributeBottom
                              relatedBy:NSLayoutRelationEqual
                              toItem:superView
                              attribute:NSLayoutAttributeBottom
                              multiplier:1
                              constant:0];
    l4.priority = 250;
    [superView addConstraint:l4];
}

@end
