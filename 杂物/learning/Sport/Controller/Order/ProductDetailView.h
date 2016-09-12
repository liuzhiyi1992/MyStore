//
//  ProductDetailView.h
//  Sport
//
//  Created by haodong  on 14-8-18.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@class Order;

@interface ProductDetailView : UIView

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView *dateHolderView;
@property (weak, nonatomic) IBOutlet UILabel *productTitleLabel;

+ (ProductDetailView *)createProductDetailView;

- (CGFloat)heightWithProductListCount:(NSUInteger)count;

- (void)updateViewWithOrder:(Order *)order showPrice:(BOOL)showPrice;

@end
