//
//  ForumDetailController.h
//  Sport
//
//  Created by 江彦聪 on 15/5/11.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "ForumPostCell.h"
#import "PostListView.h"
#import "WritePostController.h"

@interface ForumDetailController : SportController<ForumPostCellDelegate,PostListViewDelegate,WritePostControllerDelegate>

-(id)initWithForum:(Forum *)forum;

@end
