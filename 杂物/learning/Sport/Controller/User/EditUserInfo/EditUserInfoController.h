//
//  EditUserInfoController.h
//  Sport
//
//  Created by haodong  on 13-7-15.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SportController.h"
#import "EditUserInfoCell.h"
#import "UserService.h"
#import "SportStartAndEndTimePickerView.h"
#import "EditSportPlanController.h"
#import "UserCityListView.h"
#import "EditNicknameController.h"
#import "SportPickerView.h"
#import "EditGenderController.h"
#import "EditImageListCell.h"
#import "EditAvatarCell.h"
#import "PostHolderView.h"

@interface EditUserInfoController : SportController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UserServiceDelegate, EditUserInfoCellDelegate, SportStartAndEndTimePickerViewDelegate, EditSportPlanControllerDelegate, UserCityListViewDelegate, EditNicknameControllerDelegate, SportPickerViewDelegate, EditGenderControllerDelegate, UIAlertViewDelegate, EditImageListCellDelegate, EditAvatarCellDelegate, PostHolderViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *dataTableView;
@property (weak, nonatomic) IBOutlet UIView *pickHolderView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePickerView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *okButton;

- (instancetype)initWithUser:(User *)user levelTitle:(NSString *)levelTitle;

@end
