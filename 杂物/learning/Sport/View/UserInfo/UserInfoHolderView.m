//
//  UserInfoHolderView.m
//  Sport
//
//  Created by liuzhiyi on 15/11/5.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "UserInfoHolderView.h"
#import "UIImageView+WebCache.h"
#import "User.h"



@interface UserInfoHolderView()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *levelImageView;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UIImageView *genderImageView;
@property (weak, nonatomic) IBOutlet UILabel *signtureLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UIView *infoHolderView;
@property (weak, nonatomic) IBOutlet UIButton *sendMessageButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *traillingMarginConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cityLeadingConstrant;


@end


@implementation UserInfoHolderView

+ (UserInfoHolderView *)creatViewWithAvatarUrl:(NSURL *)url userName:(NSString *)userName city:(NSString *)city signture:(NSString *)signture gender:(NSString *)gender level:(NSString *)level iconUrl:(NSString *)iconUrl isRulesDisplay:(BOOL)isRulesDisplay viewStatus:(ViewStatus)viewStatus {
    UserInfoHolderView *view = [[NSBundle mainBundle] loadNibNamed:@"UserInfoHolderView" owner:self options:nil][0];
    
    view.sendMessageButton.layer.borderColor = [UIColor hexColor:@"4f6dcf"].CGColor;
    view.sendMessageButton.layer.borderWidth = 1.0;
    view.sendMessageButton.layer.cornerRadius = 10.0;
    view.sendMessageButton.layer.masksToBounds = YES;
    
    //适配
    //自己or他人
    if(viewStatus == ViewStatusMyself) {
        [view addConstraint:[NSLayoutConstraint constraintWithItem:view.avatarImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:view.infoHolderView attribute:NSLayoutAttributeHeight multiplier:1/0.7 constant:0.0f]];
        view.sendMessageButton.hidden = YES;
        
        //如果是自己，不显示城市和gender
        city = nil;
        gender = nil;
        
        view.traillingMarginConstraint.constant = 15;
    } else {
        view.sendMessageButton.hidden = NO;
        view.traillingMarginConstraint.constant = 77;
    
    }
    
    //有无个性签名
    if(signture.length <= 0) {
        [view addConstraint:[NSLayoutConstraint constraintWithItem:view.genderImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view.infoHolderView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-5.0]];
    }
    
    //姓名
    if(userName.length > 0) {
        view.nameLabel.text = userName;
    }else {
        view.nameLabel.text = @"";
    }
    
    //头像
    [view.avatarImageView sd_setImageWithURL:url placeholderImage:[SportImage avatarDefaultImage]];
    view.avatarImageView.layer.cornerRadius = view.avatarImageView.bounds.size.height / 2;
    view.avatarImageView.layer.masksToBounds = YES;
    
    //性别
    view.cityLeadingConstrant.constant = 24;
    if ([gender isEqualToString:GENDER_MALE]) {
        [view.genderImageView setImage:[UIImage imageNamed:@"male_background_new"]];;
    } else if ([gender isEqualToString:GENDER_FEMALE]) {
        [view.genderImageView setImage:[UIImage imageNamed:@"female_background_new"]];
    } else {
        view.cityLeadingConstrant.constant = 0;
        [view.genderImageView setImage:nil];
    }
    
    //签名
    if(signture.length > 0) {
        view.signtureLabel.text = signture;
    }else {
        view.signtureLabel.text = @"";
    }
    
    //城市
    if(city.length > 0) {
        view.cityLabel.text = city;
        view.cityLabel.hidden = NO;
    }else {
        view.cityLabel.hidden = YES;
    }
    
    //等级
    if(level.length > 0) {
        view.levelLabel.text = level;
        view.levelLabel.hidden = NO;
    }else {
        view.levelLabel.hidden = YES;
    }
    
    //是否展示
    if(isRulesDisplay){
        view.levelImageView.hidden = NO;
        view.levelLabel.hidden = NO;
        
        //等级图标
        if(iconUrl.length > 0) {
            [view.levelImageView sd_setImageWithURL:[NSURL URLWithString:iconUrl]];
        }
    }else {
        view.levelImageView.hidden = YES;
        view.levelLabel.hidden = YES;
    }

    return view;
}

- (IBAction)clickSendMessageButton:(id)sender {
    if([_delegate respondsToSelector:@selector(didSendMessage)]) {
        [_delegate didSendMessage];
    }
}

@end
