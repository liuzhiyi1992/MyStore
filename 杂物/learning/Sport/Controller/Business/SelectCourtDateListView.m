//
//  SelectCourtDateListView.m
//  Sport
//
//  Created by qiuhaodong on 16/6/13.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "SelectCourtDateListView.h"
#import "BookingDateView.h"
#import "UIView+Utils.h"

@interface SelectCourtDateListView()<BookingDateViewDelegate>
@property (strong ,nonatomic) NSDate *selectedDate;
@property (copy, nonatomic) void(^didClickDateViewHandler)(NSDate *date);
@end

@implementation SelectCourtDateListView

#define SELECT_COURT_DATE_LIST_VIEW_TAG  2016061301
+ (void)showViewInSuperView:(UIView *)superView
                   dateList:(NSArray *)dateList
               selectedDate:(NSDate *)selectedDate
    didClickDateViewHandler:(void(^)(NSDate * date))didClickDateViewHandler
{
    SelectCourtDateListView *view = [superView viewWithTag:SELECT_COURT_DATE_LIST_VIEW_TAG];
    if (!view) {
        view = [[SelectCourtDateListView alloc] initWithFrame:superView.bounds];
        view.showsHorizontalScrollIndicator = NO;
        view.tag = SELECT_COURT_DATE_LIST_VIEW_TAG;
        [superView addSubview:view];
    }
    view.didClickDateViewHandler = didClickDateViewHandler;
    
    if (![view hasDateView]) {
        [view initDateScrollView:dateList selectedDate:selectedDate];
    }
    
    [view updateStatusWithSelectedDate:selectedDate];
}

- (BOOL)hasDateView {
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:[BookingDateView class]]) {
            return YES;
        }
    }
    return NO;
}

#define BASIC_DATE_TAG  100
- (void)initDateScrollView:(NSArray *)dateList selectedDate:(NSDate *)selectedDate
{
    int selectedIndex = 0;
    int index = 0;
    CGFloat space = 0;
    for (NSDate *date in dateList) {
        if ([date isEqualToDate:selectedDate]) {
            selectedIndex = index;
        }
        BookingDateView *view = [BookingDateView createBookingDateView];
        view.tag = BASIC_DATE_TAG + index;
        view.delegate = self;
        [view updatView:date isSelected:NO index:index];
        [view updateOriginX:space + index * (space + view.frame.size.width)];
        [self addSubview:view];
        index ++;
    }
    
    [self setContentSize:CGSizeMake(space + index * (space + [BookingDateView defaultSize].width), self.frame.size.height)];
    
    if (selectedIndex > 3 && self.contentSize.width > self.frame.size.width) {
        CGFloat oneWidth = space + [BookingDateView defaultSize].width;
        CGFloat xOffset = MIN(MAX(selectedIndex * oneWidth - 0.5 * oneWidth, 0),  self.contentSize.width - [UIScreen mainScreen].bounds.size.width);
        [self setContentOffset:CGPointMake(xOffset, 0) animated:NO];
    }
}

- (void)updateStatusWithSelectedDate:(NSDate *)selectedDate
{
    NSArray *subViewList = [self subviews];
    for (UIView *view in subViewList) {
        if ([view isKindOfClass:[BookingDateView class]]) {
            BookingDateView *bdv = (BookingDateView *)view;
            if ([bdv.date isEqualToDate:selectedDate]){
                [bdv updateSelected:YES];
            } else {
                if (YES == bdv.isSelected) {
                    [bdv updateSelected:NO];
                }
            }
        }
    }
}

#pragma mark - BookingDateViewDelegate
- (void)didClickBookingDateView:(NSDate *)date
{
    [MobClickUtils event:umeng_event_venue_page_switch_booking_date];
    
    if ([_selectedDate isEqualToDate:date]) {
        return;
    }
    
    if (self.didClickDateViewHandler) {
        self.didClickDateViewHandler(date);
    }
}

@end
