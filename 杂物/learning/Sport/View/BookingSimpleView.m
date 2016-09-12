//
//  BookingSimpleView.m
//  Sport
//
//  Created by haodong  on 13-6-27.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "BookingSimpleView.h"
#import "DayBookingInfo.h"
#import "Court.h"
#import "Product.h"
#import "DateUtil.h"
#import "NSDate+Utils.h"
#import "Business.h"
#import "SportPopupView.h"

@interface BookingSimpleView()
@property (assign, nonatomic) int index;
@property (assign, nonatomic) NSUInteger count;
@end

@implementation BookingSimpleView

+ (BookingSimpleView *)createBookingSimpleView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"BookingSimpleView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    BookingSimpleView *view = [topLevelObjects objectAtIndex:0];
    view.countLabel.textColor = [SportColor defaultOrangeColor];
    
    [view.backgroundButton setBackgroundImage:[SportImage whiteBackgroundRoundImage] forState:UIControlStateNormal];
    
//    [view.bookButton setTitleColor:[SportColor defaultOrangeColor] forState:UIControlStateNormal];
    [view.bookButton setTitleColor:[SportColor content2Color] forState:UIControlStateDisabled];
//    
//    [view.bookButton setTitleColor:[SportColor content1Color] forState:UIControlStateHighlighted];
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 8.0f;
    return view;
}

+ (CGSize)defaultSize
{
    return CGSizeMake(83, 95);
}

- (void)updateWeek:(BookingStatistics *)bookingStatistics isToday:(BOOL)isToday
{
    if (isToday) {
        self.weekLabel.text = @"今天";
    } else {
        self.weekLabel.text = [DateUtil ChineseWeek2:bookingStatistics.date];
    }
}

- (void)updateDate:(BookingStatistics *)bookingStatistics
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
    [dateFormatter setDateFormat:@"M月d日"];
    NSString *dateString = [dateFormatter stringFromDate:bookingStatistics.date];
    self.dateLabel.text = dateString;
}

- (void)updateCount:(BookingStatistics *)bookingStatistics
{
    self.countLabel.text = [@(bookingStatistics.count) stringValue];
}

- (void)updatView:(BookingStatistics *)bookingStatistics
            index:(int)index
{
    self.index = index;
    self.count = bookingStatistics.count;
    
    BOOL isToday = NO;
    if (index == 0 &&  [bookingStatistics.date isToday]) {
        isToday = YES;
    }
    
    [self updateWeek:bookingStatistics isToday:isToday];
    [self updateDate:bookingStatistics];
    [self updateCount:bookingStatistics];
    
    if (_count > 0) {
        self.bookButton.enabled = YES;
    } else {
        self.bookButton.enabled = NO;
    }
}

- (IBAction)clickButton:(id)sender {
    if (_count <= 0) {
        [SportPopupView popupWithMessage:@"该日期的场地已售完"];
        return;
    }
    
    if ([_delegate respondsToSelector:@selector(didClickBookingSimpleView:)]) {
        [_delegate didClickBookingSimpleView:_index];
    }
}

@end
