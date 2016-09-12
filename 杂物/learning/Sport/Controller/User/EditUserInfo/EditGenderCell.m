//
//  EditGenderCell.m
//  Sport
//
//  Created by haodong  on 13-7-16.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "EditGenderCell.h"
#import "UIImage+normalized.h"

@interface EditGenderCell()
@property (strong, nonatomic) NSIndexPath *indexPath;

@end


@implementation EditGenderCell

+ (NSString*)getCellIdentifier
{
    return @"EditGenderCell";
}

+ (CGFloat)getCellHeight
{
    return 46.0;
}

+ (id)createCell
{
    EditGenderCell *cell = (EditGenderCell *)[super createCell];
    [cell.selectButton setBackgroundImage:[SportColor clearButtonHighlightedBackgroundImage] forState:UIControlStateHighlighted];
    return cell;
}

- (void)updateCell:(NSString *)value
        isSelected:(BOOL)isSelected
         indexPath:(NSIndexPath *)indexPath
{
    self.genderLabel.text = value;
    self.indexPath = indexPath;
    if (isSelected) {
        self.markImageView.hidden = NO;
        self.markImageView.image = [SportImage markImage];
    } else{
        self.markImageView.hidden = YES;
    }

    self.backgroundImageView.image = [[SportImage whiteBackgroundWithGrayLineImage] stretchableImageWithLeftCapWidth:3 topCapHeight:3];
}

- (IBAction)clickButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickEditGenderCell:)]) {
        [_delegate didClickEditGenderCell:_indexPath];
    }
}

@end
