//
//  ProductDetailGroupView.m
//  Sport
//
//  Created by haodong  on 15/3/9.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "ProductDetailGroupView.h"
#import "Order.h"
#import "Product.h"
#import "PriceUtil.h"
#import "UIView+Utils.h"

#define TAG_LINE_VERTICAL           301

@implementation ProductDetailGroupView

+ (ProductDetailGroupView *)createProductDetailGroupView
{
    ProductDetailGroupView *view  = [[ProductDetailGroupView alloc] init];
    view.frame = CGRectMake(0, 0, 567, 43);
    return view;
}

#define SPACE_TOP 9
- (void)updateViewWithOrder:(Order *)order showPrice:(BOOL)showPrice
{
    NSDictionary *group = [order createGroup:showPrice];
    NSArray *nameList = [group allKeys];
    int index = 0;
    CGFloat x = 113,width = 140,height = 25;
    CGFloat y = 0;
    NSMutableArray *lineImageViewArray = [NSMutableArray array];
    for (NSString *name in nameList) {
        if (index > 0) { //添加横线
            UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(11, y, self.frame.size.width - 17, 1)];
            [lineImageView setBackgroundColor:[UIColor hexColor:@"f5f5f9"]];
            [lineImageView updateHeight:0.5f];
            [lineImageViewArray addObject:lineImageView];
            [self addSubview:lineImageView];
        }
        
        CGFloat yGroup = y;
        y += SPACE_TOP;
        
        //add时间价钱的view
        NSArray *valueList = [group objectForKey:name];
        for (NSString *oneValue in valueList) {
            UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)] ;
            valueLabel.font = [UIFont systemFontOfSize:14];
            valueLabel.backgroundColor = [UIColor clearColor];
            valueLabel.textColor = [SportColor content1Color];
            valueLabel.text = oneValue;
        
            [self addSubview:valueLabel];
            
            y += height;
        }
        y += SPACE_TOP;
        
        //add场地名的view
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, yGroup + 0.5 * (y - yGroup) - 0.5 * height, 80, height)] ;
        nameLabel.font = [UIFont systemFontOfSize:14];
        nameLabel.adjustsFontSizeToFitWidth = YES;
        nameLabel.numberOfLines = 0;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.textColor = [SportColor content1Color];
        nameLabel.text = name;
        [self addSubview:nameLabel];
        
        index ++;
    }
    self.horiLineImageViews = lineImageViewArray;
    
    //add竖线
    UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(99, 0, 1, y)];
    lineImageView.tag = TAG_LINE_VERTICAL;
    [lineImageView setBackgroundColor:[UIColor hexColor:@"f5f5f9"]];
    [lineImageView updateWidth:0.5f];
    [self addSubview:lineImageView];
    
    [self updateHeight:y];
}

- (CGFloat)heightWithProductListCount:(NSUInteger)count
{
    return count * 36.0;
}

@end
