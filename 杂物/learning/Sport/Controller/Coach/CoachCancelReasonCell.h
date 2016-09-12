//
//  CoachCancelReasonCell.h
//  Sport
//
//  Created by 江彦聪 on 15/4/14.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDTableViewCell.h"

@protocol CoachCancelReasonCellDelegate <NSObject>

-(void)didClickButton:(NSIndexPath *)indexPath;

@end

@interface CoachCancelReasonCell : DDTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;
- (void)updateCellWithTitle:(NSString *)title
                 isSelected:(BOOL)isSelected
                  indexPath:(NSIndexPath *)indexPath;

@property (assign, nonatomic) id<CoachCancelReasonCellDelegate>delegate;
@property (strong, nonatomic) NSIndexPath *indexPath;
@end
