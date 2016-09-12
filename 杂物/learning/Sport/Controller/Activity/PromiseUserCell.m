//
//  PromiseUserCell.m
//  Sport
//
//  Created by haodong  on 14-5-1.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "PromiseUserCell.h"
#import "ActivityPromise.h"
#import "UIButton+WebCache.h"
#import "User.h"

@interface PromiseUserCell()
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) ActivityPromise *promise;
@end


@implementation PromiseUserCell


+ (NSString*)getCellIdentifier
{
    return @"PromiseUserCell";
}

+ (CGFloat)getCellHeight
{
    return 82;
}

- (void)updateCellWithPromise:(ActivityPromise *)promise
                    indexPath:(NSIndexPath *)indexPath
                       isLast:(BOOL)isLast
{
    self.indexPath = indexPath;
    self.promise = promise;
    if (isLast) {
        [self.backgroundImageView setImage:[SportImage orderBackgroundBottom2Image]];
    } else {
        [self.backgroundImageView setImage:[SportImage orderBackgroundTopImage]];
    }
    
    [self.avatarButton sd_setBackgroundImageWithURL:[NSURL URLWithString:promise.promiseUserAvatar] forState:UIControlStateNormal placeholderImage:[SportImage avatarDefaultImageWithGender:promise.promiseUserGender]];
    
    self.nickNameLabel.text = promise.promiseUserName;
    
    if ([promise.promiseUserGender isEqualToString:GENDER_MALE]) {
        [self.genderBackgroundImageView setImage:[SportImage maleBackgroundImage]];
    } else {
        [self.genderBackgroundImageView setImage:[SportImage femaleBackgroundImage]];
    }
    
    self.ageLabel.text = [NSString stringWithFormat:@"%d", promise.promiseUserAge];
    self.appointmentRateLabel.text = promise.promiseUserAppointmentRate;
    self.activityCountLabel.text = [NSString stringWithFormat:@"%d", promise.promiseUserActivityCount];
    self.lemonCountLabel.text = [NSString stringWithFormat:@"%d", promise.lemonCount];
    
    [self updateActionButton];
}

- (void)updateActionButton
{
    if (_promise.status == ActivityPromiseStatusAgreed) {
        self.actionButton.hidden = YES;
//        [self.actionButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateNormal];
//        [self.actionButton setTitle:@"取消" forState:UIControlStateNormal];
    } else {
        self.actionButton.hidden = NO;
        [self.actionButton setBackgroundImage:[SportImage greenButtonImage] forState:UIControlStateNormal];
        [self.actionButton setTitle:@"同意" forState:UIControlStateNormal];
    }
}

- (IBAction)clickActionButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickPromiseUserCellButton:)]) {
        [_delegate didClickPromiseUserCellButton:_indexPath];
    }
}

- (IBAction)clickAvatarButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickPromiseUserCellAvatarButton:)]) {
        [_delegate didClickPromiseUserCellAvatarButton:_indexPath];
    }
}

@end
