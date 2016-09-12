//
//  CommentMessageListCell.h
//  Sport
//
//  Created by 江彦聪 on 15/5/19.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"
#import "CommentMessage.h"

@protocol CommentMessageListCellDelegate <NSObject>

-(void)didClickMessageButton:(CommentMessage*) message;
-(void)didClickAvatarButton:(NSIndexPath *)indexPath;

@end

@interface CommentMessageListCell : DDTableViewCell
- (CGFloat)getCellHeightWithCommentMessage:(CommentMessage *)message
                                 indexPath:(NSIndexPath *)indexPath
                           tableViewBounds:(CGRect)tableViewBounds;
- (void)updateCell:(CommentMessage *)message
         indexPath:(NSIndexPath *)indexPath
            isLast:(BOOL)isLast;

@property (assign,nonatomic) id<CommentMessageListCellDelegate> delegate;
@end
