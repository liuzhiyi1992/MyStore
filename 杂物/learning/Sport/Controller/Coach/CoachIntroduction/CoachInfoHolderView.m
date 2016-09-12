//
//  CoachInfoHolderView.m
//  Sport
//
//  Created by liuzhiyi on 15/9/30.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "CoachInfoHolderView.h"
#import "UIView+Utils.h"
#import "CoachServiceArea.h"
#import "CoachSportExperience.h"
#import "CoachOftenArea.h"

#define TEXT_EMPLY @"无"

@interface CoachInfoHolderView()

@property (assign, nonatomic) BOOL isLaunching;

@end

@implementation CoachInfoHolderView

+ (CoachInfoHolderView *)createViewWithCoach:(Coach *)coach {
    
    CoachInfoHolderView *view = [[NSBundle mainBundle] loadNibNamed:@"CoachInfoHolderView" owner:self options:nil][0];
    
    //运动经历
    NSString *sportExperienceString = [view sportExperienceStringWithCoach:coach];
    if(sportExperienceString.length <= 0){
        view.experienceLabel.text = TEXT_EMPLY;
    }else {
        view.experienceLabel.text = sportExperienceString;
    }
    
    //常驻场馆
    NSString *oftenAreaString = [view oftenAreaStringWithCoach:coach];
    if(oftenAreaString.length <= 0){
        view.oftenSpaceLabel.text = TEXT_EMPLY;
    }else{
        view.oftenSpaceLabel.text = oftenAreaString;
    }
    
    //服务区域
    NSString *servicesString = [view serviceStringWithCoach:coach];
    if(servicesString.length <= 0){
        view.areaLabel.text = TEXT_EMPLY;
    }else {
        view.areaLabel.text = servicesString;
    }
    
    //个人介绍
    view.introduceLabel.text = coach.introduction;

    return view;
}

- (NSString *)serviceStringWithCoach:(Coach *)coach
{
    NSMutableString *string = [NSMutableString stringWithString:@""];
    for (CoachServiceArea *area in coach.serviceAreaList) {
        [string appendFormat:@"%@ ", area.regionName];
    }
    return string;
}

- (NSString *)sportExperienceStringWithCoach:(Coach *)coach {
    NSMutableString *tempString = [NSMutableString string];
    NSString *string = @"";
    for (CoachSportExperience *experience in coach.sportExperienceList) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy/MM"];
        
        [tempString appendFormat:@"%@", [formatter stringFromDate:experience.startTime]];
        [tempString appendFormat:@"-%@ ", [formatter stringFromDate:experience.endTime]];
        [tempString appendFormat:@"%@\n", experience.experienceContent];
    }
    if(tempString.length > 0) {//剪掉最后一个换行符]
        string = [tempString substringToIndex:tempString.length - 1];
    }
    return string;
}

- (NSString *)oftenAreaStringWithCoach:(Coach *)coach {
    NSMutableString *tempStr = [NSMutableString string];
    NSString *string = @"";
    for (CoachOftenArea *area in coach.oftenAreaList) {
        [tempStr appendFormat:@"%@\n", area.businessName];
    }
    if(tempStr.length > 0){//剪掉最后一个换行符
        string = [tempStr substringToIndex:tempStr.length - 1];
    }
    return string;
}


- (IBAction)clickLaunchButton:(id)sender {
    
    if(_isLaunching) {
        [self packUpInfo];
        [((UIButton *)sender) setImage:[UIImage imageNamed:@"arrow_down_black"] forState:UIControlStateNormal];
    }else{
        [self launchMoreInfo];
        [((UIButton *)sender) setImage:[UIImage imageNamed:@"arrow_up_black"] forState:UIControlStateNormal];
    }
}

- (void)launchMoreInfo {
    //展开label
    _oftenSpaceLabel.numberOfLines = 0;
    _experienceLabel.numberOfLines = 0;
    _oftenSpaceLabel.numberOfLines = 0;
    _introduceLabel.numberOfLines = 0;
    _areaLabel.numberOfLines = 0;
    
    [self layoutIfNeeded];
    [self updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:0.5f animations:^{

    }];
    
    _isLaunching = YES;
}

- (void)packUpInfo {
    //收起label
    _oftenSpaceLabel.numberOfLines = 1;
    _experienceLabel.numberOfLines = 1;
    _oftenSpaceLabel.numberOfLines = 1;
    _introduceLabel.numberOfLines = 1;
    _areaLabel.numberOfLines = 1;
    
    [UIView animateWithDuration:0.5f animations:^{
        //[self updateHeight:CGRectGetMaxY(self.launchButton.frame)];
    }];
    
    _isLaunching = NO;
}


@end
