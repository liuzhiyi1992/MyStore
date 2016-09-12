//
//  SelectedCourtJoinProductView.m
//  Sport
//
//  Created by qiuhaodong on 16/6/20.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "SelectedCourtJoinProductView.h"
#import "CourtJoin.h"
#import "UIImageView+WebCache.h"
#import "UIView+Utils.h"

@interface SelectedCourtJoinProductView()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *joinDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *remindTipsLabel;

@end

@implementation SelectedCourtJoinProductView

+ (SelectedCourtJoinProductView *)createViewWithCourtJoin:(CourtJoin *)courtJoin
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SelectedCourtJoinProductView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    SelectedCourtJoinProductView *view = (SelectedCourtJoinProductView *)[topLevelObjects objectAtIndex:0];
    [view updateWidth:[UIScreen mainScreen].bounds.size.width];
    
    view.avatarImageView.layer.cornerRadius = view.avatarImageView.frame.size.width / 2;
    view.avatarImageView.layer.masksToBounds = YES;
    
    NSURL *url = [NSURL URLWithString:courtJoin.avatarUrl];
    [view.avatarImageView sd_setImageWithURL:url placeholderImage:[SportImage avatarDefaultImage]];
    view.nickNameLabel.text = courtJoin.nickName;
    view.joinDescriptionLabel.text = courtJoin.joinDescription;
    
    if (courtJoin.leftJoinNumber == 0) {
        view.remindTipsLabel.text = @"已加满";
    } else {
        view.remindTipsLabel.text = [NSString stringWithFormat:@"还可加入%d人",courtJoin.leftJoinNumber];
    }

    return view;
}

@end
