//
//  ProductView.m
//  Sport
//
//  Created by haodong  on 13-7-18.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "ProductView.h"
#import "Product.h"
#import <QuartzCore/QuartzCore.h>
#import "PriceUtil.h"
#import "SportPopupView.h"

@interface ProductView()
@property (readwrite, strong, nonatomic) Product *product;
@property (strong, nonatomic) UILabel *courtJoinLabel;
@end

@implementation ProductView


+ (ProductView *)createProductView
{
    
//    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ProductView" owner:self options:nil];
//    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
//        return nil;
//    }
//    return [topLevelObjects objectAtIndex:0];
    
    CGRect frame = CGRectMake(0, 0, 50, 31);
    ProductView *view = [[ProductView alloc] initWithFrame:frame] ;
    
    UILabel *courtJoinLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 12, 0, 12, 12)];
    courtJoinLabel.backgroundColor = [UIColor orangeColor];
    courtJoinLabel.hidden = YES;
    courtJoinLabel.text = @"局";
    courtJoinLabel.textColor = [UIColor whiteColor];
    courtJoinLabel.font = [UIFont systemFontOfSize:9];
    courtJoinLabel.textAlignment = NSTextAlignmentCenter;
    view.courtJoinLabel = courtJoinLabel;
    [view addSubview:courtJoinLabel];
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame] ;
    label.backgroundColor = [UIColor clearColor];
    label.textColor= [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    view.priceLabel = label;
    [view addSubview:label];
    
    UIButton *button = [[UIButton alloc] initWithFrame:frame] ;
    button.backgroundColor = [UIColor clearColor];
    [button setBackgroundImage:[SportColor createImageWithColor:COLOR_HIGHLIGHTED] forState:UIControlStateHighlighted];
    [button addTarget:view action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    //view.layer.cornerRadius = 2;
    //view.layer.masksToBounds = YES;
    
    return view;
}

+ (CGSize)defaultSize
{
    return CGSizeMake(50, 31);
}

- (void)updateColor:(BOOL)isSelected
{
    if (isSelected) {
        self.backgroundColor = COLOR_MY_ORDER;
    } else {
        if ([_product canBuy]) {
            self.backgroundColor = COLOR_CAN_ORDER;
        } else if (_product.status == ProductStatusOrdered || _product.status == ProductStatusCanNotOrder) {
            self.backgroundColor = COLOR_ORDERED;
        }
    }
}

- (void)updateView:(Product *)product
         showPrice:(BOOL)showPrice
{
    self.product = product;
    
    [self updateColor:NO];
    
    for (UIButton *button in self.subviews) {
        if([button isKindOfClass:[UIButton class]] ){
            button.accessibilityLabel = [NSString stringWithFormat:@"order_status_%d",product.status];
        }
    }
    
    //价格label
    if ([product canBuy] && showPrice) {
        self.priceLabel.hidden = NO;
        if (self.product.courtJoinId) {
            self.priceLabel.text = [NSString stringWithFormat:@"￥%@", [PriceUtil toValidPriceString:product.courtJoinPrice]];
        } else {
            self.priceLabel.text = [NSString stringWithFormat:@"￥%@", [PriceUtil toValidPriceString:product.price]];
        }
    } else {
        self.priceLabel.hidden = YES;
        self.priceLabel.text = nil;
    }
    
    //球局标示
    if (product.courtJoinId && product.courtJoinCanBuy) {
        self.courtJoinLabel.hidden = NO;
    } else {
        self.courtJoinLabel.hidden = YES;
    }
}

- (IBAction)clickButton:(id)sender {
    if (![self.product canBuy]) {
        [SportPopupView popupWithMessage:@"该场次已出售"];
        return;
    }
    
    if ([_delegate respondsToSelector:@selector(didClickProductView:productView:)]) {
        [_delegate didClickProductView:_product productView:self];
    }
}

@end
