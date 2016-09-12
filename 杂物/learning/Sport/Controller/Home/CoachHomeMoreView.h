//
//  CoachHomeMoreView.h
//  Sport
//
//  Created by qiuhaodong on 15/7/20.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CoachHomeMoreViewDelegate <NSObject>
@optional
- (void)didClickCoachHomeMoreViewMessageButton;
- (void)didClickCoachHomeMoreViewMyOrderButton;
@end

@interface CoachHomeMoreView : UIView

+ (void)showInView:(UIView *)view delegate:(id<CoachHomeMoreViewDelegate>)delegate;

+ (BOOL)removeFromView:(UIView *)view;

@end
