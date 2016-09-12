//
//  MoneyCell.m
//  Sport
//
//  Created by haodong  on 15/3/18.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "MoneyCell.h"
#import <QuartzCore/QuartzCore.h>
#import "PriceUtil.h"

@interface MoneyCell()
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@end

@implementation MoneyCell


+ (id)createCell
{
    MoneyCell *cell = [super createCell];
    [cell.selectButton setBackgroundImage:[SportColor createImageWithColor:[UIColor colorWithRed:95.0/255.0 green:168.0/255.0 blue:99.0/255.0 alpha:1]] forState:UIControlStateNormal];
    cell.selectButton.layer.cornerRadius = 3;
    cell.selectButton.layer.masksToBounds = YES;
    return cell;
}

+ (NSString *)getCellIdentifier
{
    return @"MoneyCell";
}

+ (CGFloat)getCellHeight
{
    return 86;
}

- (void)updateMoney:(float)money
{
    self.moneyLabel.text = [NSString stringWithFormat:@"￥%@", [PriceUtil toValidPriceString:money]];
}

- (IBAction)clickSelectButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickMoneyCell)]) {
        [_delegate didClickMoneyCell];
    }
}

@end
