//
//  EditAvatarCell.m
//  Sport
//
//  Created by qiuhaodong on 15/5/18.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "EditAvatarCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"
#import "UserManager.h"

@interface EditAvatarCell()
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@end

@implementation EditAvatarCell


+ (NSString*)getCellIdentifier
{
    return @"EditAvatarCell";
}

+ (CGFloat)getCellHeight
{
    return 88.0;
}

+ (id)createCell
{
    EditAvatarCell *cell = [super createCell];
    cell.arrowImageView.image = [SportImage arrowRightImage];
    cell.avatarImageView.layer.cornerRadius = 30;
    cell.avatarImageView.layer.masksToBounds = YES;
    return cell;
}

- (void)updateCellWithAvatarUrl:(NSString *)avatarUrl
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.avatarImageView.clipsToBounds = YES;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[SportImage avatarDefaultImageWithGender:user != nil?user.gender:@"m"]];

    UIImage *image = [SportImage otherCellBackground4Image];
    UIImageView *bv = [[UIImageView alloc] initWithImage:image] ;
    [self setBackgroundView:bv];
}

- (IBAction)clickButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickEditAvatarCell)]) {
        [_delegate didClickEditAvatarCell];
    }
}

@end
