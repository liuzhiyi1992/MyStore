//
//  BookingDateView.m
//  Sport
//
//  Created by haodong  on 13-7-21.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "BookingDateView.h"
#import "DayBookingInfo.h"
#import "DateUtil.h"
#import "NSDate+Utils.h"

@interface BookingDateView()
@end

@implementation BookingDateView

+ (BookingDateView *)createBookingDateView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"BookingDateView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    BookingDateView *view = [topLevelObjects objectAtIndex:0];
    [view.selectButton setBackgroundImage:[SportColor createImageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
    [view.selectButton setBackgroundImage:[SportColor createImageWithColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.2]] forState:UIControlStateHighlighted];
    [view.leftLineImageView setImage:[SportImage lineVerticalImage]];
    [view.rightLineImageView setImage:[SportImage lineVerticalImage]];
    return view;
}

+ (CGSize)defaultSize
{
    return CGSizeMake(72, 45);
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
    UIColor *backgroundColor;
    
    if (isSelected){
        textColor = [SportColor defaultColor];
        bottomColor = textColor;
        backgroundColor = [UIColor whiteColor];
    } else {
        textColor = [UIColor colorWithRed:99.0/255.0 green:99.0/255.0 blue:99.0/255.0 alpha:1];
        bottomColor = [UIColor colorWithRed:196.0/255.0 green:196.0/255.0 blue:196.0/255.0 alpha:1];
        backgroundColor = [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1];
    }
    self.weekLabel.textColor = textColor;
    self.dateLabel.textColor = textColor;
    self.bottomView.backgroundColor = bottomColor;
    
    self.backgroundColor = backgroundColor;
}

- (IBAction)clickButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickBookingDateView:)]) {
        [_delegate didClickBookingDateView:_date];
    }
}

@end
