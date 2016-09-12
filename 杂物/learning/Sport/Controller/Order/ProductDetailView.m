//
//  ProductDetailView.m
//  Sport
//
//  Created by haodong  on 14-8-18.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "ProductDetailView.h"
#import "Order.h"
#import "Product.h"
#import "UIView+Utils.h"
#import "PriceUtil.h"
#import "DateUtil.h"

@implementation ProductDetailView

#define SPACE           2
#define HEIGHT_ONE      21
#define WIDTH_ONE       240

+ (ProductDetailView *)createProductDetailView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ProductDetailView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    ProductDetailView *view = [topLevelObjects objectAtIndex:0];
    
    return view;
}

- (CGFloat)heightWithProductListCount:(NSUInteger)count
{
    if (count <= 0) {
        return HEIGHT_ONE + SPACE + HEIGHT_ONE;
    } else {
        return HEIGHT_ONE + SPACE + count * HEIGHT_ONE;
    }
}

- (void)updateViewWithOrder:(Order *)order showPrice:(BOOL)showPrice
{
    BOOL isDateAtFirst = YES; //控制日期是否现实在前面
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *dateString = [dateFormatter stringFromDate:order.useDate];
    
    NSString *weekString = [DateUtil ChineseWeek2:order.useDate];
    
    self.dateLabel.text = [NSString stringWithFormat:@"%@ (%@)", dateString, weekString];
    
    CGFloat productY = 0;
    if (isDateAtFirst) {
        productY = HEIGHT_ONE + SPACE;
    } else {
        productY = 0;
    }
    
    [self.productTitleLabel updateOriginY:productY];
    int index = 0;
    for (Product * product in order.productList) {
        UILabel *label = [[UILabel alloc] init] ;
        label.textColor = self.dateLabel.textColor;
        label.font = self.dateLabel.font;
        label.backgroundColor = [UIColor clearColor];
        CGFloat y = productY + index * HEIGHT_ONE;
        CGRect frame = CGRectMake(_dateLabel.frame.origin.x, y, WIDTH_ONE, HEIGHT_ONE);
        label.frame = frame;
        
        NSMutableString *allString = [NSMutableString stringWithFormat:@"%@  %@  ", [product startTimeToEndTime], product.courtName];
        if (showPrice) {
            if (order.type == OrderTypeCourtJoin) {
                [allString appendString:[PriceUtil toPriceStringWithYuan:product.courtJoinPrice]];
            } else {
                [allString appendString:[PriceUtil toPriceStringWithYuan:product.price]];
            }
        }
        label.text = allString;
        
        [self addSubview:label];
        index ++;
    }
    
    if (isDateAtFirst) {
        [self.dateHolderView updateOriginY:0];
    } else {
        [self.dateHolderView updateOriginY:[order.productList count] * HEIGHT_ONE + SPACE];
    }
    
    [self updateHeight:[self heightWithProductListCount:[order.productList count]]];
}

@end
