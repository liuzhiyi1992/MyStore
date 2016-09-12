//
//  RegisterController.h
//  Sport
//
//  Created by haodong  on 13-6-4.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SportController.h"
#import "UserService.h"
#import "LoginDelegate.h"
#import <objc/runtime.h>

//捆绑第三方登陆资料用key
const char kOpenIdKey;
const char kUnionIdKey;
const char kAccessTokenKey;
const char kOpenTypeKey;
const char kAvatarKey;
const char kNickNameKey;
const char kGenderKey;

@protocol RegisterControllerDelegate <NSObject>
@optional
- (void)didRestPasswordAndBack:(NSString *)phoneNumber;
- (void)didUnionPhoneWithStatus:(NSString *)status msg:(NSString *)msg;
@end

@interface RegisterController : SportController <UserServiceDelegate, UITextFieldDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *firstInputBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *secondInputBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *thirdInputBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *fourthInputBackgroundImageView;

@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *verificationTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *againPasswordTextField;

@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (weak, nonatomic) IBOutlet UIControl *topHolderView;
@property (weak, nonatomic) IBOutlet UIControl *bottomHolderView;
@property (weak, nonatomic) IBOutlet UIControl *userProtocolHolderView;
@property (weak, nonatomic) IBOutlet UIView *passwordHolderView;
@property (weak, nonatomic) IBOutlet UIView *smsCodeHolderView;

@property (assign, nonatomic) id<RegisterControllerDelegate> delegate;

@property (assign, nonatomic) id<LoginDelegate> loginDelegate;
@property (copy, nonatomic) NSString *loginDelegateParameter;

- (id)initWithVerifyPhoneType:(VerifyPhoneType)type;

- (id)initWithVerifyPhoneType:(VerifyPhoneType)type
                  phoneNumber:(NSString *)phoneNumber;

@end
