//
//  MyActivityController.h
//  Sport
//
//  Created by haodong  on 14-3-5.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportController.h"
#import "ActivityService.h"
#import "ActivityPeopleCell.h"
#import "ActivityCell.h"

@interface MyActivityController : SportController <UITableViewDataSource, UITableViewDelegate, ActivityServiceDelegate, ActivityPeopleCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myPublishTableView;
@property (weak, nonatomic) IBOutlet UITableView *myPromiseTableView;
@property (weak, nonatomic) IBOutlet UIButton *myPublishButton;
@property (weak, nonatomic) IBOutlet UIButton *myPromiseButton;
@end
