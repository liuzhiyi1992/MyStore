//
//  SignInSuccessView.m
//  Sport
//
//  Created by lzy on 16/6/12.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "SignInSuccessView.h"
#import "UIView+Utils.h"
#import "NSDictionary+JsonValidValue.h"
#import "SportNetworkContent.h"

NSString * const NOTIFICATION_NAME_SIGN_IN_POP_SHARE_VIEW = @"NOTIFICATION_NAME_SIGN_IN_POP_SHARE_VIEW";

@interface SignInSuccessView()
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *rewardLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIButton *sportRecordsButton;

@end

@implementation SignInSuccessView

+ (SignInSuccessView *)createViewWithDataDict:(NSDictionary *)dataDict delegate:(id<SignInSuccessViewDelegate>)delegate {
    SignInSuccessView *view = [[NSBundle mainBundle] loadNibNamed:@"SignInSuccessView" owner:nil options:nil][0];
    view.mydelegate = delegate;
    [view configureViewWithDict:dataDict];
    return view;
}

- (void)configureViewWithDict:(NSDictionary *)dict {
    [MobClickUtils event:umeng_event_show_sign_in_succeed label:@"打卡成功页"];
    NSString *signInTime = [dict validStringValueForKey:PARA_SIGN_IN_TIME];
    NSString *venuesName = [dict validStringValueForKey:PARA_VENUES_NAME];
    NSString *integralTips = [dict validStringValueForKey:PARA_INTEGRAL_TIPS];
    NSString *weekTips = [dict validStringValueForKey:PARA_WEEK_TIPS];
    
    _subTitleLabel.text = [NSString stringWithFormat:@"%@ %@", signInTime, venuesName];
    _rewardLabel.text = integralTips;
    _tipsLabel.text = weekTips;

    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat marginRatio = 1;
    if (screenHeight <= 568) {//i4, i5
        marginRatio = 0.7f;
    }
    _mainImageViewTopConstraint.constant = marginRatio * _mainImageViewTopConstraint.constant;
}

- (IBAction)clickShareButton:(id)sender {
    //todo shareContent考虑要不要在这里传
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_SIGN_IN_POP_SHARE_VIEW object:nil];
}

- (IBAction)clickSportRecordsButton:(id)sender {
    if ([_mydelegate respondsToSelector:@selector(signInSuccessViewWillPushRecordsViewController)]) {
        [MobClickUtils event:umeng_event_sign_in_record_source label:@"来自打卡成功页"];
        [_mydelegate signInSuccessViewWillPushRecordsViewController];
    }
}


@end
