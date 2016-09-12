//
//  CreateActivityController.h
//  Sport
//
//  Created by haodong  on 14-5-1.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportController.h"
#import "SportPickerView.h"
#import "SportStartAndEndTimePickerView.h"
#import "SportTimePickerView.h"
#import "ActivityService.h"
#import "LocateInMapController.h"

@protocol CreateActivityControllerDelegate <NSObject>
@optional
- (void)didCreateActivitySuccess;
@end

@interface CreateActivityController : SportController<SportPickerViewDelegate, UITextFieldDelegate,SportStartAndEndTimePickerViewDelegate, SportTimePickerViewDelegate, UITextViewDelegate, ActivityServiceDelegate, LocateInMapControllerDelegate, UIAlertViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *selectProjectButton;
@property (weak, nonatomic) IBOutlet UIImageView *themeSelectedBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *selectPeopleCountButton;
@property (weak, nonatomic) IBOutlet UITextField *totalCostTextField;
@property (weak, nonatomic) IBOutlet UIImageView *costTypeSelectedBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *activityTimeButton;
@property (weak, nonatomic) IBOutlet UIImageView *ningmengTypeSelectedBackgroundImageView;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UIButton *proimseEndTimeButton;
@property (weak, nonatomic) IBOutlet UITextView *descTextView;
@property (weak, nonatomic) IBOutlet UILabel *descTipsLabel;

@property (weak, nonatomic) IBOutlet UIButton *requireSwitchButton;
@property (weak, nonatomic) IBOutlet UIView *requireHolderView;
@property (weak, nonatomic) IBOutlet UIButton *requireGenderButton;
@property (weak, nonatomic) IBOutlet UIButton *requireMinAgeButton;
@property (weak, nonatomic) IBOutlet UIButton *requireMaxAgeButton;
@property (weak, nonatomic) IBOutlet UIImageView *requireLevelSelectedBackgroundImageView;

@property (weak, nonatomic) IBOutlet UIControl *clearControl;

@property (assign, nonatomic) id<CreateActivityControllerDelegate> delegate;

@end
