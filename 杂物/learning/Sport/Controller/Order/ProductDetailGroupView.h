//
//  ProductDetailGroupView.h
//  Sport
//
//  Created by haodong  on 15/3/9.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@class Order;

@interface ProductDetailGroupView : UIView
@property (strong, nonatomic) NSArray *horiLineImageViews;

+ (ProductDetailGroupView *)createProductDetailGroupView;

- (void)updateViewWithOrder:(Order *)order showPrice:(BOOL)showPrice;

- (CGFloat)heightWithProductListCount:(NSUInteger)count;

@end
