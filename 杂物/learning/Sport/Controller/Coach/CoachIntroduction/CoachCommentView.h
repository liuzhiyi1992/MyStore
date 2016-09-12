//
//  CoachCommentView.h
//  Sport
//
//  Created by qiuhaodong on 15/7/26.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CoachCommentViewDelegate <NSObject>
@optional
- (void)didClickCoachCommentViewAllCommentButton;
@end

@interface CoachCommentView : UIView

+ (CoachCommentView *)createViewWithCommentList:(NSArray *)commentList delegate:(id<CoachCommentViewDelegate>)delegate controller:(UIViewController *)controller;

@end
