//
//  OrderAmountCell.m
//  Sport
//
//  Created by 江彦聪 on 15/4/14.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "OrderAmountCell.h"

@implementation OrderAmountCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (NSString*)getCellIdentifier
{
    return @"OrderAmountCell";
}

+ (CGFloat)getCellHeight
{
    return 40;
}

- (void)updateCellWithTitle:(NSString *)title
                     amount:(NSString *)ammount
                  indexPath:(NSIndexPath *)indexPath

{
    self.titleLabel.text = title;

    if ([title isEqualToString:OrderAmountTypeString(OrderMoneyAmount)]
       ||
        [title isEqualToString:OrderAmountTypeString(OrderPayAmount)] ) {
        
        NSAttributedString *attributeString = [[NSAttributedString alloc]initWithString:ammount attributes:@{NSForegroundColorAttributeName:[SportColor defaultOrangeColor]}];
        self.priceLabel.attributedText = attributeString;
    }
    else {
        self.priceLabel.text = ammount;
    }
}


+ (id)createCell
{
    OrderAmountCell *cell = (OrderAmountCell *)[super createCell];
    
    return cell;
}

- (void)layoutSubviews {
    // Custom code which potentially messes with constraints
    //self.tableViewHeightConstraint.constant = [OrderAmountCell getCellHeight]* [_dataList count];
    [super layoutSubviews]; // No code after this and this is called last
}


@end
