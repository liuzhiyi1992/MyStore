//
//  ForumHomeController.h
//  Sport
//
//  Created by haodong  on 15/5/11.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportController.h"
#import "PostListView.h"
#import "ForumCell.h"
#import "ForumService.h"

@interface ForumHomeController : SportController<PostListViewDelegate, UITableViewDataSource, UITableViewDelegate, ForumServiceDelegate, UISearchBarDelegate>

@end
