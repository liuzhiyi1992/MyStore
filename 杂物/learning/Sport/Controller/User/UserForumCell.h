//
//  UserForumCell.h
//  Sport
//
//  Created by qiuhaodong on 15/5/17.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@class Forum;

@protocol UserForumCellDelegate <NSObject>
@optional
- (void)didClickUserForumCell:(Forum *)forum;
@end

@interface UserForumCell : DDTableViewCell
@property (assign, nonatomic) id<UserForumCellDelegate> delegate;

- (void)updateCellWithForum:(Forum *)forum isLast:(BOOL)isLast;

@end
