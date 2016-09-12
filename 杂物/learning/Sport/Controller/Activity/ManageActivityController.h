//
//  ManageActivityController.h
//  Sport
//
//  Created by haodong  on 14-5-1.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportController.h"
#import "PromiseUserCell.h"
#import "ActivityService.h"
#import "MyPromiseActivityCell.h"

typedef enum {
    ManageActivityCreate = 0,
    ManageActivityPromise = 1,
} ManageActivityType;

@interface ManageActivityController : SportController<UITableViewDataSource, UITableViewDelegate, ActivityServiceDelegate, PromiseUserCellDelegate, MyPromiseActivityCellDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myCreateActivityTableView;
@property (weak, nonatomic) IBOutlet UITableView *myPromiseActivityTableView;

@property (weak, nonatomic) IBOutlet UIImageView *myCreateBackgroundImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *myCreateBackgroundImageView2;

@property (weak, nonatomic) IBOutlet UIImageView *myCreateStatusImageView;
@property (weak, nonatomic) IBOutlet UILabel *myCreateCategoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *myCreateDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *myCreateStartTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *myCreateAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *myCreatePromiseEndTimeLabel;

@property (weak, nonatomic) IBOutlet UIButton *myCreateCancelButton;
@property (weak, nonatomic) IBOutlet UIButton *myCreateEnterRoomChatButton;
@property (weak, nonatomic) IBOutlet UIButton *myCreateActivityDetailButton;

@property (weak, nonatomic) IBOutlet UILabel *myCreatePromiseCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *myCreateActivityPeopleCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *myCreateAgreeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *myCreateNeedCountLabel;

@property (weak, nonatomic) IBOutlet UIButton *myCreateButton;
@property (weak, nonatomic) IBOutlet UIButton *myPromiseButton;
@property (weak, nonatomic) IBOutlet UIView *moveLineView;

@property (weak, nonatomic) IBOutlet UIImageView *tipsBackgroundImageView;

- (instancetype)initWithType:(ManageActivityType)type;

@end
