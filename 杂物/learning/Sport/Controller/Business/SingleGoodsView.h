//
//  SingleGoodsView.h
//  Sport
//
//  Created by haodong  on 15/1/9.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@class Goods;

@protocol SingleGoodsViewDelegate <NSObject>
@optional
- (void)didClickSingleGoodsViewBuyButton:(Goods *)goods;
- (void)didClickSingleGoodsViewBuyBackgroundButton:(Goods *)goods;
@end


@interface SingleGoodsView : UIView

@property (weak, nonatomic) IBOutlet UIButton *backgroundButton;
@property (weak, nonatomic) IBOutlet UIImageView *lineImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *originalPriceLabel;
@property (weak, nonatomic) IBOutlet UIView *originalPriceLineView;
@property (weak, nonatomic) IBOutlet UIView *originalPriceHolderView;
@property (weak, nonatomic) IBOutlet UILabel *promoteMessageLabel;

@property (assign, nonatomic) id<SingleGoodsViewDelegate> delegate;

+ (SingleGoodsView *)createSingleGoodsView;

+ (CGFloat)height;

- (void)updateViewWithGoods:(Goods *)goods row:(NSUInteger)row;

@end
