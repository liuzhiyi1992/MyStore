//
//  MyPromiseActivityCell.h
//  Sport
//
//  Created by haodong  on 14-5-1.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@protocol MyPromiseActivityCellDelegate <NSObject>
@optional
- (void)didClickMyPromiseActivityCellCancelButton:(NSIndexPath *)indexPath;
- (void)didClickMyPromiseActivityCellEnterRoomChatButton:(NSIndexPath *)indexPath;
- (void)didClickMyPromiseActivityCellDetailButton:(NSIndexPath *)indexPath;
- (void)didClickMyPromiseActivityCellAvatarButton:(NSIndexPath *)indexPath;

@end


@class Activity;

@interface MyPromiseActivityCell : DDTableViewCell

@property (weak, nonatomic) IBOutlet UIButton *createUserAvatarButton;
@property (weak, nonatomic) IBOutlet UILabel *createUserNickNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *createUserGenderBackgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *createUserAgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *createUserAppointmentRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *createUserAcvitityCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UILabel *categroyLabel;
@property (weak, nonatomic) IBOutlet UILabel *createTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *promiseCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityPeopleCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *agreeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *needCountLabel;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *enterRoomChatButton;
@property (weak, nonatomic) IBOutlet UIButton *detailButton;

@property (assign, nonatomic) id<MyPromiseActivityCellDelegate> delegate;

- (void)updateCellWithActivity:(Activity *)actvity indexPath:(NSIndexPath *)indexPath;

@end
