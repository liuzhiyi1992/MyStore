//
//  CoachInfoHolderView.h
//  Sport
//
//  Created by liuzhiyi on 15/9/30.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Coach.h"

@interface CoachInfoHolderView : UIView
@property (weak, nonatomic) IBOutlet UILabel *experienceLabel;

@property (weak, nonatomic) IBOutlet UILabel *oftenSpaceLabel;

@property (weak, nonatomic) IBOutlet UILabel *areaLabel;

@property (weak, nonatomic) IBOutlet UILabel *introduceLabel;

@property (weak, nonatomic) IBOutlet UIButton *launchButton;

+ (CoachInfoHolderView *)createViewWithCoach:(Coach *)coach;


@end
