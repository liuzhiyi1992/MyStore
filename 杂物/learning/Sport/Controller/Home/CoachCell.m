//
//  CoachCell.m
//  Sport
//
//  Created by qiuhaodong on 15/7/17.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CoachCell.h"
#import "Coach.h"
#import "CoachView.h"
#import "UIView+Utils.h"

@interface CoachCell() <CoachViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *firstHolderView;
@property (weak, nonatomic) IBOutlet UIView *secondHodlerView;

@end

@implementation CoachCell

+ (NSString *)getCellIdentifier
{
    return @"CoachCell";
}

+ (CGFloat)getCellHeight
{
    return [CoachView defaultSize].height + 10;
}

+ (id)createCell
{
    CoachCell *cell = [super createCell];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.firstHolderView.frame = CGRectMake(cell.firstHolderView.frame.origin.x, cell.firstHolderView.frame.origin.y, [CoachView defaultSize].width, [CoachView defaultSize].height);
    CGFloat secondX = cell.firstHolderView.frame.origin.x + cell.firstHolderView.frame.size.width + 10;
    cell.secondHodlerView.frame = CGRectMake(secondX, cell.secondHodlerView.frame.origin.y, [CoachView defaultSize].width, [CoachView defaultSize].height);
    return cell;
}

- (void)updateCellWithFirstCoach:(Coach *)firstCoach secondCoach:(Coach *)secondCoach
{
    [self updateHolderView:self.firstHolderView coach:firstCoach];
    [self updateHolderView:self.secondHodlerView coach:secondCoach];
    
}

#define TAG_COACHVIEW 2015071701
- (void)updateHolderView:(UIView *)holderView coach:(Coach *)coach
{
    if (coach) {
        holderView.hidden = NO;
        CoachView *coachView = (CoachView *)[holderView viewWithTag:TAG_COACHVIEW];
        if (coachView == nil) {
            coachView = [CoachView createCoachView:self];
            coachView.tag = TAG_COACHVIEW;
            [holderView addSubview:coachView];
            
            coachView.frame = holderView.bounds;
        }
        [coachView updateViewWithCoach:coach];
    } else {
        holderView.hidden = YES;
    }
}

- (void)didClickCoachView:(Coach *)coach
{
    if ([_delegate respondsToSelector:@selector(didClickCoachCell:)]) {
        [_delegate didClickCoachCell:coach];
    }
}

@end
