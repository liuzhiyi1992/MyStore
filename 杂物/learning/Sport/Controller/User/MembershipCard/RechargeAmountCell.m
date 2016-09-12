//
//  RechargeAmountCell.m
//  Sport
//
//  Created by haodong  on 15/4/14.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "RechargeAmountCell.h"
#import "MembershipCardRechargeGoods.h"
#import "PriceUtil.h"

@implementation RechargeAmountCell

+ (NSString *)getCellIdentifier
{
    return @"RechargeAmountCell";
}

+ (CGFloat)getCellHeight
{
    return 45;
}

- (void)updateCellWithGoods:(MembershipCardRechargeGoods *)goods
                 isSelected:(BOOL)isSelected
                  indexPath:(NSIndexPath *)indexPath
                     isLast:(BOOL)isLast
{
    UIImage *bgImage = nil;
    if (indexPath.row == 0 && isLast ) {
        bgImage = [SportImage otherCellBackground4Image];
    } else if (indexPath.row == 0) {
        bgImage = [SportImage otherCellBackground1Image];
    } else if (isLast) {
        bgImage = [SportImage otherCellBackground3Image];
    } else {
        bgImage = [SportImage otherCellBackground2Image];
    }
    UIImageView *bv = [[UIImageView alloc] initWithImage:bgImage] ;
    [self setBackgroundView:bv];
    
    self.amountLabel.text = [PriceUtil toPriceStringWithYuan:goods.amount];
    
    if (goods.giftAmount > 0) {
        self.giftAmountLabel.text = [PriceUtil toValidPriceString:goods.giftAmount];
        self.messageLabel.text = goods.message;
    } else {
        self.giftAmountLabel.text = @"";
        self.messageLabel.text = @"";
    }
    
    if (isSelected) {
        self.rightImageView.image = [SportImage selectBoxOrangeImage];
    } else {
        self.rightImageView.image = [SportImage selectBoxUnselectImage];
    }
}

@end
