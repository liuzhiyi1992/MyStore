//
//  BusinessOrderConfirmController.m
//  Sport
//
//  Created by 江彦聪 on 16/8/3.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "BusinessOrderConfirmController.h"
#import "Order.h"
#import "UIView+Utils.h"
#import "User.h"
#import "UserManager.h"
#import "Product.h"
#import "SportProgressView.h"
#import "ProductDetailGroupView.h"
#import "PayController.h"
#import "PriceUtil.h"
#import "RegisterController.h"
#import "FavourableActivity.h"
#import "Voucher.h"
#import "DateUtil.h"
#import "CityManager.h"
#import "BaseConfigManager.h"
#import "MembershipCard.h"
#import "AppGlobalDataManager.h"
#import "Insurance.h"
#import "SportPopupView.h"
#import "LayoutConstraintUtil.h"
#import "BusinessService.h"
#import "BusinessGoods.h"
#import "BusinessOrderConfirmBottomView.h"

@interface BusinessOrderConfirmController()<BusinessOrderConfirmBottomViewDelegate>
@property (strong, nonatomic) Order *order;
//@property (strong, nonatomic) OrderConfirmPriceView *orderConfirmPriceView;
@property (strong, nonatomic) Voucher *selectedVoucher;
@property (copy, nonatomic) NSString *selectedActivityId;
@property (copy, nonatomic) NSString *activityMessage;
@property (assign, nonatomic) float userMoney;
@property (assign, nonatomic) float selectedUserMoney;
@property (assign, nonatomic) ConfirmPayType selectedConfirmPayType;
@property (assign, nonatomic) BOOL isCardUser;
@property (copy, nonatomic) NSString *refundMessage;
@property (strong, nonatomic) NSArray *cardList;
@property (copy, nonatomic) NSString *selectedCardNumber;
@property (assign, nonatomic) FromController from;
@property (strong, nonatomic) Insurance *insurance;
@property (assign, nonatomic) BOOL isIncludeInsurance;
@property (copy, nonatomic) NSString *insuranceTips;
@property (assign, nonatomic) int insuranceNumber;
@property (copy, nonatomic) NSString *insuranceUrl;
@property (assign, nonatomic) int instranceOrderTime;
@property (copy,nonatomic) NSString *insuranceLimitTips;
@property (strong, nonatomic) ConfirmOrder *confirmOrder;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmPayTypeHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *priceHolderViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *priceHolderViewTopMargin;
@property (strong, nonatomic) NSArray *goodsList;
@property (strong, nonatomic) NSMutableArray *courtDetailArray;
@property (strong, nonatomic) BusinessOrderConfirmBottomView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *bottomHolderView;

@end

@implementation BusinessOrderConfirmController

- (void) dealloc {
    [self.orderConfirmPriceView removeObserver:self forKeyPath:NSStringFromSelector(@selector(needPayPriceString))];
}

- (id)initWithOrderFromQuickBooking:(Order *)order
{
    self = [self initWithOrder:order];
    self.from = FromControllerHome;
    return self;
}

- (id)initWithOrder:(Order *)order
{
    self = [super init];
    if (self) {
        self.order = order;
        self.from = FromControllerOther;
    }
    return self;
}

//#define TAG_LINE                    100
//#define TAG_LINE_VERTICAL           101
//- (void)updateLineImageView:(UIView *)view
//{
//    if ([view isKindOfClass:[UIImageView class]]) {
//        if (view.tag == TAG_LINE) {
//            [(UIImageView *)view setImage:[SportImage lineImage]];
//        } else if (view.tag == TAG_LINE_VERTICAL) {
//            [(UIImageView *)view setImage:[SportImage lineVerticalImage]];
//        }
//    }
//}
//
//
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = DDTF(@"kOrderConfirm");
    
    self.priceHolderView.hidden = YES;

    self.selectedConfirmPayType = ConfirmPayTypeNone;
    //    [self.submitButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateNormal];
    
    [SportProgressView showWithStatus:@"加载中..."];
    User *user  = [[UserManager defaultManager] readCurrentUser];
    
    [OrderService confirmOrder:self
                        userId:user.userId
                   goodsIdList:[self getGoodsIds]
                     orderType:OrderTypeDefault
                         count:1];
    
    [MobClickUtils event:umeng_event_show_order_confirm];
    
    if ([AppGlobalDataManager defaultManager].isShowQuickBook) {
        if (self.from == FromControllerHome) {
            [MobClickUtils event:umeng_event_show_order_confirm_from_quick_booking label:@"从一键订场到订单确认"];
        } else {
            [MobClickUtils event:umeng_event_show_order_confirm_from_quick_booking label:@"从其他到订单确认"];
        }
    }
}

-(void) didConfirmOrder:(NSString *)status msg:(NSString *)msg confirmOrder:(ConfirmOrder *)confirmOrder {
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismiss];
        self.confirmOrder = confirmOrder;
        _order.type = OrderTypeDefault;
        _order.totalAmount = confirmOrder.totalAmount;
        _order.promoteAmount = confirmOrder.promoteAmount;
        _order.amount = confirmOrder.payAmount;
        _order.favourableActivityList = confirmOrder.activityList;
        _order.canRefund = confirmOrder.canRefund;
        
        self.selectedActivityId = confirmOrder.selectedActivityId;
        self.userMoney = confirmOrder.userMoney;
        self.activityMessage = confirmOrder.activityMessage;
        //支持使用会员卡且是会员卡会员的时候，才显示
        self.isCardUser = confirmOrder.isCardUser && confirmOrder.isSupportMembershipCard;
        self.refundMessage = confirmOrder.refundMessage;
        self.cardList = confirmOrder.cardList;
        if ([self.cardList count] > 0) {
            self.selectedCardNumber = [(MembershipCard *)confirmOrder.cardList[0] cardNumber];
        }
        
        if (self.isCardUser) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *lastConfirmPay = [defaults valueForKey:KEY_LAST_CONFIRM_PAY];
            
            // v1.97 默认不选中支付方式，如首次选择，不显示价钱
            if (lastConfirmPay != nil) {
                self.selectedConfirmPayType = [lastConfirmPay intValue];
            } else {
                self.selectedConfirmPayType = ConfirmPayTypeNone;
            }
            //            if (lastConfirmPay == nil) {
            //                self.selectedConfirmPayType = ConfirmPayTypeOnline;
            //            } else {
            //                self.selectedConfirmPayType = [lastConfirmPay intValue];
            //            }
        } else {
            self.selectedConfirmPayType = ConfirmPayTypeOnline;
        }
        
        self.isIncludeInsurance = confirmOrder.isIncludeInsurance;
        if (confirmOrder.insuranceList.count > 0) {
            self.insurance = confirmOrder.insuranceList[0];
        }
        
        self.insuranceTips = confirmOrder.insuranceTips;
        self.insuranceUrl = confirmOrder.insuranceUrl;
        self.instranceOrderTime = confirmOrder.insuranceOrderTime;
        self.insuranceLimitTips = confirmOrder.insuranceLimitTips;
        [self.confirmPayTypeTableView reloadData];
        
        self.priceHolderView.hidden = NO;
        
        [self updateDataViews];
    } else {

        [SportProgressView dismissWithError:msg];
        
    }
    
    //无数据时的提示
    if ([status isEqualToString:STATUS_SUCCESS] == NO) {
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44);
        [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"请返回重试"];
    } else {
        [self removeNoDataView];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updatePhone];
}

- (void)updatePhone
{
    User *user  = [[UserManager defaultManager] readCurrentUser];
    if ([user.phoneNumber length] > 0) {
        self.phoneLabel.text = user.phoneNumber;
    } else {
        self.phoneLabel.text = @"您未绑定手机号码";
    }
}

#define SPACE   10
#define TEXT_SPACE 8
#define TAG_PRODUCT_DETAIL_GROUP_VIEW   2015042001
- (void)updateDataViews
{
    CGFloat y = 0;
    
    //设置订单信息
    self.categoryLabel.text = _order.categoryName;
    self.businessNameLabel.text = _order.businessName;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    if (_order.useDate) {
        NSString *dateString = [dateFormatter stringFromDate:_order.useDate];
        NSString *weekString = [DateUtil ChineseWeek2:_order.useDate];
        self.useDateLabel.text = [NSString stringWithFormat:@"%@ (%@)", dateString,weekString];
    }
    
    self.courtDetailArray = [NSMutableArray array];
    NSMutableString *courtTimeStr = [NSMutableString string];
    int index = 0;
    for (Product *product in self.order.productList) {
        NSString *oneCourtTimeStr = [NSString stringWithFormat:@"%@ %@", product.courtName, [product startTimeToEndTime]];
        [courtTimeStr appendString:oneCourtTimeStr];
        if (index < [self.order.productList count] - 1) {
            [courtTimeStr appendString:@"\n"];
        }
        
        [self.courtDetailArray addObject:@[oneCourtTimeStr,[PriceUtil toPriceStringWithYuan:product.price]]];
        
        index++;
    }
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:courtTimeStr];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:TEXT_SPACE];
    [attributeString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, courtTimeStr.length)];

    self.courtDetailLabel.attributedText = attributeString;
    
    //如果是会员，则显示下订方式
    if (self.isCardUser) {
        self.confirmPayTypeHolderView.hidden = NO;
//        [self.confirmPayTypeHolderView updateOriginY:y];
        if(_selectedConfirmPayType == ConfirmPayTypeMembershipCard) {
            self.confirmPayTypeHeight.constant = [ConfirmPayTypeCell getCellHeight]*2 + [ConfirmPayTypeCell getCellHeight] * [self.cardList count];
        } else {
            self.confirmPayTypeHeight.constant = [ConfirmPayTypeCell getCellHeight]*2;
        }
        
        y = y + _confirmPayTypeHolderView.frame.size.height + SPACE;
        
        self.priceHolderViewTopMargin.constant = SPACE;
    } else {
        self.priceHolderViewTopMargin.constant = 0;
        self.confirmPayTypeHeight.constant = 0;
        self.confirmPayTypeHolderView.hidden = YES;
    }
    
    //设置价格信息
    // v1.97 由于需要同步获取价钱更新，将orderConfirmPriceView的初始化提前
    if (_orderConfirmPriceView == nil) {
        self.orderConfirmPriceView = [OrderConfirmPriceView createOrderConfirmPriceView];
        _orderConfirmPriceView.delegate = self;
        [self registerControllerAsObserver];
    } else {
        [_orderConfirmPriceView removeFromSuperview];
    }
    
    //这里需要接收needPayPriceString的更改
    if (self.bottomView == nil) {
        self.bottomView = [BusinessOrderConfirmBottomView createBusinessOrderConfirmBottomView];
        self.bottomView.delegate = self;
        [LayoutConstraintUtil view:self.bottomView addConstraintsWithSuperView:self.bottomHolderView];
    }
    
    [self updatePriceInfo];
    
    //选择了会员卡
    if (self.isCardUser == YES && self.selectedConfirmPayType != ConfirmPayTypeOnline) {
        self.priceHolderView.hidden = YES;
        [self.orderConfirmPriceView isShowGoodsList:NO];
        [self.bottomView isShowPriceDetail:NO];
        
        self.refundButton.enabled = NO;
        [self.refundTipsImageView setImage:[UIImage imageNamed:@"Exclamatory"]];
        self.refundDetailImageView.hidden = YES;
        self.refundTipsLabel.text = @"退订规则请以场馆说明为准";
    } else {
        //选择第三方支付
        self.priceHolderView.hidden = NO;
        
        [self.orderConfirmPriceView isShowGoodsList:YES];
        [self.bottomView isShowPriceDetail:YES];
        [self.priceHolderView updateOriginY:y];
        [LayoutConstraintUtil view:_orderConfirmPriceView addConstraintsWithSuperView:self.priceHolderView];
        
        if (_order.canRefund) {
            self.refundButton.enabled = YES;
            [self.refundTipsImageView setImage:[UIImage imageNamed:@"RefundImage"]];
            self.refundDetailImageView.hidden = NO;
            if ([self.refundMessage length] != 0) {
                self.refundTipsLabel.text = self.refundMessage;
            } else {
                self.refundTipsLabel.text = @"提前24小时可退";
            }
        } else {
            self.refundButton.enabled = NO;
            [self.refundTipsImageView setImage:[UIImage imageNamed:@"canNotRefund"]];
            self.refundDetailImageView.hidden = YES;
            if ([self.refundMessage length] != 0) {
                self.refundTipsLabel.text = self.refundMessage;
            } else {
                self.refundTipsLabel.text = @"暂不支持退换";
            }
        }
    }
    
    NSDictionary *dic = @{NSFontAttributeName : self.refundTipsLabel.font};
    CGSize size = [self.refundTipsLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, self.refundTipsLabel.frame.size.height) options:NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    [self.refundDetailImageView updateOriginX:self.refundTipsLabel.frame.origin.x + size.width + 10];
}


- (void)registerControllerAsObserver {
    [self.orderConfirmPriceView addObserver:self
                                 forKeyPath:NSStringFromSelector(@selector(needPayPriceString))
                                    options:(NSKeyValueObservingOptionNew |
                                             NSKeyValueObservingOptionOld)
                                    context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([object isKindOfClass:[OrderConfirmPriceView class]]) {
        
        if ([keyPath isEqual:NSStringFromSelector(@selector(needPayPriceString))]) {
            self.bottomView.needPayPriceLabel.text = self.orderConfirmPriceView.needPayPriceString;
            [self.confirmPayTypeTableView reloadData];
        }
    }
}

- (IBAction)clickRefundButton:(UIButton *)sender {
    [MobClickUtils event:umeng_event_click_order_comfirm_refund_explame];
    SportWebController *controller = [[SportWebController alloc] initWithUrlString:[[BaseConfigManager defaultManager] refundRuleUrl] title:@"退款规则"] ;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [ConfirmPayTypeCell getCellIdentifier];
    ConfirmPayTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [ConfirmPayTypeCell createCell];
    }
    
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        cell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
    
    BOOL isSelected = NO;
    if (indexPath.row == 0) {
        isSelected = (_selectedConfirmPayType == ConfirmPayTypeMembershipCard);
        //默认不展开，所以cardList传空
        NSArray *cardList = (_selectedConfirmPayType == ConfirmPayTypeMembershipCard?self.cardList:nil);
        [cell updateCellWithType:ConfirmPayTypeMembershipCard isSelected:isSelected subTitle:@"(到场凭卡消费，无需预付)" indexPath:indexPath isLast:NO cardList:cardList];
        cell.delegate = self;
    } else {
        isSelected = (_selectedConfirmPayType == ConfirmPayTypeOnline);
        [cell updateCellWithType:ConfirmPayTypeOnline isSelected:isSelected subTitle:[NSString stringWithFormat:@"(预订费用%@)",_orderConfirmPriceView.needPayPriceString] indexPath:indexPath isLast:YES];
    }
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && _selectedConfirmPayType == ConfirmPayTypeMembershipCard) {
        return [ConfirmPayTypeCell getCellHeight] + [ConfirmPayTypeCell getCellHeight] * [self.cardList count];
    } else {
        return [ConfirmPayTypeCell getCellHeight];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.confirmPayTypeTableView) {
        if (indexPath.row == 0) {
            self.selectedConfirmPayType = ConfirmPayTypeMembershipCard;
            [MobClickUtils event:umeng_event_confirm_order_click_pay_type label:@"场馆会员卡支付"];
        } else {
            self.selectedConfirmPayType = ConfirmPayTypeOnline;
            [MobClickUtils event:umeng_event_confirm_order_click_pay_type label:@"在线支付"];
        }
        
        [tableView reloadData];
        
        [self updateDataViews];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)updatePriceInfo
{
    [_orderConfirmPriceView updateViewWithOrder:_order
                                   confirmOrder:self.confirmOrder
                       canUseActivityAndVoucher:YES
                                        voucher:_selectedVoucher
                                     controller:self
                                       goodsIds:[self getGoodsIds]];
    
    
}


#pragma mark - OrderConfirmPriceViewDelegate
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

- (void)didSelectUserMoney:(float)selectUserMoney
{
    self.selectedUserMoney = selectUserMoney;
}

- (void)didChangeInsurance {
    [self updateDataViews];
}

-(void)didClickInsuranceUrl {
    SportWebController *controller = [[SportWebController alloc]initWithUrlString:self.insuranceUrl title:@"投保规则页"];
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)didSelectGoodsList:(NSArray *)goodsList {
    self.goodsList = goodsList;
}

-(NSArray *) selectedGoodsList {
    
    NSMutableArray *selectedGoodsList = [NSMutableArray array];
    for (BusinessGoods *goods in self.goodsList) {
        if (goods.totalCount > 0) {
            [selectedGoodsList addObject:goods];
        }
    }
    
    return selectedGoodsList;
}

- (NSString *)getGoodsIds
{
    NSMutableString *goodsIds = [NSMutableString string];
    int index = 0;
    for (Product *product in _order.productList) {
        if (index > 0) {
            [goodsIds appendString:@","];
        }
        if (product.productId) {
            [goodsIds appendString:product.productId];
        }
        index ++;
    }
    return goodsIds;
}
//
#define TAG_ALERTVIEW_BIND_PHONE    2015020201
#define TAG_ALERTVIEW_SOLD          2015020202
#define TAG_USER_CARD_INVALID       2015111101
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_ALERTVIEW_BIND_PHONE) {
        RegisterController *controller = [[RegisterController alloc] initWithVerifyPhoneType:VerifyPhoneTypeBind] ;
        [self.navigationController pushViewController:controller animated:YES];
    } else if (alertView.tag == TAG_USER_CARD_INVALID) {
        //什么都不做
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - OrderServiceDelegate
- (void)didSubmitOrder:(NSString *)status
           resultOrder:(Order *)resultOrder
                   msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismiss];
        
        for (Product *product in _order.productList) {
            product.status = ProductStatusOrdered;
        }
        
        self.order = resultOrder;
        
        PayController *controller = [[PayController alloc] initWithOrder:_order];
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        if ([status isEqualToString:STATUS_SOLD]) {
            [SportProgressView dismiss];
            
            NSString *message = msg;
            if (message == nil) {
                message = @"场地已出售,请返回刷新重新选择!";
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"确定", nil];
            alertView.tag = TAG_ALERTVIEW_SOLD;
            [alertView show];
            return;
        } else if ([status isEqualToString:STATUS_USER_CARD_INVALID]) {
            [SportProgressView dismiss];
            NSString *message = msg;
            if (message == nil) {
                message = @"会员卡出错!";
            }
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"确定", nil];
            alertView.tag = TAG_USER_CARD_INVALID;
            [alertView show];
            
            return;
        } else if ([status isEqualToString:STATUS_INSURANCE_ERROR]) {
            [SportProgressView dismissWithError:msg];
            [self.orderConfirmPriceView updateInsuranceSwitchWithAction:NO];
            return;
        }
        
        if (msg) {
            [SportProgressView dismissWithError:msg afterDelay:2];
        } else {
            [SportProgressView dismissWithError:@"网络错误，请重试"];
        }
    }
}

- (NSString *)getSelectedMembershipCardNumber {
    return self.selectedCardNumber;
}

- (void)setSelectedMembershipCardNumber:(NSString *)cardNumber{
    self.selectedCardNumber = cardNumber;
}

#pragma mark -BusinessOrderConfirmBottomViewDelegate
-(void) prepareForPriceDetailView:(NSMutableArray *)priceDetailArray {
     [priceDetailArray addObjectsFromArray:self.courtDetailArray];
    
    if (self.selectedActivityId) {
        FavourableActivity *selectedActivity = [self.order selectedActivity:self.selectedActivityId];
        NSString *activityAmountString = [PriceUtil toPriceStringWithYuan:selectedActivity.activityPrice];
        [priceDetailArray addObject:@[selectedActivity.activityName,[NSString stringWithFormat:@"-%@",activityAmountString]]];
        
        
    } else if (self.selectedVoucher) {
        NSString *voucherAmountString = [PriceUtil toPriceStringWithYuan:self.selectedVoucher.amount];
        [priceDetailArray addObject:@[@"卡券",[NSString stringWithFormat:@"-%@",voucherAmountString]]];
    }
    
    NSArray *selectedGoodsList = [self selectedGoodsList];
    for (BusinessGoods *goods in selectedGoodsList) {
        NSString *oneGoodsPrice = [PriceUtil toPriceStringWithYuan:goods.price];
        [priceDetailArray addObject:@[goods.name,goods.totalCount > 1?[NSString stringWithFormat:@"%@×%d",oneGoodsPrice,goods.totalCount]:oneGoodsPrice]];
    }

}

-(void) didClickSubmitButton {
    NSString *goodsIds = [self getGoodsIds];
    
    User *user  = [[UserManager defaultManager] readCurrentUser];
    
    if ([user.phoneNumber length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"为了你的账号安全，请绑定手机号码再提交订单" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        alertView.tag = TAG_ALERTVIEW_BIND_PHONE;
        [alertView show];
        return;
    }
    
    NSString *inviteCode = nil;
    if (_selectedActivityId) {
        for (FavourableActivity *activity in self.order.favourableActivityList) {
            if ([_selectedActivityId isEqualToString:activity.activityId]) {
                inviteCode = activity.activityInviteCode;
                break;
            }
        }
    }
    
    if (self.isCardUser && self.selectedConfirmPayType == ConfirmPayTypeNone) {
        [SportPopupView popupWithMessage:@"请先选择支付方式"];
        return;
    }
    
    int type = (self.isCardUser && self.selectedConfirmPayType == ConfirmPayTypeMembershipCard ? OrderTypeMembershipCard : OrderTypeDefault);
    
    //选择第三方支付的时候不传会员卡号
    NSString *carNumber;
    if (type == OrderTypeMembershipCard) {
        [MobClickUtils event:umeng_event_click_submit_order_button label:@"会员卡订场"];
        [MobClickUtils event:umeng_event_confirm_pay_way label:@"场馆会员卡支付"];
        carNumber = self.selectedCardNumber;
        
    } else if (type == OrderTypeDefault) {
        [MobClickUtils event:umeng_event_click_submit_order_button label:@"场次订单"];
        [MobClickUtils event:umeng_event_confirm_pay_way label:@"在线支付"];
    }
    
    if ([AppGlobalDataManager defaultManager].isShowQuickBook) {
        if (self.from == FromControllerHome) {
            [MobClickUtils event:umeng_event_click_order_submit_from_quick_booking label:@"从一键订场到点击提交订单"];
        } else {
            [MobClickUtils event:umeng_event_click_order_submit_from_quick_booking label:@"从其他到点击提交订单"];
        }
    }
    
    // v1.97 当提交订单时才记住支付方式
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:@(self.selectedConfirmPayType) forKey:KEY_LAST_CONFIRM_PAY];
        [defaults synchronize];
    });
    
    [SportProgressView showWithStatus:@"提交订单中..." hasMask:YES];
    NSString *insuranceId =self.orderConfirmPriceView.isEnableInsurance?self.insurance.insuranceId:nil;
    
    NSMutableString *saleList = [NSMutableString string];
    NSArray *selectedGoodsList = [self selectedGoodsList];
    for (BusinessGoods *goods in selectedGoodsList) {
        NSString *one = [NSString stringWithFormat:@"%@_%d,",goods.goodsId,goods.totalCount];
        [saleList appendString:one];
    }
    
    if ([saleList length]> 0) {
        [saleList deleteCharactersInRange:NSMakeRange([saleList length]-1, 1)];
    }
    
    [OrderService submitOrder:self
                       userId:user.userId
                  goodsIdList:goodsIds
                        count:1
                         type:type
                   activityId:_selectedActivityId
                   inviteCode:inviteCode
                    voucherId:_selectedVoucher.voucherId
                  voucherType:_selectedVoucher.type
                        phone:user.phoneEncode
                    isClubPay:NO
                       cityId:[CityManager readCurrentCityId]
                   cardNumber:carNumber
                  insuranceId:insuranceId
            insuranceQuantity:self.orderConfirmPriceView.isEnableInsurance?self.orderConfirmPriceView.insuranceNumber:0
                     saleList:saleList];
}


@end
