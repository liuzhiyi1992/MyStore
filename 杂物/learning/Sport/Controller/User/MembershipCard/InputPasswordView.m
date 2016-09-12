//
//  InputPasswordView.m
//  Sport
//
//  Created by haodong  on 15/4/15.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "InputPasswordView.h"
#import <QuartzCore/QuartzCore.h>
#import "UserManager.h"
#import "SportPopupView.h"

@interface InputPasswordView()

@property (weak, nonatomic) IBOutlet UIView *contentHolderView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *passwordHolderView;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIView *loadHolderView;
@property (weak, nonatomic) IBOutlet UILabel *loadTitleLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (copy, nonatomic) NSString *userId;
@property (assign ,nonatomic) InputPasswordType inputType;
@property (copy, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *smsCode;
@property (assign, nonatomic) id<InputPasswordViewDelegate> delegate;

@property (assign, nonatomic) BOOL hasVerify;
@property (copy, nonatomic) NSString *oldPassword;

@end

#define PASSWORD_LENGTH 6
@implementation InputPasswordView


+ (BOOL)popUpViewWithType:(InputPasswordType)type
                 delegate:(id<InputPasswordViewDelegate>)delegate
                  smsCode:(NSString *)smsCode
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"InputPasswordView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return NO;
    }
    InputPasswordView *view = (InputPasswordView *)[topLevelObjects objectAtIndex:0];
    view.contentHolderView.layer.cornerRadius = 3;
    view.contentHolderView.layer.masksToBounds = YES;
    view.passwordTextField.delegate = view;
    view.loadHolderView.hidden = YES;
    view.inputType = type;
    view.delegate = delegate;
    view.smsCode = smsCode;
    view.frame = [UIScreen mainScreen].bounds;
    for (UIView *view in [UIApplication sharedApplication].keyWindow.subviews) {
        if ([view isKindOfClass:[InputPasswordView class]]) {
            [view removeFromSuperview];
        }
    }
    
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    [view.passwordTextField becomeFirstResponder];
    
    NSString *title = nil;
    switch (type) {
        case InputPasswordTypeVerify:
            title = @"请输入趣运动支付密码";
            break;
        case InputPasswordTypeSet:
            title = @"请设置趣运动支付密码";
            break;
        case InputPasswordTypeReset:
            title = @"请输入密码";
            break;
        case InputPasswordTypeModify:
            title = @"请输入原密码";
            break;
        default:
            break;
    }
    
    [view clearInputAndResetTitle:title];
    
    view.userId = [[[UserManager defaultManager] readCurrentUser] userId];
    
    return YES;
}

//清空输入框，重置标题
- (void)clearInputAndResetTitle:(NSString *)title
{
    self.titleLabel.text = title;
    self.passwordTextField.text = nil;
    [self updateShowPassword:0];
    [self.passwordTextField becomeFirstResponder];
    
    //由小放大的动画
    self.contentHolderView.alpha = 0;
    self.contentHolderView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    [UIView animateWithDuration:0.2 animations:^{
        self.contentHolderView.alpha = 1;
        self.contentHolderView.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

//消失
- (void)dismiss
{
    [self removeFromSuperview];
}

- (IBAction)clickCloseButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didHideInputPasswordView)]) {
        [_delegate didHideInputPasswordView];
    }
    [self dismiss];
}

//更改显示长度
- (void)updateShowPassword:(NSUInteger)length
{
    for (int i = 0; i < PASSWORD_LENGTH; i ++) {
        UIView *subView = [self.passwordHolderView viewWithTag:10 + i];
        if (length > 0 && i < length) {
            subView.hidden = NO;
        } else {
            subView.hidden = YES;
        }
    }
}

- (void)loadWithTitle:(NSString *)title
{
    self.loadTitleLabel.text = title;
    self.loadHolderView.hidden = NO;
    [self.activityIndicatorView startAnimating];
}

- (void)hideLoad
{
    self.loadHolderView.hidden = YES;
    [self.activityIndicatorView startAnimating];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * aString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSUInteger length = [aString length];
    
    [self updateShowPassword:length];
    
    if (length == PASSWORD_LENGTH) {
        
        switch (self.inputType) {
                
            //验证密码
            case InputPasswordTypeVerify:
            {
                self.password = aString;
                [self.passwordTextField resignFirstResponder];
                [self loadWithTitle:@"正在验证"];
                [UserService verifyPayPassword:self
                                        userId:self.userId
                                      password:self.password];
                break;
            }
            
            //设置密码
            case InputPasswordTypeSet:
            {
                 if (self.password == nil) {
                     self.password = aString;
                     [self clearInputAndResetTitle:@"再次输入密码以确认"];
                     
                 } else {
                     
                     if ([self.password isEqualToString:aString]) {
                         
                         [self.passwordTextField resignFirstResponder];
                         [self loadWithTitle:@"正在设置密码"];
                         User *user = [[UserManager defaultManager] readCurrentUser];
                         [UserService setPayPassword:self
                                              userId:user.userId
                                            password:self.password];
                         
                     } else {
                         self.password = nil;
                         [self clearInputAndResetTitle:@"两次输入密码不一致，请重新输入密码"];
                     }
                 }
                
                break;
            }
            
            //重置密码
            case InputPasswordTypeReset:
            {
                if (self.password == nil) {
                    self.password = aString;
                    [self clearInputAndResetTitle:@"再次输入密码以确认"];
                    
                } else {
                    if ([self.password isEqualToString:aString]) {
                        
                        [self.passwordTextField resignFirstResponder];
                        [self loadWithTitle:@"正在重置密码"];
                        User *user = [[UserManager defaultManager] readCurrentUser];
                        [UserService resetPayPassword:self
                                               userId:user.userId
                                          phoneNumber:user.phoneEncode
                                             password:aString
                                              smsCode:self.smsCode];
                        
                    } else {
                        self.password = nil;
                        [self clearInputAndResetTitle:@"两次输入密码不一致，请重新输入密码"];
                    }
                }
                break;
            }
                
            //修改密码
            case InputPasswordTypeModify:
            {
                if (self.hasVerify == NO) {
                    [self.passwordTextField resignFirstResponder];
      
                    [self loadWithTitle:@"正在验证"];
                    [UserService verifyPayPassword:self
                                            userId:self.userId
                                          password:aString];
                } else {
                    if (self.password == nil) {
                        self.password = aString;
                        [self clearInputAndResetTitle:@"再次输入新密码以确认"];
                        
                    } else {
                        if ([self.password isEqualToString:aString]) {
                            
                            [self.passwordTextField resignFirstResponder];
                            [self loadWithTitle:@"正在修改密码"];
                            User *user = [[UserManager defaultManager] readCurrentUser];
                            [UserService changePayPassword:self
                                                    userId:user.userId
                                               oldPassword:self.oldPassword
                                               newPassword:self.password];
                        } else {
                            self.password = nil;
                            [self clearInputAndResetTitle:@"两次输入密码不一致，请重新输入密码"];
                        }
                    }
                }
                break;
            }
            default:
                break;
        }
        return NO;
    } else {
        return YES;
    }
}

- (void)didVerifyPayPassword:(NSString *)status msg:(NSString *)msg payPassword:(NSString *)payPassword
{
    [self hideLoad];
    
    if (self.inputType == InputPasswordTypeVerify) {
        
        if ([status isEqualToString:STATUS_SUCCESS] == NO) {
            [SportPopupView popupWithMessage:msg];
        }
        
        if ([_delegate respondsToSelector:@selector(didFinishVerifyPayPassword:status:)]) {
            [_delegate didFinishVerifyPayPassword:self.password status:status];
        }
        
        [self dismiss];
    
    } else if (self.inputType == InputPasswordTypeModify) {
        
        if ([status isEqualToString:STATUS_SUCCESS] == NO) {
            [SportPopupView popupWithMessage:msg];
            [self dismiss];
        } else {
            self.oldPassword = payPassword;
            self.hasVerify = YES;
            [self clearInputAndResetTitle:@"请输入新密码"];
        }
    }
}

- (void)didSetPayPassword:(NSString *)status msg:(NSString *)msg
{
    [self hideLoad];
    if ([status isEqualToString:STATUS_SUCCESS] == NO) {
        [SportPopupView popupWithMessage:msg];
    }
    
    if ([_delegate respondsToSelector:@selector(didFinishSetPayPassword:status:)]) {
        [_delegate didFinishSetPayPassword:self.password status:status];
    }
    
    [self dismiss];
}

- (void)didResetPayPassword:(NSString *)status msg:(NSString *)msg
{
    [self hideLoad];
    if ([status isEqualToString:STATUS_SUCCESS] == NO) {
        [SportPopupView popupWithMessage:msg];
    } else {
        [SportPopupView popupWithMessage:@"重置支付密码成功"];
    }
    
    if ([_delegate respondsToSelector:@selector(didFinishResetPayPassword:status:)]) {
        [_delegate didFinishResetPayPassword:self.password status:status];
    }
    
    [self dismiss];
}

- (void)didChangePayPassword:(NSString *)status msg:(NSString *)msg
{
    [self hideLoad];
    if ([status isEqualToString:STATUS_SUCCESS] == NO) {
        [SportPopupView popupWithMessage:msg];
    } else {
        [SportPopupView popupWithMessage:@"修改支付密码成功"];
    }
    
    if ([_delegate respondsToSelector:@selector(didFinishModifyPayPassword:status:)]) {
        [_delegate didFinishModifyPayPassword:self.password status:status];
    }
    
    [self dismiss];
}

@end
