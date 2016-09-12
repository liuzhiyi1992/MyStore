//
//  RegisterController.m
//  Sport
//
//  Created by haodong  on 13-6-4.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "RegisterController.h"
#import "SportProgressView.h"
#import "SportPopupView.h"
#import "UIUtils.h"
#import "RegisterManager.h"
#import "UIView+Utils.h"
#import "UserManager.h"
#import "SportWebController.h"
#import "BaseConfigManager.h"
#import "FastLoginController.h"
#import "LoginController.h"
#import "SportUUID.h"
#import "MobClickUtils.h"

@interface RegisterController ()
@property (copy, nonatomic) NSString *firstPhoneNumber;
@property (assign, nonatomic) VerifyPhoneType type;
@property (assign, nonatomic) BOOL stop;
@end

@implementation RegisterController


- (id)initWithVerifyPhoneType:(VerifyPhoneType)type
{
    self = [super init];
    if (self) {
        self.type = type;
    }
    return self;
}

- (id)initWithVerifyPhoneType:(VerifyPhoneType)type
                  phoneNumber:(NSString *)phoneNumber
{
    self = [super init];
    if (self) {
        self.type = type;
        self.firstPhoneNumber = phoneNumber;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [SportColor loginPageColor];
    self.topHolderView.backgroundColor = [SportColor loginPageColor];
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    [self.userProtocolHolderView updateOriginY:screenHeight - 20 - 44 - _userProtocolHolderView.frame.size.height];
    
    [self.view updateHeight:screenHeight - 20 - 44];
    [(UIScrollView *)self.view setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + 1)];
    
    [self.firstInputBackgroundImageView setImage:[SportImage otherCellBackground4Image]];
    [self.secondInputBackgroundImageView setImage:[SportImage otherCellBackground1Image]];
    [self.thirdInputBackgroundImageView setImage:[SportImage otherCellBackground2Image]];
    [self.fourthInputBackgroundImageView setImage:[SportImage otherCellBackground3Image]];
    
//    self.sendButton.layer.cornerRadius = 3.0f;
//    self.sendButton.layer.masksToBounds = YES;
//    [self.sendButton setBackgroundImage:[SportImage blueButtonImage] forState:UIControlStateNormal];
//    [self.sendButton setBackgroundImage:[SportColor createImageWithColor:[UIColor hexColor:@"aaaaaa"]] forState:UIControlStateDisabled];
//    [self.submitButton setBackgroundImage:[SportImage blueButtonImage] forState:UIControlStateNormal];
    
    self.bottomHolderView.hidden = YES;
    
    if ([_firstPhoneNumber length] > 0) {
        self.phoneNumberTextField.text = _firstPhoneNumber;
    }
    
    NSString *title = nil;
    NSString *submitButtonTitle = nil;
    if (_type == VerifyPhoneTypeRegiser) {
        title = @"注册";
        submitButtonTitle = @"注册";
    } else if (_type == VerifyPhoneTypeBind) {
        title = @"绑定手机号";
        submitButtonTitle = @"绑定手机号";
        
        [MobClickUtils event:umeng_event_enter_bind_phone];
        
    } else if (_type == VerifyPhoneTypeForgotPassword) {
        title = @"重置密码";
        submitButtonTitle = @"重置密码";
        
        self.passwordTextField.placeholder = @"请输入新密码";
        self.againPasswordTextField.placeholder = @"请再次输入新密码";
    } else if (_type == VerifyPhoneTypeBindUnionLogin) {
        title = @"绑定手机号";
        submitButtonTitle = @"绑定手机号";
        [self.topHolderView updateOriginY:self.topHolderView.frame.origin.y + 35];
        self.passwordHolderView.hidden = YES;
        [self.submitButton updateOriginY:CGRectGetMaxY(self.smsCodeHolderView.frame) + 15];
        
    }
    
    self.title = title;
    [self.submitButton setTitle:submitButtonTitle forState:UIControlStateNormal];
    
    self.phoneNumberTextField.inputAccessoryView = [self getNumberToolbar];
    
}

-(void)doneWithNumberPad{
    
    [self.phoneNumberTextField resignFirstResponder];
}

- (void)viewDidUnload {
    [self setPhoneNumberTextField:nil];
    [self setSendButton:nil];
    [super viewDidUnload];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.phoneNumberTextField resignFirstResponder];
    [self.verificationTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.againPasswordTextField resignFirstResponder];
}

- (IBAction)touchBackground:(id)sender {
    [self.phoneNumberTextField resignFirstResponder];
    [self.verificationTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.againPasswordTextField resignFirstResponder];
}

- (IBAction)clickSendButton:(id)sender {
    if ([self.phoneNumberTextField.text length] == 0) {
        [SportPopupView popupWithMessage:@"请填写手机号码"];
        return;
    }
    if ([self.phoneNumberTextField.text length] < 11) {
        [SportPopupView popupWithMessage:@"请填写正确的手机号码"];
        return;
    }
    
    [self.phoneNumberTextField resignFirstResponder];
    
    if ([RegisterManager hasSendVerificationCount:_type] > 15) {
        [SportPopupView popupWithMessage:@"你今天获取验证码过于频繁"];
        return;
    }
    
    [self changePhoneNumberInputStatus:NO];
    [SportProgressView showWithStatus:DDTF(@"kLoading")];
    [UserService getSMSCode:self
                      phone:_phoneNumberTextField.text
                    phoneEncode: nil
                       type:_type
                   openType:objc_getAssociatedObject(self, &kOpenTypeKey)];
}

#pragma mark - UserServiceDelegate
- (void)didGetSMSCode:(NSString *)status msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismissWithSuccess:@"已发送验证码，请查看手机" afterDelay:2];
        [self.verificationTextField becomeFirstResponder];
        
        [[RegisterManager defaultManager] setSendVerificationTime:[NSDate date]];
        [self calTime];

        if (self.bottomHolderView.hidden == YES) {
            self.bottomHolderView.hidden = NO;
            [self.bottomHolderView updateOriginY:self.view.frame.size.height + _bottomHolderView.frame.size.height];
            [UIView animateWithDuration:0.4 animations:^{
                [self.bottomHolderView updateOriginY:CGRectGetMaxY(_topHolderView.frame)];
            }];
        }
        
    } else {
        [self changePhoneNumberInputStatus:YES];

        self.bottomHolderView.hidden = YES;
        
        [SportProgressView dismissWithError:msg afterDelay:3];
        
        //友盟统计
        NSString *openType = objc_getAssociatedObject(self, &kOpenTypeKey);
        if (_type == VerifyPhoneTypeBindUnionLogin) {
            if ([openType isEqualToString:@"wx"]) {
                [MobClickUtils event:umeng_event_login_for_wx label:@"登录失败"];
            } else if ([openType isEqualToString:@"qq"]){
                [MobClickUtils event:umeng_event_login_for_qq label:@"登录失败"];
            } else if ([openType isEqualToString:@"sina"]) {
                [MobClickUtils event:umeng_event_login_for_sina label:@"登录失败"];
            }
        }
    }
}


- (void)changePhoneNumberInputStatus:(BOOL)canEdit
{
    if (canEdit) {
        self.phoneNumberTextField.enabled = YES;
        self.phoneNumberTextField.textColor = [UIColor colorWithRed:76.0/255.0 green:76.0/255.0 blue:76.0/255.0 alpha:1];
    } else {
        self.phoneNumberTextField.enabled = NO;
        self.phoneNumberTextField.textColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _stop = NO;
    [self calTime];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _stop = YES;
}

- (void)calTime
{
    int diff = [[NSDate date] timeIntervalSince1970] - [[[RegisterManager defaultManager] sendVerificationTime] timeIntervalSince1970];
    if (diff < 60 && _stop == NO) {
        HDLog(@"剩下%d", 60 - diff);
        
        if (self.sendButton.enabled) {
            self.sendButton.enabled = NO;
        }
        NSString *title = [NSString stringWithFormat:@"重新获取(%d秒)", 60 - diff];
        [self.sendButton setTitle:title forState:UIControlStateNormal];
        self.sendButton.titleLabel.text = title;
    } else {
        self.sendButton.enabled = YES;
        [self.sendButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self calTime];
        });
    });
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([UIScreen mainScreen].bounds.size.height == 480) {
        if (textField == _verificationTextField
            || textField == _passwordTextField
            || textField == _againPasswordTextField) {
            [(UIScrollView *)self.view setContentOffset:CGPointMake(0, _topHolderView.frame.size.height - 10) animated:NO];
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [(UIScrollView *)self.view setContentOffset:CGPointMake(0, 0) animated:NO];
}

//提交
- (IBAction)clickSubmitButton:(id)sender {
    [self.verificationTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.againPasswordTextField resignFirstResponder];
    
    if ([self checkRight] == NO) {
        return;
    }
    
    if (_type == VerifyPhoneTypeRegiser) {
        [SportProgressView showWithStatus:DDTF(@"kSubmitting") hasMask:YES];
        [UserService registerUser:self
                      phoneNumber:_phoneNumberTextField.text
                         password:_passwordTextField.text
                          smsCode:_verificationTextField.text];
    } else if (_type == VerifyPhoneTypeBind) {
        [SportProgressView showWithStatus:DDTF(@"kSubmitting") hasMask:YES];
        User *user = [[UserManager defaultManager] readCurrentUser];
        [UserService bindPhone:self
                        userId:user.userId
                   phoneNumber:_phoneNumberTextField.text
                      password:_passwordTextField.text
                       smsCode:_verificationTextField.text];
    } else if (_type == VerifyPhoneTypeForgotPassword) {
        [SportProgressView showWithStatus:DDTF(@"kSubmitting") hasMask:YES];
        User *user = [[UserManager defaultManager] readCurrentUser];
        [UserService resetPassword:self
                            userId:user.userId
                       phoneNumber:_phoneNumberTextField.text
                          password:_passwordTextField.text
                           smsCode:_verificationTextField.text];
    } else if (_type == VerifyPhoneTypeBindUnionLogin) {
        [SportProgressView showWithStatus:DDTF(@"kSubmitting") hasMask:YES];
        NSString *openId = objc_getAssociatedObject(self, &kOpenIdKey);
        NSString *unionId = objc_getAssociatedObject(self, &kUnionIdKey);
        NSString *openType = objc_getAssociatedObject(self, &kOpenTypeKey);
        NSString *accessToken = objc_getAssociatedObject(self, &kAccessTokenKey);
        NSString *avatar = objc_getAssociatedObject(self, &kAvatarKey);
        NSString *nickName = objc_getAssociatedObject(self, &kNickNameKey);
        NSString *gender = objc_getAssociatedObject(self, &kGenderKey);
        
        [UserService unionPhone:self phoneNum:_phoneNumberTextField.text smsCode:_verificationTextField.text openId:openId unionId:unionId accessToken:accessToken openType:openType avatar:avatar nickName:nickName gender:gender];
    }
}


#define TAG_GET_VERIFICATION_AGAIN  2013070401
- (BOOL)checkRight
{
    BOOL result = YES;
    NSString *message = nil;
    NSInteger tag = 0;
    
    if (result && [self.verificationTextField.text length] == 0) {
        message = DDTF(@"kPleaseEnterVerification");
        result =  NO;
    }
    
    if (result && [self.passwordTextField.text length] == 0 && _type != VerifyPhoneTypeBindUnionLogin) {
        message = DDTF(@"kPleaseEnterPassword");
        result =  NO;
    }
    
    if (result && [self.passwordTextField.text length] < 6 && _type != VerifyPhoneTypeBindUnionLogin) {
        message = DDTF(@"kPleaseEnterPasswordMoreThanSix");
        result =  NO;
    }
    
    if (result && [self.passwordTextField.text length] > 20) {
        message = DDTF(@"密码长度不能超过20位");
        result =  NO;
    }
    
    if (result && [self.againPasswordTextField.text length] == 0 && _type != VerifyPhoneTypeBindUnionLogin) {
        message = DDTF(@"kPleaseEnterPasswordAgain");
        result =  NO;
    }
    
    if (result && [self.againPasswordTextField.text isEqualToString:self.passwordTextField.text] == NO) {
        message = DDTF(@"kInconsistentPasswordTwice");
        result =  NO;
    }
    
//    NSError *error;
//    NSString *saveVer = [RegisterManager readVerification:&error];
//    if (result && saveVer == nil) {
//        switch (error.code) {
//            case VerificationErrorInvalid:
//                message = DDTF(@"kVerificationInvalid");
//                break;
//            default:
//                message = DDTF(@"kVerificationUnknow");
//                break;
//        }
//        tag = TAG_GET_VERIFICATION_AGAIN;
//        result =  NO;
//    }else if (result && [saveVer isEqualToString:_verificationTextField.text] == NO)
//    {
//        message = DDTF(@"kVerificationWrong");
//        result =  NO;
//    }
    
    if (result == NO) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:DDTF(@"kOK")
                                                  otherButtonTitles: nil];
        alertView.tag = tag;
        alertView.delegate = self;
        [alertView show];
    }
    
    return result;
}

#pragma mark - UserServiceDelegate
- (void)didRegisterUser:(NSString *)userId
                 status:(NSString *)status
                    msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView showWithStatus:DDTF(@"kLoggingIn") hasMask:YES];
        [UserService login:self phoneNumber:_phoneNumberTextField.text password:_passwordTextField.text];
    } else {
        [SportProgressView dismissWithError:msg];
    }
    
}

- (void)didLogin:(NSString *)userId
          status:(NSString *)status
             msg:(NSString *)msg
           phone:(NSString *)phone
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismissWithSuccess:DDTF(@"kLoginSuccess")];
        
        [UserManager didLoginSuccessWithPhoneNumber:_phoneNumberTextField.text];
        
        BOOL animated = (self.loginDelegate == nil);
        
        if ([self previousPreviousControllerIsFastLoginController]) {
            NSUInteger count = [self.navigationController.viewControllers count];
            NSUInteger targetIndex = (count >= 4 ? count - 4  : 0 ); //退3页
            UIViewController *targetController = [self.navigationController.childViewControllers objectAtIndex:targetIndex];
            [self.navigationController popToViewController:targetController animated:animated];
        } else {
            NSUInteger count = [self.navigationController.viewControllers count];
            NSUInteger targetIndex = (count >= 3 ? count - 3  : 0 ); //退2页
            UIViewController *targetController = [self.navigationController.childViewControllers objectAtIndex:targetIndex];
            [self.navigationController popToViewController:targetController animated:animated];
        }
        
        if ([_loginDelegate respondsToSelector:@selector(didLoginAndPopController:)]) {
            [_loginDelegate didLoginAndPopController:_loginDelegateParameter];
        }
        
    } else {
        [SportProgressView dismissWithError:msg];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didUnionPhone:(NSString *)status msg:(NSString *)msg {
    if ([status isEqualToString:STATUS_SUCCESS]) {
        //是否需要有些许延时
        [_delegate didUnionPhoneWithStatus:status msg:msg];
        [self.navigationController popViewControllerAnimated:NO];
    }else {
        [SportProgressView dismissWithError:msg];
    }
    
}

//更新极光ID，pushToken统一在prepareForLoginSuccess中发通知到AppDelegate完成
//- (void)updatePushToken
//{
//    User *user = [[UserManager defaultManager] readCurrentUser];
//    NSString *pushToken = [UserManager readPushToken];
//    if (pushToken != nil) {
//        [UserService updatePushToken:nil
//                              userId:user.userId
//                           pushToken:pushToken
//                            deviceId:[SportUUID uuid]];
//    }
//}


- (BOOL)previousPreviousControllerIsFastLoginController //前一个的前一个Controller是否FastLoginController
{
    NSUInteger count = [self.navigationController.viewControllers count];
    if (count > 3) {
        if ([[self.navigationController.viewControllers objectAtIndex:count - 3] isKindOfClass:[FastLoginController class]]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

- (void)didBindPhone:(NSString *)status
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismissWithSuccess:DDTF(@"绑定成功")];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [SportProgressView dismissWithError:DDTF(@"绑定失败")];
    }
}

- (void)didResetPassword:(NSString *)status
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        
        if ([_delegate respondsToSelector:@selector(didRestPasswordAndBack:)]) {
            [_delegate didRestPasswordAndBack:_phoneNumberTextField.text];
        }
        
        [SportProgressView dismissWithSuccess:DDTF(@"重设密码成功")];
        
        [UserManager hasShowFirstLoginPage];
        
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [SportProgressView dismissWithError:DDTF(@"重设密码失败")];
    }
}

- (IBAction)clickUserProtocolButton:(id)sender {
    NSString *url = [[BaseConfigManager defaultManager] userProtocolUrl];
    SportWebController *controller = [[SportWebController alloc] initWithUrlString:url title:@"趣运动用户协议"];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
