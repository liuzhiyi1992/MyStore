//
//  EditImageListCell.h
//  Sport
//
//  Created by haodong  on 14-5-7.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@protocol EditImageListCellDelegate <NSObject>
@optional
- (void)didClickEditImageListCellImage:(NSIndexPath *)indexPath imageIndex:(NSInteger)imageIndex;
- (void)didClickEditImageListCellAddButton:(NSIndexPath *)indexPath;
@end

@interface EditImageListCell : DDTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (assign, nonatomic) id<EditImageListCellDelegate> delegate;

- (void)updateCellWith:(NSString *)title
          imageUrlList:(NSArray *)imageUrlList
             indexPath:(NSIndexPath *)indexPath
                isLast:(BOOL)isLast;

@end
