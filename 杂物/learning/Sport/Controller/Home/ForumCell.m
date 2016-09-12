//
//  ForumCell.m
//  Sport
//
//  Created by haodong  on 15/5/12.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "ForumCell.h"
#import <QuartzCore/QuartzCore.h>
#import "Forum.h"
#import "UIImageView+WebCache.h"
#import "UIView+Utils.h"

@interface ForumCell()

@end

@implementation ForumCell

+ (id)createCell
{
    ForumCell *cell = [super createCell];
    cell.iconImageView.layer.cornerRadius = 2;
    cell.iconImageView.layer.masksToBounds = YES;
    return cell;
}

+ (NSString *)getCellIdentifier
{
    return @"ForumCell";
}

+ (CGFloat)getCellHeight
{
    return 60;
}

- (void)updateCellWithForum:(Forum *)forum
                  indexPath:(NSIndexPath *)indexPath
                     isLast:(BOOL)isLast
{
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
    
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:forum.imageUrl] placeholderImage:nil];
    self.nameLabel.text = forum.forumName;
    
    if (forum.currentPostCount > 0) {
        self.countLabel.hidden = NO;
        self.countLabel.text = [NSString stringWithFormat:@"%@贴子", [@(forum.totalPostCount) stringValue]];
    } else {
        self.countLabel.hidden = YES;
    }
    
    if (forum.isOftenGoTo) {
        self.oftenImageView.hidden = NO;
        [self.oftenImageView setImage:[SportImage forumOftenImage]];
        
        CGSize size = [self.nameLabel sizeThatFits:self.nameLabel.frame.size];
        CGFloat x = self.nameLabel.frame.origin.x + size.width + 2;
        [self.oftenImageView updateOriginX:x];
    } else {
        self.oftenImageView.hidden = YES;
    }
}

@end
