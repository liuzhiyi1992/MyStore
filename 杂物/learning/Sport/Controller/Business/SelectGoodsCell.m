//
//  SelectGoodsCell.m
//  Sport
//
//  Created by haodong  on 14-8-17.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SelectGoodsCell.h"

@interface SelectGoodsCell()
@end

@implementation SelectGoodsCell


+ (NSString*)getCellIdentifier
{
    return @"SelectGoodsCell";
}

+ (id)createCell
{
    SelectGoodsCell *cell = [super createCell];
    cell.lineImageView.image = [SportImage lineImage];
    return cell;
}

+ (CGFloat)getCellHeight
{
    return 43.0;
}

- (void)updateCellWithValue:(NSString *)value isSelected:(BOOL)isSelected
{
    self.valueLabel.text = value;
    
    if (isSelected) {
        self.contentView.backgroundColor = [UIColor colorWithRed:185.0/255.0 green:215.0/255.0 blue:253.0/255.0 alpha:1];
    } else {
        self.contentView.backgroundColor= [UIColor whiteColor];
    }
}

@end
