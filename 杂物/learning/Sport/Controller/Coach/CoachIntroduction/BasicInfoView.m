//
//  BasicInfoView.m
//  Coach
//
//  Created by quyundong on 15/9/14.
//  Copyright (c) 2015年 ningmi. All rights reserved.
//

#import "BasicInfoView.h"
#import "CoachAuthenticationInfoView.h"
#import "UIImage+normalized.h"

#define LEVEL_STATUS_PASS 3

@interface BasicInfoView ()
@property (weak, nonatomic) IBOutlet UILabel *ageWeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *genderImageView;
@property (weak, nonatomic) IBOutlet UILabel *bookedCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *wantBookCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *authenticationInfoButton;
@property (weak, nonatomic) IBOutlet UIView *authenticationInfoButtonView;
@property (strong, nonatomic) CoachAuthenticationInfoView *authenticationInfoView;
@property (strong, nonatomic) Coach *coach;
@end
@implementation BasicInfoView

+ (BasicInfoView *)createBasicInfoView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"BasicInfoView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    BasicInfoView *view = [topLevelObjects objectAtIndex:0];
    ;
    [view.authenticationInfoButton setBackgroundImage:[[UIImage imageNamed:@"blue_radius"] stretchableImageWithLeftCapWidth:9 topCapHeight:7] forState:UIControlStateNormal];
    
    return view;
}

- (void)updateWithUser:(Coach *)coach {
    self.coach = coach;
    
    self.ageWeightLabel.text = [NSString stringWithFormat:@"%d岁/%dcm/%dkg",coach.age,coach.height,coach.weight];
    self.userNameLabel.text = coach.name;
    NSString *imageName = [coach.gender isEqualToString:@"m"]?@"skim_gender_male":@"skim_gender_female";
    self.genderImageView.image = [UIImage imageNamed:imageName];
    self.bookedCountLabel.text = [NSString stringWithFormat:@"%@人约过",[@(coach.studentCount) stringValue]];
    self.wantBookCountLabel.text = [NSString stringWithFormat:@"%d人想约",coach.collectNumber];
    if(coach.levelStatus == LEVEL_STATUS_PASS) {
        _authenticationInfoButtonView.hidden = NO;
    }else{
        _authenticationInfoButtonView.hidden = YES;
    }
}

- (IBAction)clickAuthenticationInfoButton:(UIButton *)sender {
    
    NSArray *tempArray = [self.coach.levelDesc componentsSeparatedByString:@"，"];

    self.authenticationInfoView = [CoachAuthenticationInfoView createCoachAuthenticationInfoViewWithDateList:tempArray];
    [_authenticationInfoView show];
}

- (void)dealloc {
    [_authenticationInfoView dismiss];
}


@end
