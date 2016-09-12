//
//  UserInfoController.h
//  Sport
//
//  Created by qiuhaodong on 15/5/17.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportController.h"
#import "UserForumCell.h"
#import "UserService.h"
#import "PostHolderView.h"

@interface UserInfoController : SportController<UserForumCellDelegate, UITableViewDataSource, UITableViewDataSource, UserServiceDelegate, PostHolderViewDelegate>

- (instancetype)initWithUserId:(NSString *)userId;

@end
