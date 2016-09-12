//
//  CoachCollectionCell.h
//  Sport
//
//  Created by liuzhiyi on 15/9/2.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDTableViewCell.h"

@class Coach;

@interface CoachCollectionCell : DDTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *sizedConstraints;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headImageViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

@property (strong, nonatomic) IBOutlet UIImageView *genderBackgroundImageView;

- (void)updateCellWithCoach:(Coach *)coach;

@end
