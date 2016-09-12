//
//  ForumHomeCell.m
//  Sport
//
//  Created by haodong  on 15/5/13.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "ForumHomeCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation ForumHomeCell


+ (id)createCell
{
    ForumHomeCell *cell = [super createCell];
    cell.iconImageView.layer.cornerRadius = 2;
    cell.iconImageView.layer.masksToBounds = YES;
    return cell;
}

+ (NSString *)getCellIdentifier
{
    return @"ForumHomeCell";
}

+ (CGFloat)getCellHeight
{
    return 60;
}

- (void)updateCellWithImage:(UIImage *)image
                       name:(NSString *)name
                  indexPath:(NSIndexPath *)indexPath
                     isLast:(BOOL)isLast
{
    [self.iconImageView setImage:image ];
    self.nameLabel.text = name;
    
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
