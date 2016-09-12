//
//  AboutSportController.h
//  Sport
//
//  Created by haodong  on 14-5-5.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportController.h"
#import "UserService.h"

@interface AboutSportController : SportController<UserServiceDelegate>

@property (weak, nonatomic) IBOutlet UITableView *dataTableView;

@end
