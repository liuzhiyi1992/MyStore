//
//  ForumPostCell.h
//  Sport
//
//  Created by 江彦聪 on 15/5/9.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"
#import "Post.h"
#import "PostPhoto.h"
#import "Forum.h"

@protocol ForumPostCellDelegate <NSObject>
@optional
-(void)didClickForumButton:(NSIndexPath *)indexPath;
-(void)didClickAvatarButton:(NSIndexPath *)indexPath;
-(void)didClickForumPostImage:(NSIndexPath *)indexPath
                    openIndex:(int)openIndex;
@end

@interface ForumPostCell : DDTableViewCell
@property (assign, nonatomic) id<ForumPostCellDelegate> delegate;

+ (id)createCellWithCellLineHidden:(BOOL)hidden;

- (void)updateCell:(Post *)post
         indexPath:(NSIndexPath *)indexPath
   isShowForumName:(BOOL)isShowForumName
isShowCommentCount:(BOOL)isShowCommentCount
            isLast:(BOOL)isLast;

- (CGFloat)getCellHeightWithPost:(Post *)post
                       indexPath:(NSIndexPath *)indexPath
                 tableViewBounds:(CGRect)tableViewBounds;

@end
