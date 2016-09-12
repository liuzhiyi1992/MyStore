//
//  UserCell.h
//  Sport
//
//  Created by haodong  on 14-4-27.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@class User;

@interface UserCell : DDTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeSportLabel;
@property (weak, nonatomic) IBOutlet UILabel *sportPlanLabel;
@property (weak, nonatomic) IBOutlet UIImageView *genderBackgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *locationImageView;

- (void)updateCellWithUser:(User *)user;

@end
