//
//  SportFilterCell.m
//  Sport
//
//  Created by qiuhaodong on 15/7/27.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportFilterCell.h"
#import "UIView+Utils.h"
#import "UIImageView+WebCache.h"

@interface SportFilterCell()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) IBOutlet UIView *lineView;

@end

@implementation SportFilterCell

+ (NSString *)getCellIdentifier
{
    return @"SportFilterCell";
}

+ (CGFloat)getCellHeight00
{
    return 45;
}

+ (id)createCellWithHasImage:(BOOL)hasImage
{
    SportFilterCell *cell = [super createCell];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.iconImageView setContentMode:UIViewContentModeScaleToFill];
    [cell.iconImageView setClipsToBounds:YES];
    if (hasImage) {
        [cell.contentLabel updateOriginX:cell.iconImageView.frame.origin.x + cell.iconImageView.frame.size.width + 10];
    } else {
        [cell.contentLabel updateOriginX:cell.iconImageView.frame.origin.x];
    }
    
    return cell;
}

- (void)updateCellWithImageUrl:(NSString *)imageUrl
                       content:(NSString *)content
                    isSelected:(BOOL)isSelected
{
    if (isSelected) {
        self.contentLabel.textColor = [SportColor defaultColor];
        //[self setBackgroundColor:[SportColor hexF5F5F5Color]];
    } else {
        self.contentLabel.textColor = [UIColor hexColor:@"222222"];
        //[self setBackgroundColor:[UIColor whiteColor]];
    }
    if (imageUrl) {
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
        [self.contentLabel updateOriginX:self.iconImageView.frame.origin.x + self.iconImageView.frame.size.width + 10];
        self.iconImageView.hidden = NO;
    }else{
        [self.contentLabel updateOriginX:self.iconImageView.frame.origin.x];
        self.iconImageView.hidden = YES;
    }
    self.contentLabel.text = content;
    [self.lineView updateOriginY:44.5];
    [self.lineView updateHeight:0.5];
}

@end
