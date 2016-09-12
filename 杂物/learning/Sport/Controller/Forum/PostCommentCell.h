//
//  PostCommentCell.h
//  Sport
//
//  Created by 江彦聪 on 15/5/14.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"
#import "PostComment.h"

@protocol PostCommentCellDelegate <NSObject>
- (void)didClickPostCommentCellUser:(NSIndexPath *)indexPath;

@end

@interface PostCommentCell : DDTableViewCell

@property (assign, nonatomic) id<PostCommentCellDelegate> delegate;

- (void)updateCell:(PostComment *)comment
         indexPath:(NSIndexPath *)indexPath
            isLast:(BOOL)isLast;

- (CGFloat)getCellHeightWithTableViewBounds:(CGRect)tableViewBounds;

@end
