//
//  PrizeShareController.h
//  Sport
//
//  Created by haodong  on 14/10/28.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportController.h"
#import "UserService.h"
#import <MessageUI/MessageUI.h>

@interface PrizeShareController : SportController<UIActionSheetDelegate, UserServiceDelegate, MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *topBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *inputBackgroundImageView;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UILabel *shareTipsLabel;

@end
