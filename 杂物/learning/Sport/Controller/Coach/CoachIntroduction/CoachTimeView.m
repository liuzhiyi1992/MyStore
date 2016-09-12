//
//  CoachTimeView.m
//  Sport
//
//  Created by qiuhaodong on 15/7/23.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CoachTimeView.h"
#import "UIView+Utils.h"
#import "CoachBookingInfo.h"
#import "DateUtil.h"
#import "NSDate+Utils.h"

#define TAG_BASE_TIMELABEL 10
#define TAG_BASE_DAYLABEL 10

@interface CoachTimeView()

@property (strong, nonatomic) NSArray *coachBookingInfoList;

@property (weak, nonatomic) IBOutlet UIView *canView;
@property (weak, nonatomic) IBOutlet UIView *canNotView;
@property (weak, nonatomic) IBOutlet UIView *timeHolderView;
@property (weak, nonatomic) IBOutlet UIView *dayHolderView;

@end

@implementation CoachTimeView


+ (CoachTimeView *)createViewWithCoachBookingInfoList:(NSArray *)coachBookingInfoList
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CoachTimeView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    CoachTimeView *view = [topLevelObjects objectAtIndex:0];
    view.coachBookingInfoList = coachBookingInfoList;
//    [view updateWidth:[UIScreen mainScreen].bounds.size.width];
//    view.canView.layer.cornerRadius = 2;
//    view.canView.layer.masksToBounds = YES;
//    view.canNotView.layer.cornerRadius = 2;
//    view.canNotView.layer.masksToBounds = YES;
    
    [view initWeeks];
    [view initTimes];
    [view initLineViews];
    
    return view;
}

#define COUNT   7
#define HEIGHT  43
#define WIDTH  ([UIScreen mainScreen].bounds.size.width / COUNT)
- (void)initWeeks
{
    for (int i = 0 ; i < COUNT ; i ++) {
        
        UILabel *label = (UILabel *)[self.dayHolderView viewWithTag:(TAG_BASE_DAYLABEL + i)];
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i * WIDTH, 0, WIDTH, HEIGHT)];
        
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor hexColor:@"666666"];
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentCenter;
        
        NSString *weekName = @"";
        if (i < [self.coachBookingInfoList count]) {
            CoachBookingInfo *info = [self.coachBookingInfoList objectAtIndex:i];
            if (i == 0 && [info.weekDate isToday]) {
                weekName = @"今天";
            } else {
                weekName = [DateUtil ChineseWeek2:info.weekDate];
            }
        }
        label.text = weekName;
        
//        [self addSubview:label];
    }
}

- (void)initLineViews
{
    for (int i = 1 ; i < COUNT ; i ++) {
//        UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * WIDTH - 1, HEIGHT + 1, 1, 3 * HEIGHT)] ;
//        //lineImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
//        lineImageView.backgroundColor = [UIColor clearColor];
//        [lineImageView setImage:[UIImage imageNamed:@"cell_line_e6_vertical"]];
//        [self addSubview:lineImageView];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(i * WIDTH - 1, HEIGHT + 1, 0.5, 3 * HEIGHT)];
        [view setBackgroundColor:[SportColor defaultButtonInactiveColor]];
        [self addSubview:view];
        
        
    }
}

- (void)initTimes
{
    NSArray *list = @[@"上", @"下", @"晚"];
    for (int line = 0; line < 3; line ++) {
        for (int i = 0; i < COUNT; i ++) {
            UILabel *label = (UILabel *)[self.timeHolderView viewWithTag:(TAG_BASE_TIMELABEL + line * COUNT + i)];
//            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i * WIDTH, (line + 1) * HEIGHT + 1, WIDTH, HEIGHT - 1)] ;
            
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont systemFontOfSize:14];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = [list objectAtIndex:line];
            
            BOOL canBook = [self isCanBookWithLine:line column:i];
            if (canBook) {
                label.textColor = [UIColor hexColor:@"ff850d"];
            } else {
                label.textColor = [UIColor hexColor:@"aaaaaa"];
                label.backgroundColor = [UIColor hexColor:@"f9f9f9"];
            }
            
//            [self addSubview:label];
        }
    }
}

- (BOOL)isCanBookWithLine:(int)line column:(int)column
{
    if (column < [self.coachBookingInfoList count]) {
        CoachBookingInfo *info = [self.coachBookingInfoList objectAtIndex:column];
        if (line == 0) {
            return info.morningState;
        } else if (line == 1) {
            return info.afternoonState;
        } else if (line == 2) {
            return info.nightState;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

@end
