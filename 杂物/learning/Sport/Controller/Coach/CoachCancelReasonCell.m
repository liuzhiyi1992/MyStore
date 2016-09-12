//
//  CoachCancelReasonCell.m
//  Sport
//
//  Created by 江彦聪 on 15/4/14.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CoachCancelReasonCell.h"

@implementation CoachCancelReasonCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (NSString*)getCellIdentifier
{
    return @"CoachCancelReasonCell";
}

+ (CGFloat)getCellHeight
{
    return 43;
}

- (void)updateCellWithTitle:(NSString *)title
                 isSelected:(BOOL)isSelected
                  indexPath:(NSIndexPath *)indexPath
{
    self.indexPath = indexPath;
    
    NSString *coachCancelTitle = [NSString stringWithFormat:@"%d.%@",(int)indexPath.row+1,title];
    self.titleLabel.text = coachCancelTitle;
    
    UIImage *image = nil;
    if (isSelected) {
        image = [SportImage radioButtonSelectedImage];
    } else {
        image = [SportImage radioButtonUnselectedImage];
    }
    
    self.selectImageView.image = image;
}


+ (id)createCell
{
    CoachCancelReasonCell *cell = (CoachCancelReasonCell *)[super createCell];
    
    return cell;
}
- (IBAction)clickButton:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(didClickButton:)]) {
        [_delegate didClickButton:self.indexPath];
    }
}

@end
