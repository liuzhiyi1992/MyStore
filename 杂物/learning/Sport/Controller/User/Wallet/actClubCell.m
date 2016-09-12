//
//  actClubCell.m
//  Sport
//
//  Created by 冯俊霖 on 15/8/10.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "actClubCell.h"

@interface actClubCell()
@property (strong, nonatomic) IBOutlet UIButton *selectButton;
@property (strong, nonatomic) IBOutlet UILabel *isBuyLabel;

@end

@implementation actClubCell

+ (id)createCell{
    actClubCell *cell = [super createCell];
    [cell.selectButton setBackgroundImage:[SportColor createImageWithColor:[UIColor colorWithRed:155.0/255.0 green:207.0/255.0 blue:135.0/255.0 alpha:1]] forState:UIControlStateNormal];
    cell.selectButton.layer.cornerRadius = 3;
    cell.selectButton.layer.masksToBounds = YES;
    return cell;
}

+ (NSString *)getCellIdentifier{
    return @"actClubCell";
}

+ (CGFloat)getCellHeight{
    return 78;
}

- (void)updateUserClubStatus:(int)userClubStatus usableDays:(NSString *)usableDays{
    if (userClubStatus == 1) {
        self.isBuyLabel.text = [NSString stringWithFormat:@"剩余%@天",usableDays];
    }else{
        self.isBuyLabel.text = @"尚未购买";
    }
}

- (IBAction)clickSelectButton:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(didClickactClubCell)]) {
        [_delegate didClickactClubCell];
    }
}

@end
