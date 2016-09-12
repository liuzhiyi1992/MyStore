//
//  MembershipCardDetailController.h
//  Sport
//
//  Created by haodong  on 15/4/14.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportController.h"
#import "MembershipCard.h"
#import "MembershipCardService.h"
#import "RechargeController.h"
#import "InputPasswordView.h"
#import "UserService.h"
#import "RegisterController.h"

@interface MembershipCardDetailController : SportController<UIActionSheetDelegate, MembershipCardServiceDelegate, RechargeControllerDelegate, UserServiceDelegate, InputPasswordViewDelegate,UIAlertViewDelegate,RegisterControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UIButton *bookButton;
@property (weak, nonatomic) IBOutlet UIButton *rechargeButton;

@property (weak, nonatomic) IBOutlet UIScrollView *infoHolderView;

- (id)initWithCard:(MembershipCard *)card;

@end
