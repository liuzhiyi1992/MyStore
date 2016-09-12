//
//  MembershipCardVerifyPhoneController.m
//  Sport
//
//  Created by 江彦聪 on 15/4/17.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "MembershipCardVerifyPhoneController.h"
#import "UIView+Utils.h"
#import "SportPopupView.h"
#import "SportProgressView.h"
#import "MembershipCardVerifyManager.h"
#import "AddMembershipCardController.h"
#import "BaseConfigManager.h"
#import "SportWebController.h"
#import "UserManager.h"

@interface MembershipCardVerifyPhoneController ()

@property (assign, nonatomic) NSUInteger smsCodeLength;
@property (strong, nonatomic) MembershipCard *card;
@property (assign, nonatomic) VerifyPhoneType type;
@property (copy, nonatomic) NSString *smsCode;
@property (copy, nonatomic) NSString *phone;
@property (copy, nonatomic) NSString *phoneEncode;
@property (weak, nonatomic) IBOutlet UIButton *phoneInfoButton;

@property (weak, nonatomic) IBOutlet UILabel *noticeTextlabel;
@property (weak, nonatomic) IBOutlet UIView *verifyHolderView;
@property (weak, nonatomic) IBOutlet UIButton *downCountGetCodeButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *controlHeightConstraint;
@property (assign, nonatomic) BOOL stop;

@property (weak, nonatomic) IBOutlet UILabel *setLoginPasswordPhoneLabel;
@property (weak, nonatomic) IBOutlet UIView *setLoginPasswordView;

@property (weak, nonatomic) IBOutlet UIImageView *firstInputBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *secondInputBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *loginPasswordNextButton;
@property (weak, nonatomic) IBOutlet UITextField *firstPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *secondPasswordTextField;
@property (weak, nonatomic) IBOutlet UIControl *getVerifyNumberView;

@property (weak, nonatomic) IBOutlet UIView *inputPasswordView;

@property (weak, nonatomic) IBOutlet UIView *sucessfulNoticeView;

@property (weak, nonatomic) IBOutlet UIButton *sendCodeButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *verificationTextField;
@property (weak, nonatomic) IBOutlet UIControl *userProtocolHolderView;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (assign, nonatomic) BOOL isBindNewPhone;
@end

@implementation MembershipCardVerifyPhoneController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(id) initWithType:(VerifyPhoneType)type {
    self = [super init];
    if (self) {
        self.type = type;
    }
    
    return self;
}

-(id)initWithType:(VerifyPhoneType)type
             card:(MembershipCard *)card
    isBindNewPhone:(BOOL)isBindNewPhone {
    self = [self initWithType:type];
    if (self) {
        self.card = card;
        self.isBindNewPhone = isBindNewPhone;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.type == VerifyPhoneTypeForgotPayPassword) {
        self.title = @"忘记支付密码";
        self.phone = [[UserManager defaultManager] readCurrentUser].phoneNumber;
        self.phoneEncode = [[UserManager defaultManager] readCurrentUser].phoneEncode;
        self.phoneNumberTextField.text = self.phone;
        self.userProtocolHolderView.hidden = YES;
        self.phoneInfoButton.hidden = YES;
    }
    else if(self.type == VerifyPhoneTypeMembershipCard) {
        if (self.isBindNewPhone) {
            self.title = @"确认转移";
            self.phone = self.card.phone;
            self.phoneEncode = self.card.phoneEncode;
            
        }else {
            self.title = @"重新绑定";
            self.phone = self.card.oldPhone;
            self.phoneEncode = self.card.oldPhoneEncode;
        }
        
        self.phoneNumberTextField.text = self.phone;
        self.userProtocolHolderView.hidden = YES;
        self.phoneInfoButton.hidden = YES;

    }else {
        self.title = @"会员卡登录";
        if ([self.card.phone length] > 0) {
            self.phoneNumberTextField.text = self.card.phone;
        }
    }
    
    self.phoneNumberTextField.enabled = NO;
    
    [(UIScrollView *)self.view setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + 1)];
    
    [self.firstInputBackgroundImageView setImage:[SportImage otherCellBackground1Image]];
    [self.secondInputBackgroundImageView setImage:[SportImage otherCellBackground3Image]];
    
//    self.verifyHolderView.layer.cornerRadius = 5.0f;
//    self.verifyHolderView.layer.masksToBounds = YES;
//    self.verifyHolderView.layer.borderWidth = 1.0f;
//    self.verifyHolderView.layer.borderColor = [SportColor defaultColor].CGColor;

//    [self.sendCodeButton setBackgroundImage:[SportImage blueButtonImage] forState:UIControlStateNormal];
//    [self.submitButton setBackgroundImage:[SportImage grayButtonImage] forState:UIControlStateNormal];
    self.submitButton.enabled = NO;
    self.submitButton.hidden = YES;
    
    self.sendCodeButton.hidden = NO;
    self.noticeTextlabel.text = @"";
    
    self.controlHeightConstraint.constant = [UIScreen mainScreen].bounds.size.height - self.navigationController.navigationBar.frame.origin.y - self.navigationController.navigationBar.frame.size.height+1;
    [self.view layoutSubviews];
    
    self.getVerifyNumberView.hidden = NO;
    self.verifyHolderView.hidden = YES;
    
    //跳转到setPasswordController，这里暂时不用
    self.setLoginPasswordView.hidden = YES;
    self.sucessfulNoticeView.hidden = YES;
    
    self.smsCodeLength = 5;
    self.verificationTextField.delegate = self;
    self.verificationTextField.inputAccessoryView = [self getNumberToolbar];
    //[self initSetLoginPasswordView];
}

-(void)doneWithNumberPad{
    [self.verificationTextField resignFirstResponder];

}

- (void)initSetLoginPasswordView
{
    [self.firstInputBackgroundImageView setImage:[SportImage otherCellBackground1Image]];
    [self.secondInputBackgroundImageView setImage:[SportImage otherCellBackground3Image]];
    
    self.loginPasswordNextButton.layer.cornerRadius = 3.0f;
    self.loginPasswordNextButton.layer.masksToBounds = YES;

}
- (IBAction)clickLoginPasswordNextButton:(id)sender {
    if ([self.firstPasswordTextField.text length] < 6) {
        [SportPopupView popupWithMessage:@"请输入至少6位登录密码"];
        return;
    }
    if ([self.firstPasswordTextField.text isEqualToString:self.secondPasswordTextField.text]) {
        [SportPopupView popupWithMessage:@"两次输入的密码不一致"];
        return;
    }
    
}
- (IBAction)clickSkipLoginPasswordButton:(id)sender {
    
    
}

#define TAG_PHONE_INFO 0x001
#define TAG_VERIFY_PHONE 0x002

- (IBAction)clickSendCodeButton:(id)sender {
    
    [MobClickUtils event:umeng_event_card_login_click_get_code];
    
    if ([self.phoneNumberTextField.text length] == 0) {
        [SportPopupView popupWithMessage:@"请填写手机号码"];
        return;
    }
    if ([self.phoneNumberTextField.text length] < 11) {
        [SportPopupView popupWithMessage:@"请填写正确的手机号码"];
        return;
    }
    
//    if (self.type == VerifyPhoneTypeMembershipCard) {
//        
//        NSString *message = @"验证后该手机号将自动登录趣运动，并绑定会员卡";
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
//                                                            message:message
//                                                           delegate:self
//                                                  cancelButtonTitle:@"确定"
//                                                  otherButtonTitles:nil, nil];
//        alertView.tag = TAG_VERIFY_PHONE;
//        [alertView show];
//    }
    [self sendSMSCode];


}
- (IBAction)clickResendCodeButton:(id)sender {
    
    NSString *message = @"验证码已重新发送";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
    [alertView show];

    [self sendSMSCode];
}

-(void) sendSMSCode {
    [SportProgressView showWithStatus:@"正在提交..."];
    [UserService getSMSCode:self phone:_phoneNumberTextField.text phoneEncode:self.phoneEncode type:self.type openType:nil];
}

- (void)didGetSMSCode:(NSString *)status msg:(NSString *)msg length:(int)length
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismiss];
        
        self.smsCodeLength = length;
        self.sendCodeButton.hidden = YES;
        self.verifyHolderView.hidden = NO;
        self.submitButton.hidden = NO;
        self.noticeTextlabel.text = @"验证码已发送到您的手机";
        
        [[MembershipCardVerifyManager defaultManager] setSendVerificationTime:[NSDate date]];
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
    int diff = [[NSDate date] timeIntervalSince1970] - [[[MembershipCardVerifyManager defaultManager] sendVerificationTime] timeIntervalSince1970];
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
    
    self.smsCode = self.verificationTextField.text;
    
    if (self.type == VerifyPhoneTypeMembershipCard) {

        User *user = [[UserManager defaultManager] readCurrentUser];
        
        if (_isBindNewPhone) {
            [SportProgressView showWithStatus:@"正在转移..."];
            [MembershipCardService setUserCardBindWithUserId:user.userId cardNo:self.card.cardNumber businessId:self.card.businessId phoneEncode:self.card.phoneEncode smsCode:self.smsCode completion:^(NSString *status, NSString *msg) {
                if ([status isEqualToString:STATUS_SUCCESS]) {
                    [SportProgressView dismissWithSuccess:@"转移成功"];
                    [self exitBindProcess];
                } else {
                    [SportProgressView dismissWithError:msg];
                }
            }];
        } else {
            [SportProgressView showWithStatus:@"正在绑定..."];
            [MembershipCardService confirmUserCardWithUserId:user.userId cardNo:self.card.cardNumber businessId:self.card.businessId phoneEncode:self.card.oldPhoneEncode smsCode:self.smsCode completion:^(NSString *status, NSString *msg) {
                if ([status isEqualToString:STATUS_SUCCESS]) {
                    [SportProgressView dismissWithSuccess:@"绑定成功"];
                    [self exitBindProcess];
                } else {
                    [SportProgressView dismissWithError:msg];
                }
            }];
        }
        
//        [SportProgressView showWithStatus:@"正在登录..."];
//        
//        [MembershipCardService cardLogin:self
//                              cardNumber:self.card.cardNumber
//                                   phone:self.card.phone
//                                 smsCode:self.smsCode];
    }
    else if (self.type == VerifyPhoneTypeForgotPayPassword) {
        
        [SportProgressView showWithStatus:@"正在验证"];
//        [[UserManager defaultManager] readCurrentUser].phoneEncode;
        [UserService verifySMSCode:self
                             phone:self.phoneNumberTextField.text
                             phoneEncode:[[UserManager defaultManager] readCurrentUser].phoneEncode                                             SMSCode:self.smsCode
                             type:self.type];
    }
}

-(void)didVerifySMSCode:(NSString *)status msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismiss];

        self.getVerifyNumberView.hidden = YES;
        [self performSelector:@selector(showInputPasswordWithTypeValue:) withObject:@(InputPasswordTypeReset) afterDelay:0.5];
        
    } else {
        if (msg) {
            [SportProgressView dismissWithError:msg];
        }
    }
}

#pragma mark - MembershipCardDelegate
- (void)didCardLogin:(NSString *)status
                 msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismiss];
        
        self.getVerifyNumberView.hidden = YES;
        self.sucessfulNoticeView.hidden = NO;
        self.phoneNumberLabel.text = self.card.phone;
        
        User *user = [[UserManager defaultManager] readCurrentUser];

        //新注册用户，才提示设置登录密码

        if (user.hasPassWord == NO) {
            SetPasswordController *controller = [[SetPasswordController alloc]init];
            [self.navigationController pushViewController:controller animated:YES];
            controller.delegate = self;
        }
        else {
            //有支付密码，就直接退出
            if(user.hasPayPassWord == YES) {
                [self exitBindProcess];
            }
            //没有支付密码，就停留在页面，让用户选择输入或者退出
        }
    }
    else {
        [SportProgressView dismissWithError:msg];
    }
}

- (void)clickBackButton:(id)sender
{
    [self exitBindProcess];
}


-(void)didClickSetPasswordBackButton
{

    User *user = [[UserManager defaultManager] readCurrentUser];
    if (user.hasPayPassWord == YES) {
        //有支付密码，就直接退出
        [self performSelector:@selector(exitBindProcess) withObject:nil afterDelay:0.5];
    }
    else
    {
        //没有支付密码，就停留在页面，让用户选择输入或者退出
    }
}


//会退到会员卡列表页面
- (void) exitBindProcess
{
    if ([self previousControllerIsAddMembershipCardController]) { //如果前一个Controller是AddMembershipCardController，则退两页
        
        NSUInteger count = [self.navigationController.viewControllers count];
        NSUInteger targetIndex = (count >= 3 ? count - 3  : 0 ); //
        UIViewController *targetController = [self.navigationController.childViewControllers objectAtIndex:targetIndex];
        [self.navigationController popToViewController:targetController animated:YES];
        
    } else if (self.type == VerifyPhoneTypeForgotPayPassword) {
        [self.navigationController popViewControllerAnimated:YES];
        
    }else if (self.type == VerifyPhoneTypeMembershipCard){
        if(self.isBindNewPhone) {
            NSUInteger count = [self.navigationController.viewControllers count];
            NSUInteger targetIndex = (count >= 3 ? count - 3  : 0 ); //
            UIViewController *targetController = [self.navigationController.childViewControllers objectAtIndex:targetIndex];
            [self.navigationController popToViewController:targetController animated:YES];
        }else {
             [self.navigationController popViewControllerAnimated:YES];
        }
    }else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (BOOL)previousControllerIsAddMembershipCardController //前一个Controller是否AddMembershipCardController
{
    NSUInteger count = [self.navigationController.viewControllers count];
    if (count > 2) {
        if ([[self.navigationController.viewControllers objectAtIndex:count - 2] isKindOfClass:[AddMembershipCardController class]]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

- (IBAction)clickUserProtocolButton:(id)sender {
    
    NSString *url = [[BaseConfigManager defaultManager] userProtocolUrl];
    SportWebController *controller = [[SportWebController alloc] initWithUrlString:url title:@"趣运动用户协议"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)touchBackground:(id)sender {
    [self.phoneNumberTextField resignFirstResponder];
    [self.verificationTextField resignFirstResponder];
    
    [self.firstPasswordTextField resignFirstResponder];
    [self.secondPasswordTextField resignFirstResponder];
}

- (IBAction)clickPhoneInfoButton:(id)sender {
    [MobClickUtils event:umeng_event_card_login_click_help];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"该手机号码是您在办理会员卡时填写的手机号码。\n没有预留手机号、忘记手机号或已停用，请联系场馆进行处理。"
                                                       delegate:self
                                              cancelButtonTitle:@"知道了"
                                              otherButtonTitles:nil, nil];
    alertView.tag = TAG_PHONE_INFO;
    [alertView show];
    
}

#pragma mark -- Alert View Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_VERIFY_PHONE) {
        if (buttonIndex == alertView.cancelButtonIndex) {

        }
    }
}

#pragma mark -- UITextField Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * aString = [textField.text stringByReplacingCharactersInRange:range withString:string];

    if ([aString length] >= self.smsCodeLength) {
//        [self.submitButton setBackgroundImage:[SportImage blueButtonImage] forState:UIControlStateNormal];
        self.submitButton.enabled = YES;
    }
    else {
//        [self.submitButton setBackgroundImage:[SportImage grayButtonImage] forState:UIControlStateNormal];
        self.submitButton.enabled = NO;
    }
    
    return YES;
}


#pragma mark --InputPasswordDelegate
- (void)showInputPasswordWithTypeValue:(NSNumber *)typeValue
{
    NSString *code = nil;
    InputPasswordType type = (InputPasswordType)[typeValue intValue];
    
    if (type == InputPasswordTypeReset)
    {
        code = self.smsCode;
    }
    
    [InputPasswordView popUpViewWithType:type
                                delegate:self
                                smsCode:code];
}


//输入完设置支付密码
- (void)didFinishSetPayPassword:(NSString *)payPassword status:(NSString *)status
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"设置支付密码成功"
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"确定", nil];
        [alertView show];
    }
    
    [self exitBindProcess];
}
    
- (void)didFinishResetPayPassword:(NSString *)payPassword status:(NSString *)status
{
    [self.navigationController popViewControllerAnimated:YES];
}
    
//中断输入支付密码
-(void)didHideInputPasswordView
{
    [self exitBindProcess];
}

- (IBAction)clickSetPayPasswordButton:(id)sender {
    
    [self showInputPasswordWithTypeValue:@(InputPasswordTypeSet)];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
