//
//  SportCommonCell.m
//  Sport
//
//  Created by haodong  on 13-7-31.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SportCommonCell.h"

@interface SportCommonCell()
@property (strong, nonatomic) NSIndexPath *indexPath;
@end

@implementation SportCommonCell


+ (NSString*)getCellIdentifier
{
    return @"SportCommonCell";
}

+ (CGFloat)getCellHeight
{
    return 44.0;
}

+ (id)createCell
{
    SportCommonCell *cell = (SportCommonCell *)[super createCell];
    cell.arrowImageView.image = [SportImage arrowRightImage];
    return cell;
}

- (void)updateCell:(NSString *)valueString
         indexPath:(NSIndexPath *)indexPath
            isLast:(BOOL)isLast
         tipsCount:(NSUInteger)tipsCount
    isShowRedPoint:(BOOL)isShowRedPoint
{
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
    
    if (tipsCount > 0) {
        self.tipsCountButton.hidden = NO;
        [self.tipsCountButton setTitle:[@(tipsCount) stringValue] forState:UIControlStateNormal];
    } else {
        self.tipsCountButton.hidden = YES;
    }
    
    if (isShowRedPoint) {
        self.redPointImageView.hidden = NO;
    } else {
        self.redPointImageView.hidden = YES;
    }
}

- (IBAction)clickButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickSportCommonCell:)]) {
        [_delegate didClickSportCommonCell:_indexPath];
    }
}

@end