//
//  CoachItemCell.h
//  Sport
//
//  Created by liuzhiyi on 15/9/30.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"
#import "CoachProjects.h"

typedef enum
{
    CellTypeDisplay = 1,
    CellTypeBooking = 2
} CellType;

@protocol CoachItemCellDelegate <NSObject>

@optional
- (void)coachItemDidBookingWithProject:(CoachProjects *)project;

@end


@interface CoachItemCell : DDTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *itemTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *commitButton;
@property (weak, nonatomic) IBOutlet UIView *contentholderView;
@property (strong, nonatomic) CoachProjects *project;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightScaleConstraint;

@property (weak, nonatomic) id<CoachItemCellDelegate> delegate;


+ (NSString *)getCellIdentifier;

+ (id)createCellWithCellType:(CellType)cellType;

+ (CGFloat)getCellHeightWithCellType:(CellType)cellType;

- (void)updateCellWithItem:(CoachProjects *)project;

- (void)showWithSuperView:(UIView *)superView;

@end
