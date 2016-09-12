//
//  AvatarLabelView.m
//  Sport
//
//  Created by 江彦聪 on 15/12/15.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "AvatarLabelView.h"
#import "UIImageView+WebCache.h"
#import "CourtJoinUser.h"
@interface AvatarLabelView()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (copy,nonatomic) NSString *userId;
@property (weak, nonatomic) IBOutlet UIButton *avatarButton;


@end

@implementation AvatarLabelView

+ (AvatarLabelView *)createAvatarLabelViewWithFrame:(CGRect)frame
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"AvatarLabelView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    AvatarLabelView *view = (AvatarLabelView *)[topLevelObjects objectAtIndex:0];
    view.frame = frame;
    view.avatarImage.layer.cornerRadius = 25;
    view.avatarImage.layer.masksToBounds = YES;
    return view;
}

+ (CGSize)defaultSize {
    return CGSizeMake(53, 80);
}


- (void)updateAvatarWithUser:(CourtJoinUser *)user {
    
    if (user == nil) {
        // 如为空，则显示拼场中的状态。
        [self.avatarImage setImage:[UIImage imageNamed:@"PoolingImage"]];
        self.nameLabel.text = @"";
        self.userId = nil;
        self.avatarButton.enabled = NO;
    } else {
        [self.avatarImage sd_setImageWithURL:[NSURL URLWithString:user.avatarUrl] placeholderImage:[SportImage avatarDefaultImage]];
        self.nameLabel.text = user.userName;
        self.userId = user.userId;
        
        self.avatarButton.enabled = YES;
    }
}

- (IBAction)clickAvatarButton:(id)sender {
    if([self.userId length] == 0) {
        return;
    }
    
    if([_delegate respondsToSelector:@selector(didClickAvatarButton:)]){
        [_delegate didClickAvatarButton:self.userId];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/




@end
