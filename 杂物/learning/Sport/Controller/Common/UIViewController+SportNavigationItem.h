//
//  UIViewController+SportNavigationItem.h
//  Sport
//
//  Created by qiuhaodong on 15/5/26.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

// 为Catogery添加property
#import "NSObject+TabTitleButton.h"

@interface UIViewController (SportNavigationItem)

- (void)createRightTopButton:(NSString *)buttonTitle;
- (void)createRightTopImageButton:(UIImage *)buttonImage;
- (void)clickRightTopButton:(id)sender;
- (void)cleanRightTopButton;

- (void)createLeftTopButton:(NSString *)buttonTitle;
- (void)createLeftTopImageButton:(UIImage *)buttonImage;
- (void)clickLeftTopButton:(id)sender;
- (void)cleanLeftTopButton;

- (void)showRightTopTipsCount:(NSUInteger)count;
- (void)hideRightTopTipsCount;

- (void)showRightTopRedPoint;
- (void)hideRightTopRedPoint;

- (void)showLeftTopTipsCount:(NSUInteger)count;
- (void)hideLeftTopTipsCount;

- (void)showLeftTopRedPoint;
- (void)hideLeftTopRedPoint;

- (void)createTitleViewWithleftButtonTitle:(NSString *)leftButtonTitle
                          rightButtonTitle:(NSString *)rightButtonTitle;
- (void)clickLeftTitleButton:(id)sender;
- (void)clickRightTitleButton:(id)sender;
- (void)selectedLeftButton;
- (void)selectedRightButton;
- (void)createTitleView;
- (void)createBackButton;
- (void)clickBackButton:(id)sender;

- (void)showLeftTitleTipsCount:(NSUInteger)count;
- (void)showRightTitleTipsCount:(NSUInteger)count;
- (void)hideLeftTitleTipsCount;
- (void)hideRightTitleTipsCount;

@end
