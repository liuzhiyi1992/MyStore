//
//  CommentMessageListController.h
//  Sport
//
//  Created by 江彦聪 on 15/5/19.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportController.h"
#import "CommentMessageListCell.h"
#import "ForumService.h"

@interface CommentMessageListController : SportController<UITableViewDataSource,UITableViewDelegate,ForumServiceDelegate, CommentMessageListCellDelegate>

@end
