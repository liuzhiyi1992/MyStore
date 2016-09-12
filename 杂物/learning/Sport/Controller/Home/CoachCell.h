//
//  CoachCell.h
//  Sport
//
//  Created by qiuhaodong on 15/7/17.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@class Coach;

@protocol CoachCellDelegate <NSObject>
@optional
- (void)didClickCoachCell:(Coach *)coach;
@end

@interface CoachCell : DDTableViewCell

@property (assign, nonatomic) id<CoachCellDelegate> delegate;

- (void)updateCellWithFirstCoach:(Coach *)firstCoach secondCoach:(Coach *)secondCoach;

@end
