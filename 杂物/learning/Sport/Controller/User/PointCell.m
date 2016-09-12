//
//  PointCell.m
//  Sport
//
//  Created by haodong  on 15/3/19.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "PointCell.h"
//#import <CORE >

@interface PointCell()
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UILabel *pointLabel;

@end

@implementation PointCell


+ (id)createCell
{
    PointCell *cell = [super createCell];
    [cell.selectButton setBackgroundImage:[SportColor createImageWithColor:[UIColor colorWithRed:155.0/255.0 green:207.0/255.0 blue:135.0/255.0 alpha:1]] forState:UIControlStateNormal];
    cell.selectButton.layer.cornerRadius = 3;
    cell.selectButton.layer.masksToBounds = YES;
    return cell;
}

+ (NSString *)getCellIdentifier
{
    return @"PointCell";
}

+ (CGFloat)getCellHeight
{
    return 78;
}

- (void)updatePoint:(int)point
{
    self.pointLabel.text = [NSString stringWithFormat:@"%d", point];
}

- (IBAction)clickSelectButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickPointCell)]) {
        [_delegate didClickPointCell];
    }
}

@end
