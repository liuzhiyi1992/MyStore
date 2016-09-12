//
//  SystemMessageCategoryListCell.h
//  Sport
//
//  Created by 江彦聪 on 15/5/19.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"
#import "SystemMessage.h"

@protocol SystemMessageCategoryListCellDelegate <NSObject>
@optional
-(void)didClickMessageButton:(SystemMessage*) message;

@end

@interface SystemMessageCategoryListCell : DDTableViewCell

- (void)updateCell:(SystemMessage *)message
         indexPath:(NSIndexPath *)indexPath
            isLast:(BOOL)isLast;

@property (assign,nonatomic) id<SystemMessageCategoryListCellDelegate> delegate;
@end
