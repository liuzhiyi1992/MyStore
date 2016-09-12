//
//  UnpaidOrderAlertView.h
//  Sport
//
//  Created by haodong  on 14/10/29.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UnpaidOrderAlertViewDelegate <NSObject>
@optional
- (void)didClickUnpaidOrderAlertViewCancelButton;
- (void)didClickUnpaidOrderAlertViewPayButton;
@end

@class Order;

@interface UnpaidOrderAlertView : UIView

@property (weak, nonatomic) IBOutlet UIView *contentHolderView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *businessNameLabel;

@property (weak, nonatomic) IBOutlet UIView *bottomHolderView;
@property (weak, nonatomic) IBOutlet UILabel *needPayPriceLabel;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *payButton;

@property (weak, nonatomic) IBOutlet UIView *singleHolderView;
@property (weak, nonatomic) IBOutlet UILabel *singleGoodsNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *singleGoodsCountLabel;

@property (weak, nonatomic) IBOutlet UIView *totalPriceHolderView;

@property (assign, nonatomic) id<UnpaidOrderAlertViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *packageNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountTimeLabel;

+ (UnpaidOrderAlertView *)createUnpaidOrderAlertView;

- (void)updateViewWithOrder:(Order *)order;

- (void)show;

@end
