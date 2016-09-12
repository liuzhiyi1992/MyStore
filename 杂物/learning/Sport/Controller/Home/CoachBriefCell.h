//
//  CoachBriefCell.h
//  Sport
//
//  Created by liuzhiyi on 15/8/31.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"
#import "Coach.h"

@interface CoachBriefCell : DDTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *distanceButton;
@property (weak, nonatomic) IBOutlet UIImageView *auditImageView;
@property (weak, nonatomic) IBOutlet UIButton *categoryButton;

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *sizedConstraints;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headImageViewHeightConstraint;

- (void)initLayout;

- (void)updateCellWithCoach:(Coach *)coach;

@end
