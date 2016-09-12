//
//  CoachView.h
//  Sport
//
//  Created by qiuhaodong on 15/7/16.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@class Coach;

@protocol CoachViewDelegate <NSObject>
@optional
- (void)didClickCoachView:(Coach *)coach;
@end

@interface CoachView : UIView

+ (CoachView *)createCoachView:(id<CoachViewDelegate>)delegate;

+ (CGSize)defaultSize;

- (void)updateViewWithCoach:(Coach *)coach;

@end
