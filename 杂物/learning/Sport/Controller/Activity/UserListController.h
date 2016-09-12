//
//  UserListController.h
//  Sport
//
//  Created by haodong  on 15/5/15.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportController.h"
#import "ActivityService.h"
//#import "SportPickerView.h"
#import "SportFilterListView.h"
@interface UserListController : SportController<UITableViewDataSource, UITableViewDelegate, ActivityServiceDelegate,SportFilterListViewDelegate>

@end
