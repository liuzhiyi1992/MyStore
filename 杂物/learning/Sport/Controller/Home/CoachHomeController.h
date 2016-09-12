//
//  CoachHomeController.h
//  Sport
//
//  Created by liuzhiyi on 15/8/31.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SportController.h"

@interface CoachHomeController : SportController<UITableViewDelegate, UITableViewDataSource>


@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *headerViewLeftButton;
@property (weak, nonatomic) IBOutlet UIButton *headerViewRightButton;
@property (weak, nonatomic) IBOutlet UIImageView *slideBar;

@end
