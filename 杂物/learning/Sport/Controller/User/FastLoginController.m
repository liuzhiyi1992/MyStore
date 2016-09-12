//
//  FastLoginController.m
//  Sport
//
//  Created by haodong  on 15/1/28.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "FastLoginController.h"
#import "SportPopupView.h"
#import "SportProgressView.h"
#import "User.h"
#import "UserManager.h"
#import "SportUUID.h"
#import "LoginController.h"
#import "RegisterManager.h"
#import "UIView+Utils.h"
#import "SportWebController.h"
#import "BaseConfigManager.h"

@interface FastLoginController ()
@property (assign, nonatomic) BOOL stop;
@end

@implementation FastLoginController


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"短信验证登录";
    
    if ([_defaultPhone length] > 0) {
        self.phoneNumberTextField.text = _defaultPhone;
    }
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    [self.userProtocolHolderView updateOriginY:screenHeight - 20 - 44 - _userProtocolHolderView.frame.size.height];
    
    [self.view updateHeight:screenHeight - 20 - 44];
    [(UIScrollView *)self.view setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + 1)];
    
    [self.firstInputBackgroundImageView setImage:[SportImage otherCellBackground1Image]];
    [self.secondInputBackgroundImageView setImage:[SportImage otherCellBackground3Image]];
    
    //[self.sendCodeButton setBackgroundImage:[SportImage blueButtonImage] forState:UIControlStateNormal];
    
    if ([self previousControllerIsLoginController]) {
        self.oldLoginButtonHolderView.hidden = YES;
    }
    
    self.phoneNumberTextField.inputAccessoryView = [self getNumberToolbar];
    self.verificationTextField.inputAccessoryView = [self getNumberToolbar];
}

-(void)doneWithNumberPad{
    [self.phoneNumberTextField resignFirstResponder];
    [self.verificationTextField resignFirstResponder];
}

- (IBAction)clickSendCodeButton:(id)sender {
    if ([self.phoneNumberTextField.text length] == 0) {
        [SportPopupView popupWithMessage:@"请填写手机号码"];
        return;
    }
    if ([self.phoneNumberTextField.text length] < 11) {
        [SportPopupView popupWithMessage:@"请填写正确的手机号码"];
        return;
    }
    
    [self.phoneNumberTextField resignFirstResponder];
    
    [SportProgressView showWithStatus:@"正在提交..."];
    [UserService getSMSCode:self phone:_phoneNumberTextField.text phoneEncode:nil type:1 openType:nil];
}

- (void)didGetSMSCode:(NSString *)status msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismissWithSuccess:@"获取成功，请查收短信"];
        
        [[RegisterManager defaultManager] setSendVerificationTime:[NSDate date]];
        [self calTime];
        
    } else {
        if (msg) {
            [SportProgressView dismissWithError:msg];
        } else {
            [SportProgressView dismissWithError:@"网络出问题了，请稍后再试"];
        }
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
        
        if (self.sendCodeButton.enabled) {
            self.sendCodeButton.enabled = NO;
        }
        NSString *title = [NSString stringWithFormat:@"重新获取(%d秒)", 60 - diff];
        [self.sendCodeButton setTitle:title forState:UIControlStateNormal];
        self.sendCodeButton.titleLabel.text = title;
    } else {
        self.sendCodeButton.enabled = YES;
        [self.sendCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self calTime];
        });
    });
}

- (IBAction)clickSubmitButton:(id)sender {
    [self.phoneNumberTextField resignFirstResponder];
    [self.verificationTextField resignFirstResponder];
    
    if ([self.phoneNumberTextField.text length] == 0) {
        [SportPopupView popupWithMessage:@"请输入电话号码"];
        return;
    }
    if ([self.verificationTextField.text length] == 0) {
        [SportPopupView popupWithMessage:@"请输入验证码"];
        return;
    }
    
    [SportProgressView showWithStatus:@"正在登录..."];
    [UserService quickLogin:self phone:_phoneNumberTextField.text SMSCode:_verificationTextField.text];
}

- (void)didQuickLogin:(NSString *)status msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismissWithSuccess:DDTF(@"kLoginSuccess")];
        
        [UserManager didLoginSuccessWithPhoneNumber:_phoneNumberTextField.text];
        
        BOOL animated = (self.loginDelegate == nil);
        
        if ([self previousControllerIsLoginController]) { //如果前一个Controller是LoginController，则退两页
            
            NSUInteger count = [self.navigationController.viewControllers count];
            NSUInteger targetIndex = (count >= 3 ? count - 3  : 0 ); //
            UIViewController *targetController = [self.navigationController.childViewControllers objectAtIndex:targetIndex];
            [self.navigationController popToViewController:targetController animated:animated];
        } else {
            [self.navigationController popViewControllerAnimated:animated];
        }
        
        if ([_loginDelegate respondsToSelector:@selector(didLoginAndPopController:)]) {
            [_loginDelegate didLoginAndPopController:_loginDelegateParameter];
        }
        
    } else {
        [SportProgressView dismissWithError:msg];
    }
}

- (BOOL)previousControllerIsLoginController //前一个Controller是否LoginController
{
    NSUInteger count = [self.navigationController.viewControllers count];
    if (count > 2) {
        if ([[self.navigationController.viewControllers objectAtIndex:count - 2] isKindOfClass:[LoginController class]]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

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

- (IBAction)clickUserProtocolButton:(id)sender {
    NSString *url = [[BaseConfigManager defaultManager] userProtocolUrl];
    SportWebController *controller = [[SportWebController alloc] initWithUrlString:url title:@"趣运动用户协议"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)touchBackground:(id)sender {
    [self.phoneNumberTextField resignFirstResponder];
    [self.verificationTextField resignFirstResponder];
}

- (IBAction)clickOldLoginButton:(id)sender {
    LoginController *controller = [[LoginController alloc] initWithIsCanUseOtherLogin:YES];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
