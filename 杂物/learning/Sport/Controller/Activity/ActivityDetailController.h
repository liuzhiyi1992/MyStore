//
//  ActivityDetailController.h
//  Sport
//
//  Created by haodong  on 14-2-20.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportController.h"
#import "ActivityService.h"

@interface ActivityDetailController : SportController<ActivityServiceDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *createUserAvatarButton;
@property (weak, nonatomic) IBOutlet UIImageView *createUserGenderBackgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *createUserAgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *createUserNicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *createUserAppointmentRate;
@property (weak, nonatomic) IBOutlet UILabel *createUserActivityCountLabel;

@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *themeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *costLabel;
@property (weak, nonatomic) IBOutlet UILabel *lemonLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@property (weak, nonatomic) IBOutlet UILabel *requireGenderLabel;
@property (weak, nonatomic) IBOutlet UILabel *requireAgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *requireSportLevelLabel;
@property (weak, nonatomic) IBOutlet UIImageView *requireSportLevelImageView;


@property (weak, nonatomic) IBOutlet UIView *descHoderView;
@property (weak, nonatomic) IBOutlet UIView *requireHolderView;
@property (weak, nonatomic) IBOutlet UIView *promiseUserHoderView;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView2;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView3;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView4;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView5;

@property (weak, nonatomic) IBOutlet UIImageView *pageBackgroundImageView;

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

@property (weak, nonatomic) IBOutlet UIView *bottomHolderView;
@property (weak, nonatomic) IBOutlet UIButton *managerActivityButton;
@property (weak, nonatomic) IBOutlet UIButton *promiseButton;



- (id)initWithActivityId:(NSString *)activityId;

@end
