//
//  CommentCell.h
//  Coach
//
//  Created by quyundong on 15/7/23.
//  Copyright (c) 2015年 ningmi. All rights reserved.
//

#import "DDTableViewCell.h"
#import "Comment.h"

@protocol CommentCellDelegate <NSObject>
@optional

-(void)didClickCommentCellImage:(NSIndexPath *)indexPath
                      openIndex:(int)openIndex;
@end

@interface CommentCell : DDTableViewCell
@property (weak, nonatomic) id<CommentCellDelegate> delegate;

- (void)updateCell:(Comment *)comment
         indexPath:(NSIndexPath *)indexPath;

- (CGFloat)getCellHeightWithComment:(Comment *)comment
                    tableViewBounds:(CGRect)tableViewBounds;
@end
