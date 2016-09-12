//
//  BookingSimpleView.h
//  Sport
//
//  Created by haodong  on 13-6-27.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BookingSimpleViewDelegate <NSObject>
@optional
- (void)didClickBookingSimpleView:(int)index;
@end

@class BookingStatistics;

@interface BookingSimpleView : UIView
@property (weak, nonatomic) IBOutlet UILabel *weekLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIButton *backgroundButton;
@property (weak, nonatomic) IBOutlet UIButton *bookButton;

@property (assign, nonatomic) id<BookingSimpleViewDelegate> delegate;

+ (BookingSimpleView *)createBookingSimpleView;

+ (CGSize)defaultSize;

- (void)updatView:(BookingStatistics *)bookingStatistics
            index:(int)index;

@end
