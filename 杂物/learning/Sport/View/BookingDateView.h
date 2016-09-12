//
//  BookingDateView.h
//  Sport
//
//  Created by haodong  on 13-7-21.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@class DayBookingInfo;


@protocol BookingDateViewDelegate <NSObject>
@optional
- (void)didClickBookingDateView:(NSDate *)date;
@end

@interface BookingDateView : UIView
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectedBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (assign, nonatomic) BOOL isSelected;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) NSDate *date;
@property (weak, nonatomic) IBOutlet UIImageView *leftLineImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightLineImageView;

@property (assign, nonatomic) id<BookingDateViewDelegate> delegate;

+ (BookingDateView *)createBookingDateView;

+ (CGSize)defaultSize;

- (void)updatView:(NSDate *)date
       isSelected:(BOOL)isSelected
            index:(int)index;

- (void)updateSelected:(BOOL)isSelected;

@end
