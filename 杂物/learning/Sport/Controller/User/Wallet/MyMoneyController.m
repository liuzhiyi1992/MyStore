//
//  MyMoneyController.m
//  Sport
//
//  Created by haodong  on 15/3/21.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "MyMoneyController.h"
#import "UIUtils.h"
#import "PriceUtil.h"
#import "UIView+Utils.h"
#import "MyPointController.h"
#import "BaseConfigManager.h"
#import "SportWebController.h"
#import "MoneyRecordController.h"
#import "PointRecordController.h"
#import "SportPopupView.h"
#import "TicketService.h"
#import "UserManager.h"
#import "SportProgressView.h"
#import "MembershipCardVerifyPhoneController.h"
#import "RegisterController.h"
#import "UnableVouchersController.h"
#import "UserService.h"

@interface MyMoneyController () <TicketServiceDelegate, UIActionSheetDelegate, InputPasswordViewDelegate, UIAlertViewDelegate, UITextFieldDelegate, UserServiceDelegate>
@property (assign, nonatomic) int type;
@property (assign, nonatomic) float money;
@property (assign, nonatomic) int point;
@end

@implementation MyMoneyController

- (void)dealloc {
    [self deregsiterKeyboardNotification];
}

- (instancetype)initWithMoney:(float)money
{
    self = [super init];
    if (self) {
        self.type = TypeMoney;
        self.money = money;
        [self registerForKeyboardNotifications];
    }
    return self;
}

- (instancetype)initWithPoint:(int)point
{
    self = [super init];
    if (self) {
        self.type = TypePoint;
        self.point = point;
    }
    return self;
}

-(instancetype)initWithType:(int)myMoneyControllerType {
    self = [super init];
    if(self) {
        self.type = myMoneyControllerType;
        [self registerForKeyboardNotifications];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_type == TypeMoney) {
        self.title = @"余额";
        [self.topImageView setImage:[SportImage moneyImage]];
        self.subTitleLabel.text = @"趣运动余额";
        [self updateBalance:_money];
        self.goToShopButton.hidden = YES;
        self.inputHolderView.hidden = NO;
        
        [self.inputBackgroundImageView setImage:[SportImage balanceRechargeInputImage]];
      [self.rechargeButton setBackgroundImage:[SportImage balanceRechargeButtonImage] forState:UIControlStateNormal];
        
        [self createRightTopButton:@"支付密码"];
        
        [UserService userBalance:self userId:[[UserManager defaultManager] readCurrentUser].userId];
        [SportProgressView showWithStatus:@"刷新中"];
        
    } else {
        self.title = @"积分";
        [self.topImageView setImage:[SportImage pointImage]];
        self.subTitleLabel.text = @"当前积分";
        [self updateIntegral:_point];
        self.goToShopButton.hidden = NO;
        self.inputHolderView.hidden = YES;
        
        //1.80去掉
        //[self createRightTopButton:@"联系客服"];
        
        [UserService userIntegral:self userId:[[UserManager defaultManager] readCurrentUser].userId];
        [SportProgressView showWithStatus:@"刷新中"];
    }
    
    //适配不同设备
    if([UIScreen mainScreen].bounds.size.height <= 568) {
        for (NSLayoutConstraint *constraint in self.verticalSpaceConstraint) {
            constraint.constant = 0.6 * constraint.constant;
        }
    }
    
    HDLog(@"x:%f, y:%f, w:%f, h:%f", self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     if (_type == TypePoint) {
         [self updateMyPoint];
     }
}

- (void)updateMyPoint
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    self.valueLabel.text = [NSString stringWithFormat:@"%d", user.point];
}

#pragma mark UserServiceDelegate
- (void)didUserBalance:(double)balance status:(NSString *)status msg:(NSString *)msg
{
    [SportProgressView dismiss];
    
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [self updateBalance:balance];
    } else {
        [SportPopupView popupWithMessage:msg];
    }
}

- (void)didUserIntegral:(int)integral status:(NSString *)status msg:(NSString *)msg {
    
    [SportProgressView dismiss];
    
    if([status isEqualToString:STATUS_SUCCESS]) {
        [self updateIntegral:integral];
    }else {
        [SportPopupView popupWithMessage:msg];
    }
}

//- (void)viewWillLayoutSubviews
//{
//    [super viewWillLayoutSubviews];
//    self.slogonLabel.preferredMaxLayoutWidth = self.slogonLabel.bounds.size.width;
//}

- (void)clickLeftTopButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#define TAG_SETTING_NO_PAYPASSWORD 0x001
#define TAG_SETTING_PAYPASSWORD 0x002
- (void)clickRightTopButton:(id)sender
{
    if (_type == TypeMoney) {
        
        [MobClickUtils event:umeng_event_click_balance_pay_password];
        
        User *user = [[UserManager defaultManager] readCurrentUser];
        UIActionSheet *sheet = nil;
        if (user.hasPayPassWord) {
            sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                       cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:@"忘记支付密码", @"修改支付密码",nil];
            sheet.tag = TAG_SETTING_PAYPASSWORD;
        } else {
            sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                       cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:@"设置支付密码",nil];
            sheet.tag = TAG_SETTING_NO_PAYPASSWORD;
        }
        [sheet showInView:self.view];
        
    } else {
        BOOL result = [UIUtils makePromptCall:@"4000410480"];
        if (result == NO) {
            [SportPopupView popupWithMessage:@"此设备不支持打电话"];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    if ([[[UserManager defaultManager] readCurrentUser].phoneNumber length] == 0) {
        // 没有绑定手机号码，需先绑定
        [self bindPhone];
        return;
    }
    
    if (actionSheet.tag == TAG_SETTING_PAYPASSWORD) {
        // 忘记支付密码
        if (buttonIndex == 0) {
            MembershipCardVerifyPhoneController *controller =[[MembershipCardVerifyPhoneController alloc]initWithType:VerifyPhoneTypeForgotPayPassword];
            [self.navigationController pushViewController:controller animated:YES];
        }
        // 修改支付密码
        else if(buttonIndex == 1) {
            [self performSelector:@selector(showInputPasswordView:) withObject:@(InputPasswordTypeModify) afterDelay:0.5];
        }
    } else if(actionSheet.tag == TAG_SETTING_NO_PAYPASSWORD) {
        if (buttonIndex == 0) {
            //设置支付密码
            [self performSelector:@selector(showInputPasswordView:) withObject:@(InputPasswordTypeSet) afterDelay:0.5];
        }
    }
}

- (void)bindPhone
{
    RegisterController *controller  = [[RegisterController alloc] initWithVerifyPhoneType:VerifyPhoneTypeBind] ;
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)showInputPasswordView:(NSNumber *)typeValue
{
    InputPasswordType type = (InputPasswordType)[typeValue intValue];
    
    [InputPasswordView popUpViewWithType:type
                                delegate:self
                                 smsCode:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickDescButton:(id)sender {
    BaseConfigManager *manager = [BaseConfigManager defaultManager];
    
    NSString *url = nil;
    NSString *title = nil;
    
    if (_type == TypeMoney) {
        [MobClickUtils event:umeng_event_click_balance_explanation];
        
        url = manager.userMoneyRuleUrl;
        title = @"余额使用说明";
    } else {
        url = manager.creditRuleUrl;
        title = @"积分使用说明";
    }
    
    SportWebController *controller = [[SportWebController alloc] initWithUrlString:url title:title];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)clickRecordButton:(id)sender {
    if (_type == TypeMoney) {
        [MobClickUtils event:umeng_event_click_balance_record];
        MoneyRecordController *controller = [[MoneyRecordController alloc] initWithMoney:_money type:RecordTypeMoney] ;
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        PointRecordController *controller = [[PointRecordController alloc] init] ;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (IBAction)clickPointShopButton:(id)sender {
    MyPointController *controller = [[MyPointController alloc] init] ;
    [self.navigationController pushViewController:controller animated:YES];
}



- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [MobClickUtils event:umeng_event_click_balance_edit];
}

- (IBAction)clickRechargeButton:(id)sender {
    [MobClickUtils event:umeng_event_click_balance_charge];
    
    [self.rechargeTextField resignFirstResponder];
    
    if ([self.rechargeTextField.text length] == 0) {
        [SportPopupView popupWithMessage:@"请输入充值卡密码"];
        return;
    }
    
    [SportProgressView showWithStatus:@"正在提交"];
    [TicketService rechargeDebitCard:self
                              userId:[[UserManager defaultManager] readCurrentUser].userId
                            password:self.rechargeTextField.text];
}

- (void)updateBalance:(double)balance
{
    self.money = balance;
    [[UserManager defaultManager] readCurrentUser].balance = balance;
    self.valueLabel.text = [NSString stringWithFormat:@"¥ %@", [PriceUtil toValidPriceString:_money]];
}

- (void)updateIntegral:(int)integral {
    self.point = integral;
    [[UserManager defaultManager] readCurrentUser].point = integral;
    self.valueLabel.text = [NSString stringWithFormat:@"%d", _point];
}

#define TAG_ALERTVIEW_SET_PAY_PASSWORD    2015063001
- (void)didRechargeDebitCard:(double)balance status:(NSString *)status msg:(NSString *)msg
{
    [SportProgressView dismiss];
 
    int tag = 0;
    NSString *message = nil;
    
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [self updateBalance:balance];
        User *user = [[UserManager defaultManager] readCurrentUser];
        if (user.hasPayPassWord) {
            message = @"充值成功";
        } else {
            tag = TAG_ALERTVIEW_SET_PAY_PASSWORD;
            message = @"充值成功，请设置支付密码";
        }
    } else {
        message = msg;
    }
    
    //网络好的时候都清空
    if (status) {
        self.rechargeTextField.text = @"";
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:message                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil] ;
    alertView.tag = tag;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_ALERTVIEW_SET_PAY_PASSWORD) {
        //设置支付密码
        [self performSelector:@selector(showInputPasswordView:) withObject:@(InputPasswordTypeSet) afterDelay:0.5];
    }
}

- (void)keyboardWasShown:(NSNotification *) notif
{
    NSDictionary *info = [notif userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    
    CGFloat bottom = [UIScreen mainScreen].bounds.size.height - (20 + 44) - (self.inputHolderView.frame.origin.y + self.inputHolderView.frame.size.height);
    if (bottom < keyboardSize.height) {
        CGFloat offset = bottom - keyboardSize.height;
//        [self.topHolderView updateOriginY:offset];
        [self.topHolderViewTopToSuperConstraint setConstant:offset];
    }
}

- (void)keyboardWasHidden:(NSNotification *) notif
{
    [self.topHolderViewTopToSuperConstraint setConstant:0];
    //[self.topHolderView updateOriginY:0];
}

- (IBAction)touchDownBackground:(id)sender {
    [self.rechargeTextField resignFirstResponder];
}

@end
