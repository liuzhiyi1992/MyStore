//
//  BusinessListFilterButtonsView.m
//  Sport
//
//  Created by qiuhaodong on 16/8/3.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "BusinessListFilterButtonsView.h"
#import "UIView+CreateViewFromXib.h"

@interface BusinessListFilterButtonsView()
@property (weak, nonatomic) id<BusinessListFilterButtonsViewDelegate> delegate;
@end

@implementation BusinessListFilterButtonsView

+ (BusinessListFilterButtonsView *)showInSuperView:(UIView *)superView
                                          delegate:(id<BusinessListFilterButtonsViewDelegate>)delegate {
    for (UIView *one in superView.subviews) {
        if ([one isKindOfClass:[BusinessListFilterButtonsView class]]) {
            [(BusinessListFilterButtonsView *)one removeFromSuperview];
        }
    }
    
    BusinessListFilterButtonsView *view = [self createXibView:@"BusinessListFilterButtonsView"];
    view.delegate = delegate;
    
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
    [superView addConstraint:l1];
    
    NSLayoutConstraint *l2 =[NSLayoutConstraint
                             constraintWithItem:view
                             attribute:NSLayoutAttributeTrailing
                             relatedBy:NSLayoutRelationEqual
                             toItem:superView
                             attribute:NSLayoutAttributeTrailing
                             multiplier:1
                             constant:0];
    [superView addConstraint:l2];
    
    NSLayoutConstraint *l3 = [NSLayoutConstraint
                              constraintWithItem:view
                              attribute:NSLayoutAttributeTop
                              relatedBy:NSLayoutRelationEqual
                              toItem:superView
                              attribute:NSLayoutAttributeTop
                              multiplier:1
                              constant:0];
    [superView addConstraint:l3];
    
    NSLayoutConstraint *l4 = [NSLayoutConstraint
                              constraintWithItem:view
                              attribute:NSLayoutAttributeHeight
                              relatedBy:NSLayoutRelationEqual
                              toItem:view
                              attribute:NSLayoutAttributeHeight
                              multiplier:0
                              constant:45];
    [view addConstraint:l4];
    return view;
}

#define BUTTON_BASE_TAG 100
- (void)updateWithTitleArray:(NSArray *)titleArray {
    for (int i = 0; i < 4 ; i ++) {
        UIButton *button = (UIButton *)[self viewWithTag:BUTTON_BASE_TAG + i];
        button.selected = NO;
        NSString *title = nil;
        if (i < [titleArray count]) {
            title = [titleArray objectAtIndex:i];
        }
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateSelected];
        
        CGSize size = [title sizeWithAttributes:@{NSFontAttributeName:button.titleLabel.font}];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, size.width + 1, 0, - size.width - 1)];
    }
}

- (IBAction)clickButton:(id)sender {
    UIButton *currentButton = (UIButton *)sender;
    NSUInteger index = currentButton.tag - BUTTON_BASE_TAG;
    currentButton.selected = !currentButton.selected;
    
    if ([self.delegate respondsToSelector:@selector(didClickBusinessListFilterButtonsView:isOpen:)]) {
        [self.delegate didClickBusinessListFilterButtonsView:index isOpen:currentButton.selected];
    }
    
    //取消其他的选择
    for (int i = 0; i < 4 ; i ++) {
        UIButton *button = (UIButton *)[self viewWithTag:BUTTON_BASE_TAG + i];
        if (i != index) {
            button.selected = NO;
        }
    }
}

@end
