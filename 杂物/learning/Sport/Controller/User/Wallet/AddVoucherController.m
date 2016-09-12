//
//  AddVoucherController.m
//  Sport
//
//  Created by qiuhaodong on 15/6/29.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "AddVoucherController.h"
#import "AbleVouchersController.h"
#import "SportWebController.h"
#import "BaseConfigManager.h"
#import "SportPopupView.h"
#import "UserManager.h"
#import "SportProgressView.h"
#import "TicketService.h"
#import "OtherController.h"
#import "Voucher.h"
#import "BusinessOrderConfirmController.h"
#import "CoachConfirmOrderController.h"
#import "CoachListController.h"
#import "HomeController.h"
#import "MonthCardRechargeController.h"
#import "SingleBookingController.h"
@interface AddVoucherController () <TicketServiceDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *inputBackgroundImageView;
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property (weak, nonatomic) IBOutlet UIButton *bindButton;

@property (strong, nonatomic) Voucher *voucher;

@end

@implementation AddVoucherController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"绑定卡券";
    
    [self.inputBackgroundImageView setImage:[SportImage addVoucherInputImage]];
    [self.bindButton setBackgroundImage:[SportImage addVoucherButtonImage] forState:UIControlStateNormal];
    
  //  [self createRightTopButton:@"我的卡券"];
}

- (void)clickRightTopButton:(id)sender {
    [MobClickUtils event:umeng_event_click_bind_ticket_my_ticket];
    AbleVouchersController *controller = [[AbleVouchersController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)clickBindButton:(id)sender {
    [MobClickUtils event:umeng_event_click_bind_ticket_bind_btn];
    
    [self.inputTextField resignFirstResponder];
 
    if ([self.inputTextField.text length] == 0) {
        [SportPopupView popupWithMessage:@"请输入卡券密码"];
        return;
    }
    
    [SportProgressView showWithStatus:@"正在提交"];
    User *user = [[UserManager defaultManager] readCurrentUser];
    [TicketService addVoucher:self
                       userId:user.userId
                voucherNumber:self.inputTextField.text
                     goodsIds:self.goodsIds
                    orderType:self.orderType];
}

- (void)didAddVoucher:(NSString *)status msg:(NSString *)msg voucher:(Voucher *)voucher
{
    [SportProgressView dismiss];
    
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportPopupView popupWithMessage:@"绑定成功"];
    } else {
        [SportPopupView popupWithMessage:msg];
    }
    
    //网络好的时候都清空
    if (status) {
        self.inputTextField.text = @"";
    }
    
    self.voucher = voucher;
    
    if ([status isEqualToString:STATUS_SUCCESS]) {
        
        
        if ([self.entry isEqualToString:@"0"]) {//来自我的卡券
            [self.navigationController popViewControllerAnimated:YES];
            
        } else if([self.entry isEqualToString:@"1"]){//来自订单
            
            if (![voucher validToUse:_orderAmount]) {
                NSString *message = [NSString stringWithFormat:@"此代金劵只适用于支付金额大于%d元的订单", (int)([voucher minAmountToUse])];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
                return;
            }
            
            if (!_voucher.isEnable) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:_voucher.disableMessage delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
                return;
            }
            
            NSUInteger count = [self.navigationController.childViewControllers count];
            
            UIViewController *Controller =[self.navigationController.childViewControllers objectAtIndex:count-3];
            
            if ([Controller isKindOfClass:[BusinessOrderConfirmController class]]) {
                BusinessOrderConfirmController *targetController =(BusinessOrderConfirmController *)Controller;
                self.delegate=targetController.orderConfirmPriceView;
                if ([_delegate respondsToSelector:@selector(didAddVoucher:)]) {
                    [_delegate didAddVoucher:_voucher];
                }
                
                [self.navigationController popToViewController:targetController animated:YES];
            }else if ([Controller isKindOfClass:[CoachConfirmOrderController class]]){
                
                CoachConfirmOrderController *targetController =(CoachConfirmOrderController *)Controller;
                
                self.delegate=targetController.orderConfirmPriceView;
                
                [self.navigationController popToViewController:targetController animated:YES];
                if ([_delegate respondsToSelector:@selector(didAddVoucher:)]) {
                    [_delegate didAddVoucher:_voucher];
                }
                
            }else if ([Controller isKindOfClass:[MonthCardRechargeController class]]){
                
                MonthCardRechargeController *targetController =(MonthCardRechargeController *)Controller;
                
                self.delegate=targetController.orderConfirmPriceView;
                
                [self.navigationController popToViewController:targetController animated:YES];
                if ([_delegate respondsToSelector:@selector(didAddVoucher:)]) {
                    [_delegate didAddVoucher:_voucher];
                }
                
            }else if ([Controller isKindOfClass:[SingleBookingController class]]){
                
                SingleBookingController *targetController =(SingleBookingController *)Controller;
                
                self.delegate=targetController.orderConfirmPriceView;
                
                [self.navigationController popToViewController:targetController animated:YES];
                if ([_delegate respondsToSelector:@selector(didAddVoucher:)]) {
                    [_delegate didAddVoucher:_voucher];
                }
            }
        }
    }
}

- (IBAction)clickHelpButton:(id)sender {
    [MobClickUtils event:umeng_event_click_bind_ticket_explanation];
    SportWebController *controller = [[SportWebController alloc] initWithUrlString:[[BaseConfigManager defaultManager] couponRuleUrl] title:@"卡券使用说明"] ;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
