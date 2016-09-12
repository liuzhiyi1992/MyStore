//
//  OrderSimpleCell.h
//  Sport
//
//  Created by haodong  on 14-7-17.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@protocol OrderSimpleCellDelegate <NSObject>
@optional
- (void)didClickOrderSimpleCellButton:(NSIndexPath *)indexPath;
- (void)didClickOrderSimpleCellCancelButton:(NSIndexPath *)indexPath;
- (void)didClickOrderSimpleCellPayButton:(NSIndexPath *)indexPath;
- (void)didClickOrderSimpleCellWriteReviewButton:(NSIndexPath *)indexPath;
- (void)didClickOrderSimpleCellWebDetailButtonButton:(NSIndexPath *)indexPath;
- (void)didClickOrderSimpleCellCoachActionButton:(NSIndexPath *)indexPath;
@end

@class Order;

@interface OrderSimpleCell : DDTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (weak, nonatomic) IBOutlet UILabel *businessNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *consumeCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *useDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *backgroundButton;

@property (weak, nonatomic) IBOutlet UIView *consumeCodeHolderView;
@property (weak, nonatomic) IBOutlet UIView *priceHolderView;

@property (weak, nonatomic) IBOutlet UIView *infoHolderView;
@property (weak, nonatomic) IBOutlet UILabel *useDateTitleLabel;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *payButton;

@property (weak, nonatomic) IBOutlet UIButton *writeReviewButton;
@property (weak, nonatomic) IBOutlet UIButton *webDetailButton;

@property (weak, nonatomic) IBOutlet UIView *buttonHolderView;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

typedef NS_ENUM(NSUInteger, ActionButtonType) {
    ActionButtonTypeCancel = 0,
    ActionButtonTypeConfirm = 1
};

@property (assign, nonatomic) id<OrderSimpleCellDelegate> delegate;

- (void)updateCellWithOrder:(Order *)order indexPath:(NSIndexPath *)indexPath;

+ (CGFloat)getCellHeightWithOrder:(Order *)order;
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
