//
//  RefundCauseCell.m
//  Sport
//
//  Created by haodong  on 15/3/13.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "RefundCauseCell.h"

@implementation RefundCauseCell

+ (NSString*)getCellIdentifier
{
    return @"RefundCauseCell";
}

+ (CGFloat)getCellHeight
{
    return 42;
}

- (void)updateCellWithCause:(NSString *)cause
                 isSelected:(BOOL)isSelected
                  indexPath:(NSIndexPath *)indexPath
                     isLast:(BOOL)isLast
{
    self.causeLabel.text = cause;
    
    if (isSelected) {
        [self.rightImageView setImage:[SportImage selectBoxBlueImage]];
    } else {
        [self.rightImageView setImage:[SportImage selectBoxUnselectImage]];
    }
    
    UIImage *image = nil;
    if (indexPath.row == 0 && isLast ) {
        image = [SportImage otherCellBackground4Image];
    } else if (indexPath.row == 0) {
        image = [SportImage otherCellBackground1Image];
    } else if (isLast) {
        image = [SportImage otherCellBackground3Image];
    } else {
        image = [SportImage otherCellBackground2Image];
    }
    UIImageView *bv = [[UIImageView alloc] initWithImage:image] ;
    [self setBackgroundView:bv];
}

@end
