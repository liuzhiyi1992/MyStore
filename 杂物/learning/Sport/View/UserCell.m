//
//  UserCell.m
//  Sport
//
//  Created by haodong  on 14-4-27.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "UserCell.h"
#import "UIImageView+WebCache.h"
#import "User.h"
#import <CoreLocation/CoreLocation.h>
#import "UserManager.h"

@interface UserCell()
@end

@implementation UserCell


+ (NSString*)getCellIdentifier
{
    return @"UserCell";
}

+ (id)createCell
{
    UserCell *cell = [super createCell];
    UIImageView *bv = [[UIImageView alloc] initWithImage:[SportImage businessCellBackgroundImage]] ;
    [cell setBackgroundView:bv];
    cell.avatarImageView.layer.cornerRadius = 2.5;
    cell.avatarImageView.layer.masksToBounds = YES;
    return cell;
}

+ (CGFloat)getCellHeight
{
    return 82.0;
}

- (void)updateCellWithUser:(User *)user
{
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        self.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:user.avatarUrl] placeholderImage:[SportImage avatarDefaultImageWithGender:user.gender]];
    self.nickNameLabel.text = user.nickname;
    
    self.likeSportLabel.text = user.likeSport;
    
    self.sportPlanLabel.text = user.sportPlan;
    
    if ([user.gender isEqualToString:GENDER_MALE]) {
        self.genderBackgroundImageView.image = [SportImage maleBackgroundImage];
    } else {
        self.genderBackgroundImageView.image = [SportImage femaleBackgroundImage];
    }
    
    self.ageLabel.text = [@(user.age) stringValue];
    
    CLLocation *meLocation = [[UserManager defaultManager] readUserLocation];
    CLLocationDistance distance = 0;
    if (meLocation != nil) {
        CLLocation *userLocation = [[CLLocation alloc] initWithLatitude:user.latitude longitude:user.longitude];
        distance = [meLocation distanceFromLocation:userLocation];
    }
    
    if (meLocation == nil || distance == 0) {
        self.distanceLabel.text = @"未知距离";
    } else {
        if (distance >= 1000.0) {
            self.distanceLabel.text = [NSString stringWithFormat:@"%.2fkm", distance/1000.0];
        } else {
            if (distance < 100.0) {
                self.distanceLabel.text = @"<100m";
            } else {
                self.distanceLabel.text = [NSString stringWithFormat:@"%d0m", (int)distance/10];
            }
        }
    }
}


@end
