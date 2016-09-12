//
//  SportDropDownLeftCell.m
//  Sport
//
//  Created by 冯俊霖 on 15/10/9.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "SportDropDownLeftCell.h"

@interface SportDropDownLeftCell()


@end

@implementation SportDropDownLeftCell

+ (NSString *)getCellIdentifier
{
    return @"SportDropDownLeftCell";
}

+ (CGFloat)getCellHeight
{
    return 45;
}

+ (id)createCell
{
    SportDropDownLeftCell *cell = [super createCell];
    cell.backgroundColor = [SportColor hexf6f6f9Color];
    UIView *sView = [[UIView alloc] init];
    sView.backgroundColor = [UIColor whiteColor];
    cell.selectedBackgroundView = sView;
    [cell setSelected:YES animated:NO];
    return cell;
}

- (void)updateCellWithTitle:(NSString *)title{
    self.titleLabel.text = title;
}

@end
