//
//  SponsorCourtJoinView.m
//  Sport
//
//  Created by lzy on 16/6/7.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "SponsorCourtJoinView.h"
#import "SponsorCourtJoinEditingView.h"
#import "Order.h"
#import "ShareView.h"
#import "SportNetworkContent.h"
#import "UIView+Utils.h"
#import "UIImage+Extension.h"
#import "BaseConfigManager.h"
#import "SportWebController.h"
#import "UIView+Utils.h"

NSString * const NOTIFICATION_NAME_POP_SHARE_VIEW = @"NOTIFICATION_NAME_POP_SHARE_VIEW";
NSString * const NOTIFICATION_NAME_DID_CLICK_CJ_REGULATION_BUTTON = @"NOTIFICATION_NAME_DID_CLICK_CJ_REGULATION_BUTTON";
#define VIEW_RATIO_SPONSOR_TYPE_PAY_SUCCEED 1.65f
#define VIEW_RATIO_SPONSOR_TYPE_ORDER_DETAIL 2.31f

@interface SponsorCourtJoinView ()
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *regulationButton;
@property (strong, nonatomic) SponsorCourtJoinEditingView *sponsorCourtJoinEditingView;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *adaptiveConstraint;
@property (assign, nonatomic) SponsorType sponsorType;
@property (assign, nonatomic) CGFloat viewRatio;//控件宽高比
@end

@implementation SponsorCourtJoinView
+ (SponsorCourtJoinView *)createViewWithOrder:(Order *)order sponsorType:(SponsorType)sponsorType {
    SponsorCourtJoinView *view = [[NSBundle mainBundle] loadNibNamed:@"SponsorCourtJoinView" owner:nil options:nil][0];
    view.order = order;
    view.sponsorType = sponsorType;
    [view registerNotification];
    [view configureView];
    return view;
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sponsorCourtJoinSucceed:) name:NOTIFICATION_NAME_COURT_JOIN_SUCCESS object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configureView {
    UIImage *backgroundImage;
    NSString *actionButtonTitle = @"我先试试";
    NSString *subTitleText = @"切磋球技 共担场费";
    BOOL isDisplayRegulation = NO;
    if (_sponsorType == SponsorTypePaySucceed) {
        backgroundImage = [UIImage imageNamed:@"court_join_sponsor_background_pay_succeed"];
        actionButtonTitle = @"我先试试";
        subTitleText = @"切磋球技 共担场费";
        isDisplayRegulation = YES;
        self.viewRatio = VIEW_RATIO_SPONSOR_TYPE_PAY_SUCCEED;
    } else if (_sponsorType == SponsorTypeOrderDetail) {
        backgroundImage = [UIImage imageNamed:@"court_join_sponsor_background_order_detail"];
        actionButtonTitle = @"我来试试";
        subTitleText = @"切磋球技 共担场地费";
        isDisplayRegulation = YES;
        self.viewRatio = VIEW_RATIO_SPONSOR_TYPE_ORDER_DETAIL;
        //constant
        for (NSLayoutConstraint *constraint in _adaptiveConstraint) {
            constraint.constant = 0.5 * constraint.constant;
        }
    }
    _regulationButton.hidden = !isDisplayRegulation;
    [_backgroundImageView setImage:backgroundImage];
    [_actionButton setTitle:actionButtonTitle forState:UIControlStateNormal];
    _subTitleLabel.text = subTitleText;
    
    [_actionButton setBackgroundImage:[SportColor createImageWithColor:[UIColor hexColor:@"22874e"]] forState:UIControlStateHighlighted];
    [self adaptiveSize];
}

- (void)adaptiveSize {
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat mariginRatio = 1;
    if (screenHeight == 480) {//i4
        mariginRatio = 0.6;
    } else if (screenHeight == 568) {//i5
        mariginRatio = 0.7;
    }
    for (NSLayoutConstraint *constraint in _adaptiveConstraint) {
        constraint.constant = mariginRatio * constraint.constant;
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    [self updateWidth:[UIScreen mainScreen].bounds.size.width];
    [self updateHeight:screenSize.width / _viewRatio];
    CGFloat courtJoinViewOriginY = screenSize.height - self.bounds.size.height;
    [self updateOriginY:courtJoinViewOriginY];
}

- (void)sponsorCourtJoinSucceed:(NSNotification *)notify {
    //success
    [_titleImageView setImage:[UIImage imageNamed:@"court_join_exist"]];
    _subTitleLabel.text = @"在订单详情页可查看更多消息";
    //change action
    [_actionButton setTitle:@"立即分享" forState:UIControlStateNormal];
    [_actionButton removeTarget:self action:@selector(clickSponsorCourtJoinButton:) forControlEvents:UIControlEventTouchUpInside];
    [_actionButton addTarget:self action:@selector(clickShareButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)clickSponsorCourtJoinButton:(id)sender {
    [MobClickUtils event:umeng_event_welcome_court_join_button];
    [SponsorCourtJoinEditingView showWithOrder:_order];
}

- (IBAction)clickRegulationButton:(id)sender {
    UIViewController *sponsorController;
    [self findControllerWithResultController:&sponsorController];
    if (sponsorController) {
        SportWebController *constroller = [[SportWebController alloc] initWithUrlString:[[BaseConfigManager defaultManager] courtJoinInstructionUrl] title:@"什么是球局"];
        [sponsorController.navigationController pushViewController:constroller animated:YES];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_DID_CLICK_CJ_REGULATION_BUTTON object:nil];
}

- (void)clickShareButton:(UIButton *)sender {
    //share
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_POP_SHARE_VIEW object:nil];
}
@end
