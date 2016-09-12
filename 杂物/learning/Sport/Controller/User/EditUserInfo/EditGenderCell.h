//
//  EditGenderCell.h
//  Sport
//
//  Created by haodong  on 13-7-16.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@protocol EditGenderCellDelegate <NSObject>
@optional
- (void)didClickEditGenderCell:(NSIndexPath *)indexPath;

@end

@interface EditGenderCell : DDTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UIImageView *markImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (assign, nonatomic) id<EditGenderCellDelegate> delegate;

- (void)updateCell:(NSString *)value
        isSelected:(BOOL)isSelected
         indexPath:(NSIndexPath *)indexPath;

@end
