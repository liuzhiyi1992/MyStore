//
//  LoginController.h
//  Sport
//
//  Created by haodong  on 13-6-6.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SportController.h"
#import "UserService.h"
#import "SNSService.h"
#import "QQManager.h"
#import "RegisterController.h"
#import "LoginDelegate.h"
#import <RongIMKit/RongIMKit.h>

@interface LoginController : SportController <UserServiceDelegate, SNSServiceDelegate, QQManagerDelegate, UITextFieldDelegate, UIScrollViewDelegate, RegisterControllerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *firstOpenHolderView;
@property (weak, nonatomic) IBOutlet UIButton *firstOpenLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *firstOpenRegisterButton;

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

@property (weak, nonatomic) IBOutlet UIImageView *firstInputBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *secondBackgroundImageView;

@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@property (weak, nonatomic) IBOutlet UIButton *sinaWeiboButton;
@property (weak, nonatomic) IBOutlet UIButton *qqButton;
@property (weak, nonatomic) IBOutlet UIButton *weChatButton;

@property (weak, nonatomic) IBOutlet UIView *otherLoginHolderView;

@property (weak, nonatomic) IBOutlet UIImageView *triangleImageView;

@property (weak, nonatomic) IBOutlet UIButton *SMSLoginButton;

@property (assign, nonatomic) id<LoginDelegate> loginDelegate;
@property (copy, nonatomic) NSString *loginDelegateParameter;

- (instancetype)initWithIsCanUseOtherLogin:(BOOL)isCanUseOtherLogin;

@end
