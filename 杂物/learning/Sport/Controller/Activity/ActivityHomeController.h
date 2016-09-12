//
//  ActivityHomeController.h
//  Sport
//
//  Created by haodong  on 14-2-18.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportController.h"
#import "ActivityCell.h"
#import "ActivityService.h"
#import "UserCell.h"
#import "SportPickerView.h"
#import "CreateActivityController.h"
#import "UserService.h"

@interface ActivityHomeController : SportController <UITableViewDataSource, UITableViewDelegate, ActivityCellDelegate, ActivityServiceDelegate, UIActionSheetDelegate, SportPickerViewDelegate, CreateActivityControllerDelegate, UserServiceDelegate>

@property (weak, nonatomic) IBOutlet UIView *activityHolderView;
@property (weak, nonatomic) IBOutlet UITableView *peopleTableView;
@property (weak, nonatomic) IBOutlet UITableView *activityTableView;
@property (weak, nonatomic) IBOutlet UIButton *manageActivityButton;
@property (weak, nonatomic) IBOutlet UIButton *createActivityButton;

@property (weak, nonatomic) IBOutlet UIImageView *filterBackgroundImageView;

@property (weak, nonatomic) IBOutlet UIView *peopleHolderView;

@property (weak, nonatomic) IBOutlet UIView *activityFilterHolderView;
@property (weak, nonatomic) IBOutlet UIButton *activityCategoryFilterButton;
@property (weak, nonatomic) IBOutlet UIButton *activityThemeFilterButton;
@property (weak, nonatomic) IBOutlet UIButton *activitySortFilterButton;

@property (weak, nonatomic) IBOutlet UIButton *peopleGenderFilterButton;
@property (weak, nonatomic) IBOutlet UIButton *peopleCategoryFilterButton;

@property (weak, nonatomic) IBOutlet UIImageView *tipsBackgroundImageView;

@property (weak, nonatomic) IBOutlet UIView *updateUserInfoTipsHolderView;
@property (weak, nonatomic) IBOutlet UIButton *updateUserInfoButton;
@property (weak, nonatomic) IBOutlet UIImageView *updateUserInfoGrayBackgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *updateUserInfoTipsLabel;


@end
