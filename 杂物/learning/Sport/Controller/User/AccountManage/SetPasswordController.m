//
//  SetPasswordController.m
//  Sport
//
//  Created by haodong  on 15/2/3.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SetPasswordController.h"
#import "User.h"
#import "UserManager.h"
#import "SportProgressView.h"
#import "SportPopupView.h"

@interface SetPasswordController ()
@property (weak, nonatomic) IBOutlet UIButton *isSetLoginPasswordButton;

@end

#define TAG_SKIP_PASSWORD 0x001

@implementation SetPasswordController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"设置登录密码";
    
    [self.firstBackgroundImageView setImage:[SportImage otherCellBackground1Image]];
    [self.secondBackgroundImageView setImage:[SportImage otherCellBackground3Image]];
    
//    [self.okButton setBackgroundImage:[SportImage blueButtonImage] forState:UIControlStateNormal];
    
    if ([_delegate respondsToSelector:@selector(didClickSetPasswordBackButton)]) {
        self.isSetLoginPasswordButton.hidden = NO;
    }
    else
    {
        self.isSetLoginPasswordButton.hidden = YES;
    }
}

- (BOOL)checkRight
{
    BOOL result = YES;
    NSString *message = nil;
    NSInteger tag = 0;
    
    if (result && [self.passwordTextField.text length] == 0) {
        message = @"请输入密码";
        result =  NO;
    }
    
    if (result && [self.passwordTextField.text length] < 6) {
        message = @"请输入六位以上的密码";
        result =  NO;
    }
    
    if (result && [self.passwordTextField.text length] > 20) {
        message = @"密码长度不能超过20位";
        result =  NO;
    }
    
    if (result && [self.againPasswordTextField.text length] == 0) {
        message = @"请再次输入密码";
        result =  NO;
    }
    
    if (result && [self.againPasswordTextField.text isEqualToString:self.passwordTextField.text] == NO) {
        message = @"两次密码不一致";
        result =  NO;
    }
    
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

- (IBAction)clickOkButton:(id)sender {
    if ([self checkRight]) {
        [SportPopupView popupWithMessage:@"提交中..."];
        User *user = [[UserManager defaultManager] readCurrentUser];
        [UserService setPassword:self userId:user.userId password:_againPasswordTextField.text];
    }
}

- (void)didSetPassword:(NSString *)status msg:(NSString *)msg
{
    BOOL isSetPassword = NO;

    if ([status isEqualToString:STATUS_SUCCESS] ||
        [status isEqualToString:STATUS_DUPLICATE_PASSWORD]) {
        isSetPassword = YES;
    }  else {
        [SportPopupView popupWithMessage:msg];
    }
        
    if (isSetPassword) {
        User *user = [[UserManager defaultManager] readCurrentUser];
        user.hasPassWord = YES;
        [[UserManager defaultManager] saveCurrentUser:user];
        
        if ([_delegate respondsToSelector:@selector(didClickSetPasswordBackButton)]) {
            [_delegate didClickSetPasswordBackButton];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)clickSkipLoginPassword:(id)sender {
    [self clickBackButton:nil];
}

- (void)clickBackButton:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"不设置登录密码的用户可以使用“短信验证登录”功能，免密码登录趣运动"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"确定", nil];
    alertView.tag = TAG_SKIP_PASSWORD;
    [alertView show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_SKIP_PASSWORD) {
        
        if ([_delegate respondsToSelector:@selector(didClickSetPasswordBackButton)]) {
            [_delegate didClickSetPasswordBackButton];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
        

    }
}



@end
