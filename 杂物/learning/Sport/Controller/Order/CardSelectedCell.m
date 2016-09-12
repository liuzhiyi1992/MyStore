//
//  CardSelectedCell.m
//  Sport
//
//  Created by 江彦聪 on 15/11/4.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "CardSelectedCell.h"
#import "MembershipCard.h"
@implementation CardSelectedCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    self.cardNumberLabelWidth.constant = ([UIScreen mainScreen].bounds.size.width - _leadingConstrant.constant - 30)/2 - 45;
}

+ (CGFloat)getCellHeight
{
    return 50;
}

+ (NSString *)getCellIdentifier
{
    return @"CardSelectedCell";
}

- (void)updateCellWithCard:(MembershipCard *)card
                  isSelected:(BOOL)isSelected
                   indexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        self.topLineImageView.hidden = NO;
    } else {
        self.topLineImageView.hidden = YES;
    }
    self.cardNumberLabel.text = card.cardNumber;
    if (card.status == CardStatusLock){
        self.cardBalanceLabel.text = @"(待确定转移)";
        self.rightImageView.hidden = YES;
        self.userInteractionEnabled = NO;
    } else {
        self.cardBalanceLabel.text = [NSString stringWithFormat:@"(余额%@)",card.money];
        self.rightImageView.hidden = NO;
        
        self.userInteractionEnabled = YES;
    }
    
    UIImage *image;
    if (isSelected) {
        image = [SportImage radioButtonSelectedImage];
    } else {
        image = [SportImage radioButtonUnselectedImage];
    }
    self.rightImageView.image = image;
}

- (void)updateCellWithNumber:(NSString *)cardNumber
                  balance:(NSString *)cardBalance
                  isSelected:(BOOL)isSelected
                 indexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        self.topLineImageView.hidden = NO;
    } else {
        self.topLineImageView.hidden = YES;
    }
    self.cardNumberLabel.text = cardNumber;
    self.cardBalanceLabel.text = [NSString stringWithFormat:@"(余额%@)",cardBalance];
    
    UIImage *image;
    if (isSelected) {
        image = [SportImage radioButtonSelectedImage];
    } else {
        image = [SportImage radioButtonUnselectedImage];
    }
    self.rightImageView.image = image;
}


@end
