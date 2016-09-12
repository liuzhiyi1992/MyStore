//
//  ActivityDetailController.m
//  Sport
//
//  Created by haodong  on 14-2-20.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "ActivityDetailController.h"
#import "UIButton+WebCache.h"
#import "Activity.h"
#import "UserManager.h"
#import "UIView+Utils.h"
#import <QuartzCore/QuartzCore.h>
#import "ActivityPromise.h"
#import "SportProgressView.h"
#import "LoginController.h"
#import "UserInfoController.h"
#import "SportPopupView.h"
#import "ManageActivityController.h"
#import "NSString+Utils.h"

@interface ActivityDetailController ()
@property (copy, nonatomic) NSString *activityId;
@property (strong, nonatomic) Activity *activity;
@end

@implementation ActivityDetailController

- (void)viewDidUnload {
    [self setCreateUserAvatarButton:nil];
    [self setCreateUserGenderBackgroundImageView:nil];
    [self setCreateUserNicknameLabel:nil];
    [self setCreateUserAppointmentRate:nil];
    [self setCreateUserActivityCountLabel:nil];
    [self setCreateUserAgeLabel:nil];
    [self setCategoryLabel:nil];
    [self setAddressLabel:nil];
    [self setThemeLabel:nil];
    [self setTimeLabel:nil];
    [self setCostLabel:nil];
    [self setLemonLabel:nil];
    [self setDescLabel:nil];
    [self setRequireGenderLabel:nil];
    [self setRequireAgeLabel:nil];
    [self setRequireSportLevelLabel:nil];
    [self setDescHoderView:nil];
    [self setRequireHolderView:nil];
    [self setPromiseUserHoderView:nil];
    [self setBackgroundImageView1:nil];
    [self setBackgroundImageView2:nil];
    [self setBackgroundImageView3:nil];
    [self setBackgroundImageView4:nil];
    [self setBackgroundImageView5:nil];
    [self setMainScrollView:nil];
    [self setPageBackgroundImageView:nil];
    [self setActivityStatusLabel:nil];
    [self setRequireSportLevelImageView:nil];
    [super viewDidUnload];
}

- (id)initWithActivityId:(NSString *)activityId
{
    self = [super init];
    if (self) {
        self.activityId = activityId;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"活动详情";
    
    //[self.pageBackgroundImageView setImage:[SportImage pageBackgroundImage]];
    
    [self.backgroundImageView1 setImage:[SportImage orderBackgroundTopImage]];
    [self.backgroundImageView2 setImage:[SportImage orderBackgroundTopImage]];
    [self.backgroundImageView3 setImage:[SportImage orderBackgroundBottomImage]];
    [self.backgroundImageView4 setImage:[SportImage orderBackgroundTopImage]];
    [self.backgroundImageView5 setImage:[SportImage orderBackgroundBottom2Image]];
    [self.mainScrollView updateHeight:[UIScreen mainScreen].bounds.size.height - 64];
    [self.mainScrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 580)];
    
    self.createUserAvatarButton.layer.cornerRadius = 2.5;
    self.createUserAvatarButton.layer.masksToBounds = YES;
    
    [self updateUI];
    
    [SportProgressView showWithStatus:@"正在加载..."];
    [self queryData];
    
    [MobClickUtils event:umeng_event_enter_activity_detail];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)queryData
{
    [ActivityService queryActivityDetail:self activityId:_activityId];
}

//TEST DATA测试数据
//- (void)addPromiseTestData
//{
//    NSMutableArray *mu = [NSMutableArray array];
//    for (int i = 0; i < 10; i ++) {
//        ActivityPromise *promise = [[[ActivityPromise alloc] init] autorelease];
//        promise.promiseId = [NSString stringWithFormat:@"%d",     1000  + i];
//        promise.promiseUserId = [NSString stringWithFormat:@"%d", 1000 + i];
//        promise.promiseUserAvatar = @"http://img4.duitang.com/uploads/item/201306/19/20130619113256_vRGPj.thumb.600_0.jpeg";
//        promise.promiseUserName = [NSString stringWithFormat:@"%d", 1000  + i];
//        promise.promiseUserGender = (i %2 == 0 ? @"m" : @"f");
//        promise.promiseUserAge = i;
//        promise.promiseUserAppointmentRate = (i %2 == 0 ? @"100%" : @"80%");
//        promise.promiseUserActivityCount = i;
//        
//        promise.lemonType = (i % 3);
//        promise.lemonCount = i + 1;
//        promise.status = (i % 3);
//        
//        [mu addObject:promise];
//    }
//    self.activity.promiseList = mu;
//}

- (void)didQueryActivityDetail:(Activity *)activity status:(NSString *)status
{
    [SportProgressView dismiss];
    //if ([status isEqualToString:STATUS_SUCCESS]) {
    self.activity = activity;
    [self updateUI];
    //}
    
    //无数据时的提示
    if (activity == nil) {
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44);
        if ([status isEqualToString:STATUS_SUCCESS]) {
            [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"没有相关数据"];
        } else {
            [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:@"网络错误"];
        }
    } else {
        [self removeNoDataView];
    }
}

- (void)didClickNoDataViewRefreshButton
{
    [SportProgressView showWithStatus:@"正在加载..."];
    [self queryData];
}

- (BOOL)isMeInPromiseList
{
    User *me = [[UserManager defaultManager] readCurrentUser];
    for (ActivityPromise *promise in _activity.promiseList) {
        if ([promise.promiseUserId isEqualToString:me.userId]) {
            return YES;
        }
    }
    return NO;
}

- (void)updateBottomHolderView
{
    if (_activity == nil) {
        self.bottomHolderView.hidden = YES;
        [self.mainScrollView updateHeight:[UIScreen mainScreen].bounds.size.height - 20 - 44];
    } else {
        self.bottomHolderView.hidden = NO;
        [self.bottomHolderView updateOriginY:[UIScreen mainScreen].bounds.size.height - 20 - 44 - _bottomHolderView.frame.size.height];
        [self.mainScrollView updateHeight:[UIScreen mainScreen].bounds.size.height - 20 - 44 - _bottomHolderView.frame.size.height];
        
        User *user = [[UserManager defaultManager] readCurrentUser];
        if ([_activity.userId isEqualToString:user.userId] == NO) {
            self.promiseButton.hidden = NO;
            
            [self.managerActivityButton updateOriginX:[UIScreen mainScreen].bounds.size.width/2];
            [self.managerActivityButton updateWidth:[UIScreen mainScreen].bounds.size.width/2];
            [self.managerActivityButton setTitle:@"我的活动" forState:UIControlStateNormal];
        } else {
            self.promiseButton.hidden = YES;
            
            [self.managerActivityButton updateOriginX:0];
            [self.managerActivityButton updateWidth:[UIScreen mainScreen].bounds.size.width];
            [self.managerActivityButton setTitle:@"活动管理" forState:UIControlStateNormal];
        }
    }
}

#define TAG_ADDPROMISE_ALERTVIEW 2014051701
- (IBAction)clickPromiseButton:(id)sender {
    [MobClickUtils event:umeng_event_click_promise];
    
    if ([UserManager isLogin]) {
        
        if ( _activity.stauts != 0 ||
            [_activity.startTime compare:[NSDate date]] == NSOrderedAscending) {
            [SportPopupView popupWithMessage:@"活动已过期或失效"];
            return;
        } else {
            
            if ([self isMeInPromiseList]) {
                //[SportPopupView popupWithMessage:@"你已经应约过该活动"];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"你已经参与过该活动了，可以通过\"活动管理->我的参与\"查看参与情况" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
                return;
            }
            
            if (_activity.integralType == 2 && _activity.integralCount > 0) {
                NSString *message = [NSString stringWithFormat:@"参与该活动将花费你%d个柠檬，确定参与吗？", _activity.integralCount];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                alertView.tag = TAG_ADDPROMISE_ALERTVIEW;
                [alertView show];
            } else {
                [self addPromise];
            }
        }
    } else {
        LoginController *controller = [[LoginController alloc] init] ;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (IBAction)clickManagerActivityButton:(id)sender {
    if ([UserManager isLogin]) {
        ManageActivityController *controller = [[ManageActivityController alloc] initWithType:ManageActivityPromise];
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        LoginController *controller = [[LoginController alloc] init] ;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_ADDPROMISE_ALERTVIEW) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            return;
        } else {
            [self addPromise];
        }
    }
}

- (void)addPromise
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    [SportProgressView showWithStatus:@"参与中..."];
    [ActivityService addPromise:self
                     activityId:_activity.activityId
                         userId:user.userId];
}

- (void)didAddPromise:(NSString *)status msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismiss];
        [self queryData];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"已提交参与请求!" message:@"您可以通过\"活动管理->我的参与\"查看情况" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    } else {
        [SportProgressView dismissWithError:msg];
    }
}

- (void)updateUI
{
    [self updateBottomHolderView];
    
    [self.createUserAvatarButton sd_setImageWithURL:[NSURL URLWithString:_activity.createUserAvatarUrl] forState:UIControlStateNormal placeholderImage:[SportImage avatarDefaultImageWithGender:_activity.createUserGender]];
    if ([_activity.createUserGender isEqualToString:GENDER_MALE]) {
        [self.createUserGenderBackgroundImageView setImage:[SportImage maleBackgroundImage]];
    } else {
        [self.createUserGenderBackgroundImageView setImage:[SportImage femaleBackgroundImage]];
    }
    self.createUserAgeLabel.text = [NSString stringWithFormat:@"%d", _activity.createUserAge];
    self.createUserNicknameLabel.text = _activity.createUserNickName;
    self.createUserAppointmentRate.text = _activity.createUserAppointmentRate;
    self.createUserActivityCountLabel.text = [NSString stringWithFormat:@"%d", _activity.createUserActivityCount];
    
    self.activityStatusLabel.text = [_activity statusString];
    self.activityStatusLabel.textColor = [SportColor activityStatusColor:_activity.stauts];
    
    self.categoryLabel.text = _activity.proName;
    self.addressLabel.text = _activity.address;
    self.themeLabel.text = [NSString stringWithFormat:@"%@(需%d人)", [Activity themeName:_activity.theme], (int)_activity.peopleNumber];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    self.timeLabel.text = [dateFormatter stringFromDate:_activity.startTime];
    
    NSString *totalCost = [NSString stringWithFormat:@"共%d元", _activity.totalCost];
    NSString *costType = [Activity costName:_activity.costType];
    self.costLabel.text = [NSString stringWithFormat:@"%@ %@", totalCost, costType];
    
    NSString *lemonType = nil;
    if (_activity.integralType == 1) {
        lemonType = @"赠送";
    } else if (_activity.integralType == 2) {
        lemonType = @"索取";
    } else {
        lemonType = @"";
    }
    self.lemonLabel.text = [NSString stringWithFormat:@"%@%d柠檬/人", lemonType, _activity.integralCount];
    
    if ([_activity.desc length] > 0) {
        self.descLabel.text = _activity.desc;
    } else {
        self.descLabel.text = @"暂无说明";
    }
    
    if ([_activity.requireGender isEqualToString:GENDER_MALE]) {
        self.requireGenderLabel.text = @"男";
    } else if ([_activity.requireGender isEqualToString:GENDER_FEMALE]){
        self.requireGenderLabel.text = @"女";
    } else {
        self.requireGenderLabel.text = @"不限";
    }
    
    if ( _activity.requireMinAge <= 0 || _activity.requireMinAge > _activity.requireMaxAge ) {
        self.requireAgeLabel.text = @"不限";
    } else {
        self.requireAgeLabel.text = [NSString stringWithFormat:@"%d-%d", (int)_activity.requireMinAge, (int)_activity.requireMaxAge];
    }
    
    if (_activity.requireSportLevel == SportLevelUnknow) {
        [self.requireSportLevelLabel updateOriginX:264 - 16];
    } else {
        [self.requireSportLevelLabel updateOriginX:264];
    }
    self.requireSportLevelLabel.text = [Activity sportLevelName:_activity.requireSportLevel];
    self.requireSportLevelLabel.textColor = [SportColor sportLevelColor:_activity.requireSportLevel];
    self.requireSportLevelImageView.image = [SportImage sportLevelImage:_activity.requireSportLevel];
    
    //调整位置
    CGSize nickNameSize = [self.createUserNicknameLabel.text sizeWithMyFont:_createUserNicknameLabel.font];
    CGFloat gx = _createUserNicknameLabel.frame.origin.x + nickNameSize.width + 20;
    gx = (gx > 200 ? 200 : gx);
    [self.createUserGenderBackgroundImageView updateOriginX:gx];
    [self.createUserAgeLabel updateOriginX:_createUserGenderBackgroundImageView.frame.origin.x + 14];
    
    CGSize descSize = [self.descLabel.text sizeWithMyFont:self.descLabel.font constrainedToSize:CGSizeMake(229, 100)];
    [self.descLabel updateHeight:descSize.height + 10];
    
    CGFloat descBackgroundHeight = MAX(descSize.height + 20, 40);
    [self.backgroundImageView3 updateHeight:descBackgroundHeight];
    [self.descHoderView updateHeight:descBackgroundHeight];
    
    [self.requireHolderView updateOriginY:_descHoderView.frame.origin.y + _descHoderView.frame.size.height + 10];
    [self.promiseUserHoderView updateOriginY:_requireHolderView.frame.origin.y + _requireHolderView.frame.size.height];
    
    
    //更新报名用户
    NSArray *subViewList = self.promiseUserHoderView.subviews;
    for (UIView *subView in subViewList) {
        if ([subView isKindOfClass:[UIButton class]]) {
            [subView removeFromSuperview];
        }
    }
    
    CGFloat startX = 20, startY = 30;
    CGFloat x, y = startY;
    CGFloat with = 42, height = 42;
    CGFloat space = 6;
    int index = 0;
    for (ActivityPromise *promise in _activity.promiseList) {
        UIButton *button = [[UIButton alloc] init] ;
        button.tag = index;
        [button addTarget:self action:@selector(clickPromiseAvatarButton:) forControlEvents:UIControlEventTouchUpInside];
        
        int lie = index % 6;
        int hang = index / 6;
        x = startX + lie * (with + space);
        y = startY + hang * (height + space);
        [button setFrame:CGRectMake(x, y, with, height)];
        [button sd_setImageWithURL:[NSURL URLWithString:promise.promiseUserAvatar] forState:UIControlStateNormal placeholderImage:[SportImage avatarDefaultImage]];
        
        if (promise.status == ActivityPromiseStatusAgreed) {
            UIImageView *iv = [[UIImageView alloc] initWithImage:[SportImage greenMarkImage]];
            CGRect frame  = CGRectMake(37, -3, 8, 8);
            [iv setFrame:frame];
            [button addSubview:iv];
           // [iv release];
        }
        
        index ++;
        
        [self.promiseUserHoderView addSubview:button];
    }
    
    [self.promiseUserHoderView updateHeight:y + height + 20];
    [self.backgroundImageView5 updateHeight:_promiseUserHoderView.frame.size.height];
    
    CGFloat contentHeight = _promiseUserHoderView.frame.origin.y + _promiseUserHoderView.frame.size.height + 30;
    contentHeight = (contentHeight > _mainScrollView.frame.size.height ? contentHeight : _mainScrollView.frame.size.height + 1);
    [self.mainScrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, contentHeight)];
}

- (IBAction)clickCreateUserAvatarButton:(id)sender {
    UserInfoController *controller = [[UserInfoController alloc] initWithUserId:_activity.userId];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)clickPromiseAvatarButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSUInteger tag = button.tag;
    ActivityPromise *promise = [_activity.promiseList objectAtIndex:tag];

    UserInfoController *controller = [[UserInfoController alloc]  initWithUserId:promise.promiseUserId] ;
    [self.navigationController pushViewController:controller animated:YES];
}

@end


