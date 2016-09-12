//
//  EditAvatarCell.h
//  Sport
//
//  Created by qiuhaodong on 15/5/18.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@protocol EditAvatarCellDelegate <NSObject>
@optional
- (void)didClickEditAvatarCell;

@end

@interface EditAvatarCell : DDTableViewCell
@property (assign, nonatomic) id<EditAvatarCellDelegate> delegate;

- (void)updateCellWithAvatarUrl:(NSString *)avatarUrl;

@end
