//
//  MonthCardRechargeController.m
//  Sport
//
//  Created by qiuhaodong on 15/6/11.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "MonthCardRechargeController.h"
#import "UIView+Utils.h"
#import "MonthCardService.h"
#import "PriceUtil.h"
#import "SportProgressView.h"
#import "UserManager.h"
#import "Voucher.h"
#import "PayController.h"
#import "RegisterController.h"
#import "BaseConfigManager.h"
#import "CityManager.h"

@interface MonthCardRechargeController ()<OrderConfirmPriceViewDelegate, MonthCardServiceDelegate, UIAlertViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) Voucher *selectedVoucher;
@property (copy, nonatomic) NSString *selectedActivityId;

@property (assign, nonatomic) NSUInteger count;
@property (assign, nonatomic) NSUInteger maxCount;

@property (weak, nonatomic) IBOutlet UIView *priceHolderView;
@property (weak, nonatomic) IBOutlet UITextField *countTextField;
@property (weak, nonatomic) IBOutlet UIButton *minusButton;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;
@property (weak, nonatomic) IBOutlet UIImageView *inputBackgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *goodsNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodsPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UIButton *payButton;
@property (weak, nonatomic) IBOutlet UIView *bottomHolderView;
@property (weak, nonatomic) IBOutlet UIControl *bottomControl;

@end

@implementation MonthCardRechargeController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#define MAX_COUNT 12 //最大购买数量
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"购买动Club";
    [self createRightTopButton:@"了解更多"];
    self.maxCount = MAX_COUNT;
    self.count = 1;
    self.minusButton.enabled = NO;
    [self.view sportUpdateAllBackground];
    [self.inputBackgroundImageView setImage:[SportImage inputBackgroundWhiteImage]];
    [self.minusButton setBackgroundImage:[SportImage minusButtonImage] forState:UIControlStateNormal];
    [self.plusButton setBackgroundImage:[SportImage plusButtonImage] forState:UIControlStateNormal];
    [self.minusButton setBackgroundImage:[SportImage minusButtonOffImage] forState:UIControlStateDisabled];
    [self.plusButton setBackgroundImage:[SportImage plusButtonOffImage] forState:UIControlStateDisabled];
    
    [self.payButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateNormal];
    
    [self calculatePrice];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updatePhone];
}

- (void)clickRightTopButton:(id)sender
{
    [MobClickUtils event:umeng_event_month_buy_club_click_know_more];
    NSString *urlString = [[BaseConfigManager defaultManager] moncardHelpUrl];
    SportWebController *controller = [[SportWebController alloc] initWithUrlString:urlString title:@"动Club介绍"] ;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)touchDownBackground:(id)sender {
    [self.countTextField resignFirstResponder];
     self.bottomControl.hidden = YES;
}

- (void)calculatePrice
{
    [SportProgressView showWithStatus:@"" hasMask:YES];
    [MonthCardService monCardConfirmOrder:self goodsNumber:_count];
}

#define TAG_PRICE_VIEW 2015061101
- (void)didMonCardConfirmOrder:(NSString *)status
                           msg:(NSString *)msg
                       goodsId:(NSString *)goodsId
                     goodsName:(NSString *)goodsName
                      onePrice:(float)onePrice
                   totalAmount:(float)totalAmount
                   orderAmount:(float)orderAmount
                  orderPromote:(float)orderPromote
                    activityId:(NSString *)activityId
                  activityList:(NSArray *)activityList
               activityMessage:(NSString *)activityMessage
                   goodsNumber:(NSUInteger)goodsNumber
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        
        [SportProgressView dismiss];
        
        self.goodsNameLabel.text = goodsName;
        self.goodsPriceLabel.text = [PriceUtil toPriceStringWithYuan:onePrice];
        self.count = goodsNumber;
        [self updateCoutTextField];
        
        //设置priceHolderView
        [[self.priceHolderView viewWithTag:TAG_PRICE_VIEW] removeFromSuperview];
        OrderConfirmPriceView *orderConfirmPriceView = [OrderConfirmPriceView createOrderConfirmPriceView];
        self.orderConfirmPriceView=orderConfirmPriceView;
        orderConfirmPriceView.tag = TAG_PRICE_VIEW;
        orderConfirmPriceView.delegate = self;
        [orderConfirmPriceView updateViewWithAmount:totalAmount
                           canUseActivityAndVoucher:YES
                                       activityList:activityList
                                 selectedActivityId:activityId
                                            voucher:_selectedVoucher
                                         controller:self
                                    activityMessage:activityMessage
                                           goodsIds:goodsId
                                          orderType:OrderTypeMonthCardRecharge];
        [self.priceHolderView addSubview:orderConfirmPriceView];
        [self.priceHolderView updateHeight:orderConfirmPriceView.frame.size.height];
        
        [self updateBottomHolderView];
        
        [self removeNoDataView];
    } else {
        
        [SportProgressView dismissWithError:msg];
        
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        [self showNoDataViewWithType:NoDataTypeDefault frame:CGRectMake(0, 0, screenSize.width, screenSize.height - 20 - 44) tips:nil];
    }
}

- (void)didSelectActivity:(NSString *)selectedActivityId
{
    self.selectedVoucher = nil;
    self.selectedActivityId = selectedActivityId;
}

- (void)didSelectVoucher:(Voucher *)voucher
{
    self.selectedVoucher = voucher;
    self.selectedActivityId = nil;
}

- (void)didCancelSelectVoucher
{
    self.selectedVoucher = nil;
}

- (void)updateCoutTextField
{
    self.countTextField.text = [@(_count) stringValue];
}

- (void)updateMinusButtonAndPlusButton
{
    if (_count <= 1) {
        self.minusButton.enabled = NO;
        self.count = 1;
    } else {
        self.minusButton.enabled = YES;
    }
    
    if (_count >= _maxCount) {
        self.plusButton.enabled = NO;
        self.count = _maxCount;
    } else {
        self.plusButton.enabled = YES;
    }
    
    [self calculatePrice];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [MobClickUtils event:umeng_event_month_buy_club_click_count_edit];
    self.bottomControl.hidden = NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * aString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([aString length] > 0) {
        self.count = [aString intValue];
        [self updateMinusButtonAndPlusButton];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.count = [textField.text intValue];
    [self updateMinusButtonAndPlusButton];
    self.bottomControl.hidden = YES;
}

- (IBAction)clickMinusButton:(id)sender {
    [MobClickUtils event:umeng_event_month_buy_club_click_count_decrease];
    
    self.count = [self.countTextField.text intValue];
    [self.countTextField resignFirstResponder];
    
    if (_count > 1) {
        _count --;
    }
    
    [self updateMinusButtonAndPlusButton];
    
    [self updateCoutTextField];
}

- (IBAction)clickPlusButton:(id)sender {
    [MobClickUtils event:umeng_event_month_buy_club_click_count_increase];
    
    self.count = [self.countTextField.text intValue];
    [self.countTextField resignFirstResponder];
    
    if (_count < _maxCount) {
        _count ++;;
    }
    
    [self updateMinusButtonAndPlusButton];
    
    [self updateCoutTextField];
}

- (void)updatePhone
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    if ([user.phoneNumber length] > 0) {
        self.phoneLabel.text = [NSString stringWithFormat:@"您的手机号码:%@", user.phoneNumber];
    } else {
        self.phoneLabel.text = @"您未绑定手机号码";
    }
}

- (void)updateBottomHolderView
{
    [self.bottomHolderView updateOriginY:_priceHolderView.frame.origin.y + _priceHolderView.frame.size.height + 10];
}

#define TAG_ALERTVIEW_BIND_PHONE 2015061701
- (IBAction)clickPayButton:(id)sender {
    
    User *user  = [[UserManager defaultManager] readCurrentUser];
    if ([user.phoneNumber length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"为了您的账号安全，请绑定手机号码再提交订单" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        alertView.tag = TAG_ALERTVIEW_BIND_PHONE;
        [alertView show];
        return;
    }
    
    [SportProgressView showWithStatus:@"正在提交订单"];
    [MonthCardService addMonCardOrder:self
                                phone:user.phoneNumber
                          goodsNumber:_count
                           activityId:_selectedActivityId
                             couponId:_selectedVoucher.voucherId
                           ticketType:[@(_selectedVoucher.type) stringValue]
                               cityId:[CityManager readCurrentCityId]];
}

- (void)didAddMonCardOrder:(Order *)order status:(NSString *)status msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismiss];
        PayController *controller = [[PayController alloc] initWithOrder:order];
        [self.navigationController pushViewController:controller animated:YES];

    } else {
        [SportProgressView dismissWithError:msg];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_ALERTVIEW_BIND_PHONE) {
        RegisterController *controller = [[RegisterController alloc] initWithVerifyPhoneType:VerifyPhoneTypeBind] ;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end
