//
//  UserForumCell.m
//  Sport
//
//  Created by qiuhaodong on 15/5/17.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "UserForumCell.h"
#import "Forum.h"
#import "UIImageView+WebCache.h"
#import "Forum.h"
#import <QuartzCore/QuartzCore.h>

@interface UserForumCell()

@property (strong, nonatomic) Forum *forum;

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *lineImageView;

@end

@implementation UserForumCell


+ (CGFloat)getCellHeight
{
    return 65;
}

+ (NSString *)getCellIdentifier
{
    return @"UserForumCell";
}

+ (id)createCell
{
    UserForumCell *cell = [super createCell];
    cell.lineImageView.image = [SportImage lineImage];
    cell.iconImageView.layer.cornerRadius = 2;
    cell.iconImageView.layer.masksToBounds = YES;
    return cell;
}

- (void)updateCellWithForum:(Forum *)forum isLast:(BOOL)isLast
{
    self.forum = forum;
    
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:forum.imageUrl] placeholderImage:nil];
    self.nameLabel.text = forum.forumName;
    if (isLast) {
        self.lineImageView.hidden = YES;
    } else {
        self.lineImageView.hidden = NO;
    }
}

- (IBAction)clickButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickUserForumCell:)]) {
        [_delegate didClickUserForumCell:_forum];
    }
}

@end
