//
//  JudgeImageView.h
//  Coach
//
//  Created by quyundong on 15/6/30.
//  Copyright (c) 2015年 ningmi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JudgeImageViewDelegate <NSObject>
@optional

- (void)didClickJudgeButtonWithRank:(int)rank;

@end

@interface JudgeImageView : UIView
@property (weak,nonatomic) id<JudgeImageViewDelegate>delegate;
+ (JudgeImageView *)createJudgeImageView;
-(void)updateViewWithMark:(float)mark;
@end
