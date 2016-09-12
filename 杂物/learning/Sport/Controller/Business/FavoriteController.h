//
//  FavoriteController.h
//  Sport
//
//  Created by haodong  on 13-8-21.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SportController.h"
#import "BusinessService.h"
#import "CoachService.h"
#import "CoachService.h"

@interface FavoriteController : SportController<UITableViewDataSource, UITableViewDelegate, BusinessServiceDelegate, CoachServiceDelegate, CoachServiceDelegate>

@property (weak, nonatomic) IBOutlet UITableView *dataTableView;

@property (strong, nonatomic) IBOutlet UIView *navigationSegmentView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *topSegmentedControl;

@end
