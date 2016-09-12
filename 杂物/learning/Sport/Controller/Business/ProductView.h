//
//  ProductView.h
//  Sport
//
//  Created by haodong  on 13-7-18.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

#define COLOR_CAN_ORDER [UIColor colorWithRed:106.0/255.0 green:212.0/255.0 blue:73.0/255.0 alpha:1]
#define COLOR_ORDERED [UIColor colorWithRed:205.0/255.0 green:205.0/255.0 blue:205.0/255.0 alpha:1]
#define COLOR_HIGHLIGHTED [SportColor content1Color]
#define COLOR_MY_ORDER [SportColor defaultColor]

@class ProductView;
@class Product;

@protocol ProductViewDelegate<NSObject>
@optional
- (void)didClickProductView:(Product *)product productView:(ProductView *)productView;
@end

@interface ProductView : UIView
@property (assign, nonatomic) id<ProductViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (readonly, strong, nonatomic) Product *product;

+ (ProductView *)createProductView;
+ (CGSize)defaultSize;
- (void)updateColor:(BOOL)isSelected;
- (void)updateView:(Product *)product
         showPrice:(BOOL)showPrice;

- (IBAction)clickButton:(id)sender;

@end
