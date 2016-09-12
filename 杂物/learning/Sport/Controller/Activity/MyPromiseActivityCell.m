//
//  MyPromiseActivityCell.m
//  Sport
//
//  Created by haodong  on 14-5-1.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "MyPromiseActivityCell.h"
#import "Activity.h"
#import "UIButton+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "User.h"
#import "UserManager.h"

@interface MyPromiseActivityCell()
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) Activity *activity;
@property (strong, nonatomic) ActivityPromise *myPromise;
@end


@implementation MyPromiseActivityCell
+ (NSString*)getCellIdentifier
{
    return @"MyPromiseActivityCell";
}

+ (CGFloat)getCellHeight
{
    return 367;
}

#define TAG_TOP_IMAGE_VIEW      89
#define TAG_BOTTON_IMAGE_VIEW   90

+ (id)createCell
{
    MyPromiseActivityCell *cell = [super createCell];
    
    
    cell.createUserAvatarButton.layer.cornerRadius = 2.5;
    cell.createUserAvatarButton.layer.masksToBounds = YES;
    
    [cell.cancelButton setBackgroundImage:[SportImage blueButtonImage] forState:UIControlStateNormal];
    [cell.enterRoomChatButton setBackgroundImage:[SportImage greenButtonImage] forState:UIControlStateNormal];
    [cell.detailButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateNormal];
    
    for (UIView *subView in cell.contentView.subviews) {
        if ([subView isKindOfClass:[UIImageView class]]) {
            UIImageView *iv= nil;
            if (subView.tag == TAG_TOP_IMAGE_VIEW) {
                iv = (UIImageView *)subView;
                [iv setImage:[SportImage orderBackgroundTopImage]];
            }
            if (subView.tag == TAG_BOTTON_IMAGE_VIEW) {
                iv = (UIImageView *)subView;
                [iv setImage:[SportImage orderBackgroundBottom2Image]];
            }
        }
    }
    
    return cell;
}

#define TAG_STATUS_IMAGE_VIEW_START  20
- (void)toPointIndex:(int)index
{
    for (int i = 0 ; i <  3; i ++) {
        UIImageView *iv = (UIImageView *)[self.contentView viewWithTag:TAG_STATUS_IMAGE_VIEW_START + i];
        if (i <= index) {
            [iv setImage:[SportImage activityStatusDot2Image]];
        } else {
            [iv setImage:[SportImage activityStatusDot1Image]];
        }
    }
}

- (void)updateStatus
{
    if (_myPromise.status == ActivityPromiseStatusAgreed) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *todayString = [formatter stringFromDate:[NSDate date]];
        NSString *statrString = [formatter stringFromDate:_activity.startTime];
        if ([todayString isEqualToString:statrString]) {
            [self toPointIndex:2];
        } else {
            [self toPointIndex:1];
        }
    } else {
        [self toPointIndex:0];
    }
}

- (void)findMyPromise
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    for (ActivityPromise *promise in _activity.promiseList) {
        if ([user.userId isEqualToString:promise.promiseUserId]) {
            self.myPromise = promise;
            break;
        }
    }
}

- (void)updateCellWithActivity:(Activity *)activity indexPath:(NSIndexPath *)indexPath
{
    self.indexPath = indexPath;
    self.activity = activity;
    [self findMyPromise];
    
    [self.createUserAvatarButton sd_setBackgroundImageWithURL:[NSURL URLWithString:activity.createUserAvatarUrl] forState:UIControlStateNormal placeholderImage:[SportImage avatarDefaultImage]];
    self.createUserNickNameLabel.text = activity.createUserNickName;
    
    if ([activity.createUserGender isEqualToString:GENDER_MALE]) {
        [self.createUserGenderBackgroundImageView setImage:[SportImage maleBackgroundImage]];
    } else {
        [self.createUserGenderBackgroundImageView setImage:[SportImage femaleBackgroundImage]];
    }
    
    self.createUserAgeLabel.text = [NSString stringWithFormat:@"%d", activity.createUserAge];
    self.createUserAppointmentRateLabel.text = activity.createUserAppointmentRate;
    self.createUserAcvitityCountLabel.text = [NSString stringWithFormat:@"%d", activity.createUserActivityCount];
    
    //update status
    [self updateStatus];
    
    self.categroyLabel.text = activity.proName;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    self.createTimeLabel.text =[NSString stringWithFormat:@"发布于%@", [formatter stringFromDate:activity.createTime]];
    
    self.startTimeLabel.text = [formatter stringFromDate:activity.startTime];
    self.addressLabel.text = activity.address;
    
    if (activity.promiseEndTime == nil) {
        self.endTimeLabel.text = @"";
    } else {
        self.endTimeLabel.text = [NSString stringWithFormat:@"截止时间 %@", [formatter stringFromDate:activity.promiseEndTime]];
    }
    
    self.promiseCountLabel.text = [NSString stringWithFormat:@"%@人应约", [@([activity.promiseList count]) stringValue]];
    
    NSUInteger activityPeopleCount = activity.peopleNumber;
    NSUInteger agreeCount = [activity agreePromiseCount];
    self.activityPeopleCountLabel.text = [NSString stringWithFormat:@"需要%@人", [@(activityPeopleCount) stringValue]];
    self.agreeCountLabel.text = [NSString stringWithFormat:@"已选%@人", [@(agreeCount) stringValue]];
    self.needCountLabel.text = [NSString stringWithFormat:@"还需%@人", [@(activityPeopleCount - agreeCount) stringValue]];
}

- (IBAction)clickCancelButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickMyPromiseActivityCellCancelButton:)]) {
        [_delegate didClickMyPromiseActivityCellCancelButton:_indexPath];
    }
}

- (IBAction)clickEnterRoomChatButton:(id)sender {
//    if ([_delegate respondsToSelector:@selector(didClickMyPromiseActivityCellEnterRoomChatButton:)]) {
//        [_delegate didClickMyPromiseActivityCellEnterRoomChatButton:_indexPath];
//    }
}

- (IBAction)clickAvatarButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickMyPromiseActivityCellAvatarButton:)]) {
        [_delegate didClickMyPromiseActivityCellAvatarButton:_indexPath];
    }
}

- (IBAction)clickDetailButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickMyPromiseActivityCellDetailButton:)]) {
        [_delegate didClickMyPromiseActivityCellDetailButton:_indexPath];
    }
}

@end
