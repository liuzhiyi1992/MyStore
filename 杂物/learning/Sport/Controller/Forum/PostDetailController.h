//
//  PostDetailController.h
//  Sport
//
//  Created by 江彦聪 on 15/5/12.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportController.h"
#import "Post.h"
#import "ForumService.h"
#import "ForumPostCell.h"
#import "PostCommentCell.h"

@interface PostDetailController : SportController<ForumServiceDelegate,UITextFieldDelegate,ForumPostCellDelegate, PostCommentCellDelegate>
-(id)initWithPost:(Post *)post
      isShowTitle:(BOOL)isShowTitle;
@end
