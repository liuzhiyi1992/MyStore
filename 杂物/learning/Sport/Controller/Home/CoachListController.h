//
//  CoachListController.h
//  Sport
//
//  Created by qiuhaodong on 15/7/15.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportController.h"
#import "CoachFilterController.h"

@interface CoachListController : SportController

@property (weak, nonatomic) IBOutlet UIButton *headerLeftButton;
@property (weak, nonatomic) IBOutlet UIButton *headerRightButton;
@property (weak, nonatomic) IBOutlet UIImageView *slideBar;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHolerViewHeightConstraint;

@end
