//
//  ChangePasswordController.m
//  Sport
//
//  Created by haodong  on 13-9-14.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "ChangePasswordController.h"
#import "SportProgressView.h"
#import "User.h"
#import "UserManager.h"

@interface ChangePasswordController ()

@end

@implementation ChangePasswordController

- (void)viewDidUnload {
    [self setOldPasswordTextField:nil];
    [self setPasswordTextField:nil];
    [self setAgainPasswordTextField:nil];
    [self setSubmitButton:nil];
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = DDTF(@"修改密码");
    self.view.backgroundColor = [SportColor defaultPageBackgroundColor];
    [self.submitButton setBackgroundColor:[SportColor defaultColor]];
    [self.submitButton setTitle:DDTF(@"kSubmit") forState:UIControlStateNormal];
    
    self.oldPasswordTextField.delegate = self;
    self.againPasswordTextField.delegate = self;
    self.passwordTextField.delegate = self;
    //[self initSetLoginPasswordView];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.oldPasswordTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.againPasswordTextField resignFirstResponder];
    return YES;
}

- (IBAction)touchBackground:(id)sender {
    [self.oldPasswordTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.againPasswordTextField resignFirstResponder];
}

#define TAG_GET_VERIFICATION_AGAIN  2013091401
- (BOOL)checkRight
{
    BOOL result = YES;
    NSString *message = nil;
    NSInteger tag = 0;
    
    if (result && [self.oldPasswordTextField.text length] == 0) {
        message = DDTF(@"请输入旧密码");
        result =  NO;
    }
    
    if (result && [self.passwordTextField.text length] == 0) {
        message = DDTF(@"kPleaseEnterPassword");
        result =  NO;
    }
    
    if (result && [self.passwordTextField.text length] < 6) {
        message = DDTF(@"kPleaseEnterPasswordMoreThanSix");
        result =  NO;
    }
    
    if (result && [self.againPasswordTextField.text length] == 0) {
        message = DDTF(@"kPleaseEnterPasswordAgain");
        result =  NO;
    }
    
    if (result && [self.againPasswordTextField.text isEqualToString:self.passwordTextField.text] == NO) {
        message = DDTF(@"kInconsistentPasswordTwice");
        result =  NO;
    }
    
    if (result == NO) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:DDTF(@"kOK")
                                                  otherButtonTitles:nil];
        alertView.tag = tag;
        alertView.delegate = self;
        [alertView show];
    }
    return result;
}

- (IBAction)clickSubmitButton:(id)sender{
    [self.oldPasswordTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.againPasswordTextField resignFirstResponder];
    if ([self checkRight] == NO) {
        return;
    }
    
    [SportProgressView showWithStatus:DDTF(@"kSubmitting") hasMask:YES];
    User *user = [[UserManager defaultManager] readCurrentUser];
    [UserService changePassword:self
                         userId:user.userId
                    oldPassword:self.oldPasswordTextField.text
                    newPassword:self.passwordTextField.text];
}

- (void)didChangePassword:(NSString *)status
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismissWithSuccess:DDTF(@"修改密码成功")];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [SportProgressView dismissWithError:DDTF(@"修改密码失败")];
    }
}

@end
