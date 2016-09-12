//
//  CourtJoinDateListView.m
//  Sport
//
//  Created by xiaoyang on 16/6/13.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "CourtJoinDateListView.h"
#import "DateUtil.h"
#import "NSDate+Utils.h"

@implementation CourtJoinDateListView

+(CourtJoinDateListView *)createCourtJoinDateListViewWithHoldViewWidth:(CGFloat)holdViewWidth{
    
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CourtJoinDateListView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    CourtJoinDateListView *view = [topLevelObjects objectAtIndex:0];
    //    [view.selectButton setBackgroundImage:[SportColor createImageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
    [view.selectButton setBackgroundImage:[SportColor createImageWithColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.2]] forState:UIControlStateHighlighted];
    
    
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, holdViewWidth/ 4, view.frame.size.height);
    
    
    return view;
}

+ (CGSize)defaultSize
{
    return CGSizeMake([UIScreen mainScreen].bounds.size.width / 4, 58);
}

- (void)updatView:(NSDate *)date
       isSelected:(BOOL)isSelected
            index:(int)index
{
    self.date = date;
    
    if (index == 0 && [date isToday]) {
        self.weekLabel.text = @"今天";
    } else {
        self.weekLabel.text = [DateUtil ChineseWeek2:date];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
    [dateFormatter setDateFormat:@"M月dd日"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    self.dateLabel.text = dateString;
    
    [self updateSelected:isSelected];
}

- (void)updateSelected:(BOOL)isSelected
{
    self.isSelected = isSelected;
    UIColor *bottomColor;
    UIColor *textColor;
    
    if (isSelected){
        textColor = [UIColor colorWithRed:34.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1];
        bottomColor = textColor;
        
    } else {
        textColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1];
        bottomColor = [UIColor clearColor];
        
    }
    self.weekLabel.textColor = textColor;
    self.dateLabel.textColor = textColor;
    self.bottomView.backgroundColor = bottomColor;
    
}

- (IBAction)clickButton:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(didClickCourtJoinDateListView:)]){
        [_delegate didClickCourtJoinDateListView:_date];
    }
}

@end
