//
//  MyPointCell.m
//  Sport
//
//  Created by haodong  on 14/11/13.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "MyPointCell.h"
#import <QuartzCore/QuartzCore.h>
#import "PointGoods.h"
#import "UIImageView+WebCache.h"
#import "UIView+Utils.h"
#import "NSString+Utils.h"

@implementation MyPointCell


+ (NSString*)getCellIdentifier
{
    return @"MyPointCell";
}

+ (CGFloat)getCellHeight
{
    return 83;
}

+ (id)createCell
{
    MyPointCell *cell = [super createCell];
    cell.goodsImageView.layer.cornerRadius = 1;
    cell.goodsImageView.layer.masksToBounds = YES;
    cell.lineViewConstraintHeight.constant = 0.5;
    return cell;
}

- (void)updateCellWithPointGoods:(PointGoods *)pointGoods
                       indexPath:(NSIndexPath *)indexPath
                          isLast:(BOOL)isLast
{
    [self.goodsImageView sd_setImageWithURL:[NSURL URLWithString:pointGoods.imageUrl] placeholderImage:[SportImage defaultImage_92x65]];
    self.titleLabel.text = pointGoods.title;
    self.subTitleLabel.text = pointGoods.subTitle;
    
    self.pointLabel.text = [NSString stringWithFormat:@"%d积分", pointGoods.point];
    
    //test data
    //pointGoods.originalPoint = rand() % 1000;
    //pointGoods.joinTimes = rand() % 9999;
    
    if (pointGoods.originalPoint > 0) {
        self.originalPointLabel.hidden = NO;
        self.originalPointLineView.hidden = NO;
        self.originalPointLabel.text = [NSString stringWithFormat:@"%d积分", pointGoods.originalPoint];
        
        CGSize size = [self.pointLabel.text sizeWithMyFont:self.pointLabel.font];
        CGFloat originalX = _pointLabel.frame.origin.x + size.width + 8;
        [self.originalPointHolderView updateOriginX:originalX];
        
        CGSize originalSize = [self.originalPointLabel.text sizeWithMyFont:self.originalPointLabel.font];
        [self.originalPointLineView updateWidth:originalSize.width + 4];
        
    } else {
        self.originalPointLabel.hidden = YES;
        self.originalPointLineView.hidden = YES;
    }
    
    NSString *joinTimesString;
    if (pointGoods.type == PointGoodsTypeDraw) {
        joinTimesString = @"参与";
    } else {
        joinTimesString = @"兑换";
    }
    
    self.joinTimesLabel.text = [NSString stringWithFormat:@"%@(%lu)", joinTimesString,(unsigned long)pointGoods.joinTimes];
    
}

@end
