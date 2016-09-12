//
//  PromiseUserCell.h
//  Sport
//
//  Created by haodong  on 14-5-1.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@protocol PromiseUserCellDelegate <NSObject>
@optional
- (void)didClickPromiseUserCellButton:(NSIndexPath *)indexPath;
- (void)didClickPromiseUserCellAvatarButton:(NSIndexPath *)indexPath;

@end

@class ActivityPromise;

@interface PromiseUserCell : DDTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (weak, nonatomic) IBOutlet UIButton *avatarButton;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *genderBackgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;

@property (weak, nonatomic) IBOutlet UILabel *appointmentRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *lemonCountLabel;

@property (weak, nonatomic) IBOutlet UIButton *actionButton;

@property (assign, nonatomic) id<PromiseUserCellDelegate> delegate;

- (void)updateCellWithPromise:(ActivityPromise *)promise
                    indexPath:(NSIndexPath *)indexPath
                       isLast:(BOOL)isLast;

- (void)updateActionButton;

@end
