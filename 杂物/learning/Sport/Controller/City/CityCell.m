//
//  CityCell.m
//  Sport
//
//  Created by haodong  on 13-8-5.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "CityCell.h"

@interface CityCell()
@property (strong, nonatomic) NSIndexPath *indexPath;
@end

@implementation CityCell


+ (NSString*)getCellIdentifier
{
    return @"CityCell";
}

+ (CGFloat)getCellHeight
{
    return 44.0;
}

+ (id)createCell
{
    CityCell *cell = (CityCell *)[super createCell];
    return cell;
}

- (void)updateCell:(NSString *)valueString
         indexPath:(NSIndexPath *)indexPath
        isSelected:(BOOL)isSelected
            isLast:(BOOL)isLast
{
    self.valueLabel.text = valueString;
    self.indexPath = indexPath;
    
    if (isSelected) {
        self.markImageView.hidden = NO;
        self.markImageView.image = [SportImage markImage];
    } else{
        self.markImageView.hidden = YES;
    }
    
    UIImage *image = nil;
    if (indexPath.row == 0 && isLast) {
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

//- (IBAction)clickButton:(id)sender {
//    if ([_delegate respondsToSelector:@selector(didClickCityCell:)]) {
//        [_delegate didClickCityCell:_indexPath];
//    }
//}

@end
