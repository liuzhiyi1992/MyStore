//
//  MainHomeSignInView.m
//  Sport
//
//  Created by lzy on 16/6/20.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "MainHomeSignInView.h"
#import "SignInWeeklyModel.h"
#import "SignIn.h"
#import "SportSignInController.h"
#import "SportRecordsViewController.h"
#import "UserManager.h"
#import "LoginController.h"
#import "UIView+Utils.h"

int const TAG_SIGN_IN_SPOT_BASIC = 11;
int const TAG_SIGN_IN_NAME_LABEL_BASIC = 21;
NSString * const NOTIFICATION_NAME_DID_UPDATE_SIGN_IN_DATA = @"NOTIFICATION_NAME_DID_UPDATE_SIGN_IN_DATA";

@interface MainHomeSignInView ()
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *weeklySignRecordsSpots;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weeklyRecordViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signInButtonWidthConstraint;

@property (weak, nonatomic) IBOutlet UIView *defaultSignInStatusView;
@property (weak, nonatomic) IBOutlet UIView *signInRecordView;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UILabel *signInTipsLabel;
@end

@implementation MainHomeSignInView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupView];
        [self registerNotification];
    }
    return self;
}

- (void)dealloc {
    [self resignNotification];
}

- (void)setupView {
    [[NSBundle mainBundle] loadNibNamed:@"MainHomeSignInView" owner:self options:nil];
    [self addSubview:self.view];
    [self configureView];
    [self loginConfigure];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.view.frame = self.bounds;
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginConfigure) name:NOTIFICATION_NAME_DID_LOG_OUT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginConfigure) name:NOTIFICATION_NAME_DID_LOG_IN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateSignInData:) name:NOTIFICATION_NAME_DID_UPDATE_SIGN_IN_DATA object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSignInSucceed) name:NOTIFICATION_NAME_SIGN_IN_SUCCEED object:nil];
    
}

- (void)resignNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loginConfigure {
    if (![UserManager isLogin]) {
        //没登陆
        _signInRecordView.hidden = YES;
        _defaultSignInStatusView.hidden = NO;
    } else {
        //已登陆
        _signInRecordView.hidden = NO;
        _defaultSignInStatusView.hidden = YES;
    }
}

- (void)didUpdateSignInData:(NSNotification *)notify {
    SignIn *signIn = [notify.userInfo valueForKey:PARA_SIGN_IN];
    self.signIn = signIn;
}

- (void)didSignInSucceed {
    self.signIn.daySignInStatus = 1;
    self.signIn.versionSignInStatus = 1;
    self.signIn = self.signIn;
}

- (void)configureView {
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat leadingRatio = 1;
    CGFloat buttonRatio = 1;
    if (screenHeight == 480) {//i4
        leadingRatio = 0.7f;
        buttonRatio = 0.9;
    } else if (screenHeight == 568) {//i5
        leadingRatio = 0.7f;
        buttonRatio = 0.9;
    } else if (screenHeight == 667){//6
        leadingRatio = 0.9f;
    }
    _weeklyRecordViewLeadingConstraint.constant = leadingRatio * _weeklyRecordViewLeadingConstraint.constant;
    _signInButtonWidthConstraint.constant = buttonRatio * _signInButtonWidthConstraint.constant;
    
    for (UIView *spot in _weeklySignRecordsSpots) {
        spot.layer.cornerRadius = spot.frame.size.height/2;
        spot.layer.borderWidth = 1.f;
        spot.layer.borderColor = [UIColor hexColor:@"797e89"].CGColor;
    }
}

- (void)setSignIn:(SignIn *)signIn {
    _signIn = signIn;
    
    //历史打卡状态
    if(_signIn.versionSignInStatus == 0) {
        _signInRecordView.hidden = YES;
        _defaultSignInStatusView.hidden = NO;
    } else {
        _signInRecordView.hidden = NO;
        _defaultSignInStatusView.hidden = YES;
    }
    
    //当天打卡状态
    if (_signIn.daySignInStatus == 1) {
        [_signInButton setBackgroundImage:[UIImage imageNamed:@"sign_in_fingerprint_dark"] forState:UIControlStateNormal];
        [_signInTipsLabel setTextColor:[UIColor hexColor:@"aaaaaa"]];
    } else {
        [_signInButton setBackgroundImage:[UIImage imageNamed:@"sign_in_fingerprint"] forState:UIControlStateNormal];
        [_signInTipsLabel setTextColor:[UIColor hexColor:@"5B73F2"]];
    }
    
    
    for (int i = 0; i < signIn.fourWeekSignInList.count; i++) {
        SignInWeeklyModel *weekly = signIn.fourWeekSignInList[i];
        UIView *weeklySpotView = [self viewWithTag:TAG_SIGN_IN_SPOT_BASIC + i];
        UILabel *nameLabel = [self viewWithTag:TAG_SIGN_IN_NAME_LABEL_BASIC + i];
        //records
        if (weekly.weekSignInTimes > 0) {
            [self lightenWeekSpot:weeklySpotView nameLabel:nameLabel];
        } else {
            [self dimWeekSpot:weeklySpotView nameLabel:nameLabel];
        }
        //week name
        if (weekly.weekName.length > 0) {
            if ([nameLabel isKindOfClass:[UILabel class]]) {
                NSString *timesString = (weekly.weekSignInTimes > 0) ? [NSString stringWithFormat:@"%d次", weekly.weekSignInTimes] : @"";
                NSString *weekNameString = [NSString stringWithFormat:@"%@%@", weekly.weekName, timesString];
                nameLabel.text = weekNameString;
            }
        }
    }
}

- (void)lightenWeekSpot:(UIView *)spotView nameLabel:(UILabel *)nameLabel {
    spotView.layer.borderWidth = 0;
    spotView.backgroundColor = [UIColor hexColor:@"5b73f2"];
    nameLabel.textColor = [UIColor hexColor:@"5b73f2"];
}

- (void)dimWeekSpot:(UIView *)spotView nameLabel:(UILabel *)nameLabel {
    spotView.backgroundColor = [UIColor whiteColor];
    spotView.layer.borderWidth = 1.f;
    spotView.layer.borderColor = [UIColor hexColor:@"797e89"].CGColor;
    nameLabel.textColor = [UIColor hexColor:@"666666"];
}

- (IBAction)clickSignInButton:(id)sender {
    [MobClickUtils event:umeng_event_click_sign_in_button label:@"打卡"];
    UIViewController *responderController = nil;
    [self findControllerWithResultController:&responderController];
    if (nil == responderController) {
        return;
    }
    if (![UserManager isLogin]) {
        LoginController *loginController = [[LoginController alloc] init];
        [responderController.navigationController pushViewController:loginController animated:YES];
    }  else if (_signIn.daySignInStatus == 1) {
        //今天已打卡
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"今天您已经打过卡了，下次运动再来吧" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alert show];
    } else if (_signIn.daySignInStatus == 0) {
        SportSignInController *signInController = [[SportSignInController alloc] init];
        [responderController.navigationController pushViewController:signInController animated:YES];
    }
}

- (IBAction)clickBackgroundButton:(id)sender {
    UIViewController *responderController = nil;
    [self findControllerWithResultController:&responderController];
    if (nil == responderController) {
        return;
    }
    if ([UserManager isLogin] && _signIn.versionSignInStatus == 1) {
        [MobClickUtils event:umeng_event_sign_in_record_source label:@"来自首页"];
        SportRecordsViewController *recordsController = [[SportRecordsViewController alloc] init];
        [responderController.navigationController pushViewController:recordsController animated:YES];
    }
}


@end
