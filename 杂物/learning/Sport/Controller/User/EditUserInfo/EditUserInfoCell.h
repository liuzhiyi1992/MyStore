//
//  EditUserInfoCell.h
//  Sport
//
//  Created by haodong  on 13-7-15.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@protocol EditUserInfoCellDelegate <NSObject>
@optional
- (void)didClickEditUserInfoCell:(NSIndexPath *)indexPath;
@end


@interface EditUserInfoCell : DDTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;

@property (assign, nonatomic) id<EditUserInfoCellDelegate> delegate;

- (void)updateCellWith:(NSString *)title
                 value:(NSString *)value
             indexPath:(NSIndexPath *)indexPath
                isLast:(BOOL)isLast;

@end
