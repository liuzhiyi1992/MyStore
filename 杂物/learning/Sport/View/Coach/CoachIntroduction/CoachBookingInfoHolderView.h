//
//  CoachBookingInfoHolderView.h
//  Sport
//
//  Created by liuzhiyi on 15/10/8.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoachItemCell.h"
#import "CoachIntroductionController.h"

@interface CoachBookingInfoHolderView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *leftHeaderButton;
@property (weak, nonatomic) IBOutlet UIButton *rightHeaderButton;
@property (weak, nonatomic) IBOutlet UIView *slideBar;
@property (weak, nonatomic) IBOutlet UIView *drawerHolderView;
@property (weak, nonatomic) IBOutlet UITableView *itemTabelView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *drawerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *itemTableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slideBarleadingConstraint;


@property (weak, nonatomic) CoachIntroductionController *superViewController;
@property (strong, nonatomic) NSArray *coachProjectList;



+ (CoachBookingInfoHolderView *)creatCoachBookingInfoHolderViewWithProjectList:(NSArray *)projectList;


@end
