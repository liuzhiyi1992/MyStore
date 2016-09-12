//
//  FastLoginController.h
//  Sport
//
//  Created by haodong  on 15/1/28.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportController.h"
#import "UserService.h"
#import "LoginDelegate.h"

@interface FastLoginController : SportController<UITextFieldDelegate, UserServiceDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *firstInputBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *secondInputBackgroundImageView;

@property (weak, nonatomic) IBOutlet UIButton *sendCodeButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *verificationTextField;

@property (weak, nonatomic) IBOutlet UIView *oldLoginButtonHolderView;

@property (weak, nonatomic) IBOutlet UIControl *userProtocolHolderView;

@property (copy, nonatomic) NSString *defaultPhone;

@property (assign, nonatomic) id<LoginDelegate> loginDelegate;
@property (copy, nonatomic) NSString *loginDelegateParameter;

@end
