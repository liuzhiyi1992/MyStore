//
//  ActivityCell.h
//  Sport
//
//  Created by haodong  on 14-2-18.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"
#import "Activity.h"

@protocol ActivityCellDelegate<NSObject>
@optional
- (void)didClickActivityCell:(NSIndexPath *)indexPath;
- (void)didClickActivityCellAvatarButton:(NSIndexPath *)indexPath;
@end

@interface ActivityCell : DDTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *backgroundButton;

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIButton *avatarButton;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *themeLabel;
@property (weak, nonatomic) IBOutlet UILabel *peopleNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *genderImageView;
@property (weak, nonatomic) IBOutlet UILabel *activityStatusLabel;

@property (weak, nonatomic) id<ActivityCellDelegate> delegate;

- (void)updateCell:(NSIndexPath *)indexPath activity:(Activity *)activity;

@end
