//
//  PostHolderView.m
//  Sport
//
//  Created by liuzhiyi on 15/11/5.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "PostHolderView.h"
#import "UIImageView+WebCache.h"
#import "UserPostListController.h"

@interface PostHolderView()
@property (weak, nonatomic) IBOutlet UILabel *whoPostLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;


@end


@implementation PostHolderView

+ (NSString *)getCellIdentifier {
    return @"PostHolderView";
}

+ (CGFloat)getCellHeight {
    return 85;
}

+ (PostHolderView *)creatViewWithStatus:(BOOL)status count:(NSString *)count imageUrl:(NSURL *)imageUrl content:(NSString *)content{
    PostHolderView *view = [[NSBundle mainBundle] loadNibNamed:@"PostHolderView" owner:self options:nil][0];
    
    view.whoPostLabel.text = status ? @"我的贴子" : @"TA的贴子";
    view.countLabel.text = count;
    if(imageUrl != nil) {
        [view.avatarImageView sd_setImageWithURL:imageUrl placeholderImage:[SportImage defaultImage_300x155]];
    }else {
        [view.avatarImageView removeFromSuperview];
    }
    
    view.avatarImageView.layer.masksToBounds = YES;
    view.contentLabel.text = content;
    
    return view;
}

- (void)updateViewWithCount:(NSString *)count imageUrl:(NSURL *)imageUrl content:(NSString *)content {
    
    self.countLabel.text = count;
    if(imageUrl != nil) {
        [self.avatarImageView sd_setImageWithURL:imageUrl];
    }else {
        [self.avatarImageView removeFromSuperview];
    }
    self.contentLabel.text = content;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_delegate postHolderViewDidClickedWithTitle:self.whoPostLabel.text];
    //跳转到帖子列表
}

@end
