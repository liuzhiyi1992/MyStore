//
//  BusinessGalleryCell.m
//  Sport
//
//  Created by haodong  on 14-9-17.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "BusinessGalleryCell.h"
#import "BusinessPhoto.h"
#import "UIButton+WebCache.h"
#import <QuartzCore/QuartzCore.h>

@interface BusinessGalleryCell()
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) BusinessPhoto *firstPhoto;
@property (strong, nonatomic) BusinessPhoto *secondPhoto;
@end

@implementation BusinessGalleryCell

+ (id)createCell{
    BusinessGalleryCell *cell = [super createCell];
    cell.firstButton.layer.cornerRadius = 2.5;
    cell.firstButton.layer.masksToBounds = YES;
    cell.secondButton.layer.cornerRadius = 2.5;
    cell.secondButton.layer.masksToBounds = YES;
    return cell;
}

+ (CGFloat)getCellHeight
{
    return 125;
}

+ (NSString*)getCellIdentifier
{
    return @"BusinessGalleryCell";
}

- (void)updateCellWithFirstPhoto:(BusinessPhoto *)firstPhoto
                     secondPhoto:(BusinessPhoto *)secondPhoto
                       indexPath:(NSIndexPath *)indexPath
{
    self.indexPath = indexPath;
    self.firstPhoto = firstPhoto;
    self.secondPhoto = secondPhoto;
    
    NSURL *firstUrl = [NSURL URLWithString:firstPhoto.photoThumbUrl];
    [self.firstButton sd_setBackgroundImageWithURL:firstUrl forState:UIControlStateNormal placeholderImage:[SportImage defaultImage_143x115]];
    
    if (secondPhoto == nil) {
        self.secondButton.hidden = YES;
    } else {
        self.secondButton.hidden = NO;
        NSURL *secondUrl = [NSURL URLWithString:secondPhoto.photoThumbUrl];
        [self.secondButton sd_setBackgroundImageWithURL:secondUrl forState:UIControlStateNormal placeholderImage:[SportImage defaultImage_143x115]];
    }
}

- (IBAction)clickFirstButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickBusinessGalleryCell:)]) {
        [_delegate didClickBusinessGalleryCell:_indexPath.row * 2];
    }
}

- (IBAction)clickSecondButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickBusinessGalleryCell:)]) {
        [_delegate didClickBusinessGalleryCell:_indexPath.row * 2 + 1];
    }
}

@end
