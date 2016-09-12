//
//  ActivityCell.m
//  Sport
//
//  Created by haodong  on 14-2-18.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "ActivityCell.h"
#import "UIImageView+WebCache.h"
#import "User.h"
#import <QuartzCore/QuartzCore.h>

@interface ActivityCell()
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) NSDateFormatter *formatter;
@end

@implementation ActivityCell

+ (NSString*)getCellIdentifier
{
    return @"ActivityCell";
}

+ (CGFloat)getCellHeight
{
    return 125;
}

+ (id)createCell
{
    ActivityCell *cell = [super createCell];
    [cell.backgroundButton setBackgroundImage:[SportImage orderBackgroundBottom2Image] forState:UIControlStateNormal];
    cell.avatarImageView.layer.cornerRadius = 2.5;
    cell.avatarImageView.layer.masksToBounds = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)updateCell:(NSIndexPath *)indexPath activity:(Activity *)activity
{
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        self.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
    
    self.indexPath = indexPath;
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:activity.createUserAvatarUrl]  placeholderImage:[SportImage avatarDefaultImageWithGender:activity.createUserGender]];
    
    self.nickNameLabel.text = activity.createUserNickName;
    if ([activity.createUserGender isEqualToString:GENDER_MALE]) {
        self.genderImageView.image = [SportImage maleBackgroundImage];
    } else {
        self.genderImageView.image = [SportImage femaleBackgroundImage];
    }
    self.ageLabel.text = [NSString stringWithFormat:@"%d", activity.createUserAge];
    
    self.themeLabel.text = [Activity themeName:activity.theme];
    self.addressLabel.text = activity.address;
    self.categoryNameLabel.text = activity.proName;
    
    if (_formatter == nil) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        self.formatter = dateFormatter;
    }
    NSString *dateString = [_formatter stringFromDate:activity.startTime];
    self.timeLabel.text = dateString;
    
    self.peopleNumberLabel.text = [NSString stringWithFormat:@"%d", (int)activity.peopleNumber];
    
    self.activityStatusLabel.text = [activity statusString];
    self.activityStatusLabel.textColor = [SportColor activityStatusColor:activity.stauts];
}

- (IBAction)clickButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickActivityCell:)]) {
        [_delegate didClickActivityCell:_indexPath];
    }
}

- (IBAction)clickAvatarButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickActivityCellAvatarButton:)]) {
        [_delegate didClickActivityCellAvatarButton:_indexPath];
    }
}

@end
