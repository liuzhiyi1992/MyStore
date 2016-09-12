//
//  CourtPoolListDateView.h
//  Sport
//
//  Created by xiaoyang on 16/2/23.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@class DayBookingInfo;


@protocol CourtPoolListDateViewDelegate <NSObject>
@optional
- (void)didClickCourtPoolListDateView:(NSDate *)date;
@end

@interface CourtPoolListDateView : UIView
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekLabel;

@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (assign, nonatomic) BOOL isSelected;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) NSDate *date;
@property (assign, nonatomic) id<CourtPoolListDateViewDelegate > delegate;

+(CourtPoolListDateView *)createCourtPoolListDateViewWithHoldViewWhite:(CGFloat)holdViewWidth;

- (void)updatView:(NSDate *)date
       isSelected:(BOOL)isSelected
            index:(int)index;

+ (CGSize)defaultSize;

- (void)updateSelected:(BOOL)isSelected;

@end
