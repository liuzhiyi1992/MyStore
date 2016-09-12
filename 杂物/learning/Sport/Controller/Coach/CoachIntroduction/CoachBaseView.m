//
//  CoachBaseView.m
//  Sport
//
//  Created by qiuhaodong on 15/7/22.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CoachBaseView.h"
#import "Coach.h"
#import "UIButton+WebCache.h"
#import "UIView+Utils.h"

@interface CoachBaseView()
@property (assign, nonatomic) id<CoachBaseViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *avatarButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *genderImageView;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *signatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *studentCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@end

@implementation CoachBaseView


+ (CoachBaseView *)createViewWithCoach:(Coach *)coach
                              delegate:(id<CoachBaseViewDelegate>)delegate
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CoachBaseView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    CoachBaseView *view = [topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    [view updateWidth:[UIScreen mainScreen].bounds.size.width];
    view.avatarButton.layer.cornerRadius = view.avatarButton.frame.size.height / 2;
    view.avatarButton.layer.masksToBounds = YES;
    view.avatarButton.layer.borderColor = [SportColor defaultButtonInactiveColor].CGColor;
    view.avatarButton.layer.borderWidth = 0.5f;
    [view.backgroundImageView setImage:[SportImage whiteBackgroundImage]];
    [view.avatarButton sd_setImageWithURL:[NSURL URLWithString:coach.avatarUrl] forState:UIControlStateNormal placeholderImage:[SportImage headImageView]];
    view.avatarButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    view.nameLabel.text = coach.name;
    if ([coach.gender length] > 0) {
        if ([coach.gender isEqualToString:@"m"]) {
            [view.genderImageView setImage:[SportImage genderMaleImage]];
        } else {
            [view.genderImageView setImage:[SportImage genderFemaleImage]];
        }
        
        //计算名字长度
        CGSize nameSize ;
        if ([view.nameLabel.text respondsToSelector:@selector(sizeWithAttributes:)]) {
            nameSize = [view.nameLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObject:view.nameLabel.font forKey:NSFontAttributeName]];
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            nameSize = [view.nameLabel.text sizeWithFont:view.nameLabel.font];
#pragma clang diagnostic pop
        }
        [view.genderImageView updateOriginX:view.frame.size.width / 2 + nameSize.width / 2 + 6];
    }
    view.ageLabel.text = [NSString stringWithFormat:@"%d岁/%dcm/%dkg", coach.age, coach.height, coach.weight];
    view.signatureLabel.text = coach.introduction;
    view.studentCountLabel.text = [NSString stringWithFormat:@"%@人", [@(coach.studentCount) stringValue]];
    view.durationLabel.text = [NSString stringWithFormat:@"%@小时", [@(coach.totalTime) stringValue]];
    view.rateLabel.text = [NSString stringWithFormat:@"%.1f", coach.rate];
    view.signatureLabel.text = coach.introduction;
    
    CGSize signatureSize = [view.signatureLabel sizeThatFits:CGSizeMake(view.signatureLabel.frame.size.width, 100)];
    [view.signatureLabel updateHeight:signatureSize.height];
    
    [view updateHeight:view.signatureLabel.frame.origin.y + view.signatureLabel.frame.size.height + 14];
    
    return view;
}

- (IBAction)clickAvatarButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didClickCoachBaseViewAvatar)]) {
        [self.delegate didClickCoachBaseViewAvatar];
    }
}

@end
