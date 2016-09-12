//
//  RechargeController.m
//  Sport
//
//  Created by haodong  on 15/4/14.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "RechargeController.h"
#import "RechargeAmountCell.h"
#import "PayTypeCell.h"
#import "BaseConfigManager.h"
#import "UIView+Utils.h"
#import "SportPopupView.h"
#import "PayMethod.h"
#import "MembershipCardRechargeGoods.h"
#import "PriceUtil.h"
#import "UserManager.h"
#import "SportProgressView.h"
#import "Order.h"
#import "NSDictionary+JsonValidValue.h"
#import "AliPayOrder.h"
#import "AliPayManager.h"
#import "WeChatPayManager.h"
#import "UIUtils.h"
#import "CityManager.h"

@interface RechargeController ()

@property (strong, nonatomic) NSArray *goodsList;
@property (strong, nonatomic) MembershipCardRechargeGoods *selectedGoods;
@property (strong, nonatomic) MembershipCard *card;
@property (strong, nonatomic) PayMethod *selectedPayMethod;
@property (strong, nonatomic) Order *order;
@property (assign, nonatomic) BOOL localPaySuccess;
@end

@implementation RechargeController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_ALIPAY_PAY_CALLBACK object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NAME_FINISH_WECHAT_PAY object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (instancetype)initWithGoodsList:(NSArray *)goodsList card:(MembershipCard *)card
{
    self = [super init];
    if (self) {
        self.goodsList = goodsList;
        self.card = card;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleAlipayCallBack:)
                                                     name:NOTIFICATION_ALIPAY_PAY_CALLBACK
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleWeChatCallBack:)
                                                     name:NOTIFICATION_NAME_FINISH_WECHAT_PAY
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"会员卡充值";
    
    if ([_goodsList count] > 0) {
        self.selectedGoods = [self.goodsList objectAtIndex:0];
    }
    
    //设置基本信息
    for (UIView *subView in self.baseHolderView.subviews) {
        if ([subView isKindOfClass:[UIImageView class]]) {
            if (subView.tag == 200) {
                [(UIImageView *)subView setImage:[SportImage whiteBackgroundImage]];
            } else if (subView.tag == 100) {
                [(UIImageView *)subView setImage:[SportImage lineImage]];
            } else if (subView.tag == 101) {
                [(UIImageView *)subView setImage:[SportImage lineVerticalImage]];
            }
        }
    }
    
    self.businessNameLabel.text = self.card.businessName;
    self.cardNumberLabel.text = self.card.cardNumber;
    self.cardPhoneLabel.text = self.card.phone;
    
    //设置充值金额
    [self.amountTableView updateHeight:[RechargeAmountCell getCellHeight] * [self.goodsList count]];
    
    //设置支付金额
    [self.payAmountHolderView updateOriginY:self.amountTableView.frame.origin.y + self.amountTableView.frame.size.height + 10];
    [self updatePayAmount];
    
    //设置支付方式
    [self.payTypeTableView updateOriginY:self.payAmountHolderView.frame.origin.y + self.payAmountHolderView.frame.size.height + 10];
    [self.payTypeTableView updateHeight:[PayTypeCell getCellHeight] * [[[BaseConfigManager defaultManager] payMethodList] count]];
    
    //设置支付按钮
    [self.payButton updateOriginY:self.payTypeTableView.frame.origin.y + self.payTypeTableView.frame.size.height + 10];
    [self.payButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateNormal];
    
    [(UIScrollView *)self.unpayHolderView setContentSize:CGSizeMake(self.unpayHolderView.frame.size.width, self.payButton.frame.origin.y + self.payButton.frame.size.height + 10)];
    
    //订场按钮
    [self.bookButton setBackgroundImage:[SportImage blueButtonImage] forState:UIControlStateNormal];
    
    //刷新按钮
    [self.refreshButton setBackgroundImage:[SportImage blueButtonImage] forState:UIControlStateNormal];
}

- (void)updatePayAmount
{
    self.needPayAmount.text = [PriceUtil toPriceStringWithYuan:self.selectedGoods.amount];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _amountTableView) {
        return [_goodsList count];
    } else {
        return [[[BaseConfigManager defaultManager] payMethodList] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _amountTableView) {
        NSString *identifier = [RechargeAmountCell getCellIdentifier];
        RechargeAmountCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [RechargeAmountCell createCell];
        }
        
        //workaround for IOS 7 auto layout bug
        if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
        {
            cell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
        }
        
        MembershipCardRechargeGoods *goods = [_goodsList objectAtIndex:indexPath.row];
        BOOL isSelected = [self.selectedGoods.goodsId isEqualToString:goods.goodsId];
        BOOL isLast = (indexPath.row == [_goodsList count] - 1);
        [cell updateCellWithGoods:goods isSelected:isSelected indexPath:indexPath isLast:isLast];
        
        return cell;
    } else {
        NSString *identifier = [PayTypeCell getCellIdentifier];
        PayTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [PayTypeCell createCell];
        }
        
        NSArray *list = [[BaseConfigManager defaultManager] payMethodList];
        PayMethod *method = [list objectAtIndex:indexPath.row];
        BOOL isSelected = [self.selectedPayMethod.payKey isEqualToString:method.payKey];
        BOOL isLast = (indexPath.row == [list count] - 1);
        
        [cell updateCellWithPayMethod:method
                         isSelected:isSelected
                          indexPath:indexPath
                             isLast:isLast];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _amountTableView) {
        return [RechargeAmountCell getCellHeight];
    } else {
        return [PayTypeCell getCellHeight];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _amountTableView) {
        [MobClickUtils event:umeng_event_card_recharge_switch_goods];
        
        self.selectedGoods = [_goodsList objectAtIndex:indexPath.row];
        
        [self updatePayAmount];
        [tableView reloadData];
    } else {
        PayMethod *method = [[[BaseConfigManager defaultManager] payMethodList] objectAtIndex:indexPath.row];
        self.selectedPayMethod = method;
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [tableView reloadData];
    }
}

- (IBAction)clickPayButton:(id)sender {
    if (self.selectedPayMethod == nil) {
        [SportPopupView popupWithMessage:@"请选择支付方式"];
        return;
    }
    
    if ([self.selectedPayMethod.payKey isEqualToString:PAY_METHOD_ALIPAY_CLIENT]) {
        [MobClickUtils event:umeng_event_card_recharge_click_pay label:@"支付宝客户端支付"];
    } else if ([self.selectedPayMethod.payKey  isEqualToString:PAY_METHOD_ALIPAY_WAP]) {
        [MobClickUtils event:umeng_event_card_recharge_click_pay label:@"支付宝网页支付"];
    } else if ([self.selectedPayMethod.payKey  isEqualToString:PAY_METHOD_WEIXIN]) {
        [MobClickUtils event:umeng_event_card_recharge_click_pay label:@"微信支付"];
    } else if ([self.selectedPayMethod.payKey  isEqualToString:PAY_METHOD_UNION_CLIENT]) {
        [MobClickUtils event:umeng_event_card_recharge_click_pay label:@"银联支付"];
    }
    
    NSString *userId = [[[UserManager defaultManager] readCurrentUser] userId];
    [SportProgressView showWithStatus:@"正在提交订单"];
    [MembershipCardService addUserCardOrder:self
                                     userId:userId
                                 cardNumber:self.card.cardNumber
                                    goodsId:self.selectedGoods.goodsId
                                     cityId:[CityManager readCurrentCityId]
                                   venuesId:self.card.businessId];
}

- (void)didAddUserCardOrder:(Order *)order
                     status:(NSString *)status
                        msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        self.order = order;
        NSString *userId = [[[UserManager defaultManager] readCurrentUser] userId];
        [PayService payRequest:self
                        userId:userId
                       orderId:order.orderId
                         payId:self.selectedPayMethod.payId
                     useWallet:NO
                      password:nil
                      payToken:nil];
    } else {
        [SportProgressView dismissWithError:msg];
    }
}

- (void)didPayRequest:(NSDictionary *)data status:(NSString *)status msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        
        [SportProgressView dismiss];
        
        if ([self.selectedPayMethod.payKey isEqualToString:PAY_METHOD_ALIPAY_CLIENT]) {
            NSString *paySn = [data validStringValueForKey:@"pay_sn"];
            NSString *notifyUrl = [data validStringValueForKey:@"notify_url"];
            float money = [data validFloatValueForKey:@"money"];
            
            self.order.amount = money;
            self.order.alipayNotifyUrlString = notifyUrl;
            
            [self payWithAlipayClient:money tradeNO:paySn notifyURL:notifyUrl];
                
        } else if ([self.selectedPayMethod.payKey isEqualToString:PAY_METHOD_ALIPAY_WAP]) {
            
            NSString *redirectUrl = [data validStringValueForKey:@"redirect_url"];
            
            [self payWithAlipayWap:redirectUrl];
            
        } else if ([self.selectedPayMethod.payKey isEqualToString:PAY_METHOD_WEIXIN]) {
            
            NSString *openId        = [data validStringValueForKey:@"appid"];
            NSString *partnerId     = [data validStringValueForKey:@"partnerid"];
            NSString *prepayId      = [data validStringValueForKey:@"prepayid"];
            NSString *nonceStr      = [data validStringValueForKey:@"noncestr"];
            NSString *timeStamp     = [data validStringValueForKey:@"timestamp"];
            NSString *package       = [data validStringValueForKey:@"weixinpackage"];
            NSString *sign          = [data validStringValueForKey:@"sign"];
            
            [WeChatPayManager payWithOpenID:openId
                                  partnerId:partnerId
                                   prepayId:prepayId
                                   nonceStr:nonceStr
                                  timeStamp:timeStamp
                                    package:package
                                       sign:sign];
            
        }  else if ([self.selectedPayMethod.payKey isEqualToString:PAY_METHOD_UNION_CLIENT]) {
            
            NSString *tn = [data validStringValueForKey:@"tn"];
            NSString *mode = [data validStringValueForKey:@"mode"];
            
            BOOL result = [UnionPayManager startPay:tn mode:mode viewController:self delegate:self];
            if (result == NO) {
                [SportPopupView popupWithMessage:@"调用银联失败"];
            }
        }
        
    } else {
        [SportProgressView dismissWithError:msg];
    }
}


- (void)payWithAlipayClient:(double)payAmount
                    tradeNO:(NSString *)tradeNO
                  notifyURL:(NSString *)notifyURL
{
    AliPayOrder *aliPayOrder = [[AliPayOrder alloc] init];
    aliPayOrder.partner = ALIPAY_PARTNER;
    aliPayOrder.seller = ALIPAY_SELLER;
    aliPayOrder.tradeNO =  tradeNO;                         //要唯一
    aliPayOrder.productName = @"趣运动-会员充值费用";          //商品标题
    aliPayOrder.productDescription = @"充值";               //商品描述
    aliPayOrder.amount = [NSString stringWithFormat:@"%.2f", payAmount]; //商品价格
    aliPayOrder.notifyURL = notifyURL;        //回调URL
    aliPayOrder.itBPay = @"12m";
    
    [AliPayManager payWithOrder:aliPayOrder
                      appScheme:ALIPAY_CALL_BACK_SCHEME
                  rsaPrivateKey:ALIPAY_RSA_PRIVATE_KEY];
}

- (void)payWithAlipayWap:(NSString *)urlString
{
    HDLog(@"urlString:%@", urlString);
    WebPayController *controller = [[WebPayController alloc] initWithUrlString:urlString title:@"支付"] ;
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)handleAlipayCallBack:(NSNotification *)note
{
    HDLog(@"receive message: %@", NOTIFICATION_ALIPAY_PAY_CALLBACK);
    NSDictionary *userInfo = note.userInfo;
    NSString *resultCode = [userInfo objectForKey:@"result_code"];
    NSString *resultMessage = [userInfo objectForKey:@"result_message"];
    
    NSInteger resultCodeInt = [resultCode integerValue];
    
    if (resultCodeInt == 9000) {
        self.localPaySuccess = YES;
        [SportProgressView showWithStatus:@"支付成功，正在刷新订单" hasMask:YES];
        [self queryOrderData];
    }else{
        if (resultCodeInt == 6001) { //取消支付
            [MobClickUtils event:umeng_event_card_recharge_pay_cancel label:@"支付宝客户端支付"];
        } else {
            [MobClickUtils event:umeng_event_card_recharge_pay_failure label:@"支付宝客户端支付"];
        }
        
        NSString *message = [NSString stringWithFormat:@"支付失败:%@", resultMessage];
        [SportPopupView popupWithMessage:message];
    }
}

- (void)handleWeChatCallBack:(NSNotification *)note
{
    HDLog(@"handleWeChatCallBack");
    NSDictionary *userInfo = note.userInfo;
    int errorCode = [[userInfo valueForKey:@"error_code"] intValue];
    NSString *errorMessage = [userInfo valueForKey:@"error_message"];
    
    if (errorCode == 0) {
        self.localPaySuccess = YES;
        [SportProgressView showWithStatus:@"支付成功，正在刷新订单" hasMask:YES];
        [self queryOrderData];
    } else {
        if (errorMessage) {
            [SportPopupView popupWithMessage:errorMessage];
        } else {
            if (errorCode == -2) {
                [MobClickUtils event:umeng_event_card_recharge_pay_cancel label:@"微信支付"];
                [SportPopupView popupWithMessage:@"取消支付"];
            } else {
                [MobClickUtils event:umeng_event_card_recharge_pay_failure label:@"微信支付"];
                [SportPopupView popupWithMessage:@"支付失败"];
            }
        }
    }
}

- (void)didClickWebPayControllerBackButton:(BOOL)isFinishPay
{
    self.localPaySuccess = isFinishPay;
    [SportProgressView showWithStatus:@"正在刷新订单" hasMask:YES];
    sleep(1);
    [self queryOrderData];
}

-(void)UPPayPluginResult:(NSString*)result
{
    if ([result isEqualToString:@"success"]) {
        self.localPaySuccess = YES;
        [SportProgressView showWithStatus:@"支付成功，正在刷新订单" hasMask:YES];
        [self queryOrderData];
    } else {
        [SportPopupView popupWithMessage:@"支付失败"];
    }
}


- (void)queryOrderData
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    [OrderService queryOrderDetail:self
                           orderId:_order.orderId
                            userId:user.userId
                           isShare:@"0"
                        entrance:0];
}

- (void)didQueryOrderDetail:(NSString *)status msg:(NSString *)msg resultOrder:(Order *)resultOrder
{
    [SportProgressView dismiss];
    if ([status isEqualToString:STATUS_SUCCESS]) {
        
        self.order = resultOrder;
        if (_order.status == OrderStatusPaid) {
            
            [MobClickUtils event:umeng_event_card_recharge_success];
            
            self.unpayHolderView.hidden = YES;
            self.timeDelayHolderView.hidden = YES;
            self.rechargeSuccessHolderView.hidden = NO;
            
            self.cardAmountLabel.hidden = YES;
            NSString *userId = [[[UserManager defaultManager] readCurrentUser] userId];
            [MembershipCardService getCardDetail:self
                                      cardNumber:self.card.cardNumber
                                          userId:userId
                                           phone:self.card.phone
                                      businessId:self.card.businessId];
        } else {
            
            if (_localPaySuccess) {
                self.unpayHolderView.hidden = YES;
                self.timeDelayHolderView.hidden = NO;
                [self updateTimeDelay];
            } else {
                self.unpayHolderView.hidden = NO;
                self.timeDelayHolderView.hidden = YES;
            }
            self.rechargeSuccessHolderView.hidden = YES;
        }
        
    } else {
        
        [SportProgressView dismiss];
        
        if (_localPaySuccess) {
            self.unpayHolderView.hidden = YES;
            self.timeDelayHolderView.hidden = NO;
            [self updateTimeDelay];
            self.rechargeSuccessHolderView.hidden = YES;
        }
    }
}

- (void)updateTimeDelay
{
    self.timeDelayAmountLabel.text = [PriceUtil toPriceStringWithYuan:self.selectedGoods.amount];
    self.timeDelayCardNumberLabel.text = self.card.cardNumber;
}

- (void)didGetCardDetail:(MembershipCard *)card status:(NSString *)status msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        self.cardAmountLabel.hidden = NO;
        self.card = card;
        self.cardAmountLabel.text = [PriceUtil toPriceStringWithYuan:card.money];
    } else {
        self.cardAmountLabel.hidden = YES;
    }
}

- (IBAction)clickBookButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickRechargeControllerBookButton)]) {
        [_delegate didClickRechargeControllerBookButton];
    }
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)clickRefreshButton:(id)sender {
    [SportProgressView showWithStatus:@"正在刷新订单" hasMask:YES];
    [self queryOrderData];
}

- (IBAction)clickPhoneButton:(id)sender {
    BOOL result = [UIUtils makePromptCall:@"4000410480"];
    if (result == NO) {
        [SportPopupView popupWithMessage:@"此设备不支持打电话"];
    }
}

@end
