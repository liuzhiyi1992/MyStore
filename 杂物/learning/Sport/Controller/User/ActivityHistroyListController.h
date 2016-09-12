//
//  ActivityHistroyListController.h
//  Sport
//
//  Created by haodong  on 14-5-3.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportController.h"
#import "ActivityCell.h"
#import "ActivityService.h"

@interface ActivityHistroyListController : SportController<UITableViewDataSource, UITableViewDelegate, ActivityCellDelegate, ActivityServiceDelegate>

- (instancetype)initWithUserId:(NSString *)userId;

@end
