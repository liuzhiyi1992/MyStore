//
//  CoachBaseView.h
//  Sport
//
//  Created by qiuhaodong on 15/7/22.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CoachBaseViewDelegate <NSObject>
@optional
- (void)didClickCoachBaseViewAvatar;

@end

@class Coach;

@interface CoachBaseView : UIView

+ (CoachBaseView *)createViewWithCoach:(Coach *)coach
                              delegate:(id<CoachBaseViewDelegate>)delegate;

@end
