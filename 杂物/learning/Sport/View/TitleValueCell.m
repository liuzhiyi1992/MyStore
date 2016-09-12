//
//  TitleValueCell.m
//  Sport
//
//  Created by haodong  on 13-7-31.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "TitleValueCell.h"

@interface TitleValueCell()
@property (strong, nonatomic) NSIndexPath *indexPath;
@end

@implementation TitleValueCell


+ (NSString*)getCellIdentifier
{
    return @"TitleValueCell";
}

+ (CGFloat)getCellHeight
{
    return 44.0;
}

+ (id)createCell
{
    TitleValueCell *cell = (TitleValueCell *)[super createCell];
    cell.arrowImageView.image = [SportImage arrowRightImage];
    return cell;
}

- (void)updateCell:(NSString *)titleString
       valueString:(NSString *)valueString
         indexPath:(NSIndexPath *)indexPath
            isLast:(BOOL)isLast
{
    self.titleLabel.text = titleString;
    self.valueLabel.text = valueString;
    self.indexPath = indexPath;
    
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

- (IBAction)clickButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickTitleValueCell:)]) {
        [_delegate didClickTitleValueCell:_indexPath];
    }
}

@end
