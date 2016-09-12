//
//  OrderDetailCourtJoinParticipatorView.m
//  Sport
//
//  Created by lzy on 16/6/17.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "OrderDetailCourtJoinParticipatorView.h"
#import "CourtJoinUser.h"
#import "UIImageView+WebCache.h"
#import "UIUtils.h"
#import "SportPopupView.h"
#import "ConversationViewController.h"
#import "UserInfoController.h"
#import "EditUserInfoController.h"
#import "UserManager.h"
#import "UIView+Utils.h"

@interface OrderDetailCourtJoinParticipatorView()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (copy, nonatomic) NSString *phoneNum;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *contactButtons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelLeadingConstraint;


@property (strong, nonatomic) CourtJoinUser *courtUser;
@property (weak, nonatomic) IBOutlet UIButton *avatarButton;

@end

@implementation OrderDetailCourtJoinParticipatorView
+ (OrderDetailCourtJoinParticipatorView *)createViewWithCourtJoinUser:(CourtJoinUser *)courtJoinUser {
    OrderDetailCourtJoinParticipatorView *view = [[NSBundle mainBundle] loadNibNamed:@"OrderDetailCourtJoinParticipatorView" owner:self options:nil][0];
    [view configureViewWithUser:courtJoinUser];

    return view;
}

- (void)configureViewWithUser:(CourtJoinUser *)courtJoinUser {
    self.courtUser = courtJoinUser;
    
    //fit scale
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    if (screenHeight <= 568) {
        _nameLabelLeadingConstraint.constant = 10;
    }
    
    for (UIButton *btn in _contactButtons) {
        btn.layer.cornerRadius = btn.bounds.size.height/2;
        btn.layer.borderColor = [UIColor hexColor:@"4f6dcf"].CGColor;
        btn.layer.borderWidth = 1.f;
    }
    
    //nameLabel
    NSString *userName = courtJoinUser.userName;
    if (userName == nil) {
        userName = @"";
    }else if (userName.length > 3) {
        NSString *front = [userName substringToIndex:1];
        NSString *later = [userName substringFromIndex:userName.length - 1];
        userName = [NSString stringWithFormat:@"%@**%@", front, later];
    }
    NSString *statusString = @"";
    if (courtJoinUser.orderStatus == 0) {
        statusString = @"待支付";
    } else if (courtJoinUser.orderStatus == 1) {
        statusString = @"加入成功";
    }
    NSMutableString *nameString = [NSMutableString string];
    [nameString appendString:@"["];
    [nameString appendString:userName];
    [nameString appendString:@"] "];
    [nameString appendString:statusString];
    self.nameLabel.text = nameString;
    
    //avatar
    if (courtJoinUser.avatarUrl.length > 0) {
        NSURL *avatarUrl = [NSURL URLWithString:courtJoinUser.avatarUrl];
        [_avatarImageView sd_setImageWithURL:avatarUrl placeholderImage:[UIImage imageNamed:@"defaultAvatar"]];
    } else {
        [_avatarImageView setImage:[SportImage avatarDefaultImage]];
    }

    self.phoneNum = courtJoinUser.phoneNumber;
}

- (IBAction)clickCallingButton:(id)sender {
    BOOL result = [UIUtils makePromptCall:self.phoneNum];
    [MobClickUtils event:umeng_event_court_join_sponsor_order_phone];
    if (result == NO) {
        [SportPopupView popupWithMessage:@"此设备不支持打电话"];
    }
}

- (IBAction)clickSendMessageButton:(id)sender {
    
    
    [MobClickUtils event:umeng_event_court_join_sponsor_order_im];
    UIViewController *controller = nil;
    [self findControllerWithResultController:&controller];
    if (controller) {
        ConversationViewController *conversationVC = [[ConversationViewController alloc]init];
        conversationVC.conversationType = ConversationType_PRIVATE;
        conversationVC.targetId = self.courtUser.userId;
        conversationVC.title = self.courtUser.userName;
        
        [controller.navigationController pushViewController:conversationVC animated:YES];
    }
}

- (IBAction)clickAvatarButton:(id)sender {
    if ([self.courtUser.userId length] == 0) {
        return;
    }
    UIViewController *sponsorController = nil;
    [self findControllerWithResultController:&sponsorController];
    if (sponsorController) {
        UIViewController *pController;
        User *me = [[UserManager defaultManager] readCurrentUser];
        if ([self.courtUser.userId isEqualToString:me.userId]) {
            pController = [[EditUserInfoController alloc] initWithUser:me levelTitle:me.rulesTitle];
        } else {
            pController = [[UserInfoController alloc] initWithUserId:self.courtUser.userId];
        }
        
        [sponsorController.navigationController pushViewController:pController animated:YES];
    }
}
@end
