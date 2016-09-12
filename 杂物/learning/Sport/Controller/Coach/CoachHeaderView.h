//
//  CoachHeaderView.h
//  Sport
//
//  Created by 江彦聪 on 15/7/15.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CoachHeaderViewDelegate <NSObject>

@optional
-(void)didClickButton;

@end

@class Order;
@class Coach;

@interface CoachHeaderView : UIView
@property (assign, nonatomic) id<CoachHeaderViewDelegate> delegate;
+ (CoachHeaderView *)createViewWithFrame:(CGRect)frame;
-(void)updateWithOrder:(Order *)order;
-(void)updateWithCoach:(Coach *)coach;
-(void)showWithSuperView:(UIView *)superView
              secondView:(UIView *)secondView;
-(void)hideArrow;
@end
