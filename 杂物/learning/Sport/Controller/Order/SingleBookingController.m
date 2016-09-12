//
//  SingleBookingController.m
//  Sport
//
//  Created by haodong  on 13-12-19.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SingleBookingController.h"
#import "Business.h"
#import "Goods.h"
#import "UIView+Utils.h"
#import "PayController.h"
#import "UserManager.h"
#import "SportProgressView.h"
#import "PriceUtil.h"
#import "LoginController.h"
#import "TipNumberManager.h"
#import "OrderListController.h"
#import "OrderManager.h"
#import "PriceUtil.h"
#import "RegisterController.h"
#import "Voucher.h"
#import "FavourableActivity.h"
#import "ActClubIntroduceController.h"
#import "MonthCardCourse.h"
#import "DateUtil.h"
#import "ConfirmPayTypeCell.h"
#import "CityManager.h"
#import "SportPlusMinusView.h"
#import "LayoutConstraintUtil.h"
#import "BusinessOrderConfirmBottomView.h"

@interface SingleBookingController ()<LoginDelegate,SportPlusMinusViewDelegate,BusinessOrderConfirmBottomViewDelegate>
@property (copy ,nonatomic) NSString *businessName;
@property (assign, nonatomic) int count;
@property (strong, nonatomic) Goods *goods;
@property (strong, nonatomic) MonthCardCourse *course;
@property (assign, nonatomic) BOOL isSpecialSale;
@property (strong, nonatomic) Order *needPayOrder;

@property (strong, nonatomic) Voucher *selectedVoucher;
@property (copy, nonatomic) NSString *selectedActivityId;
@property (strong, nonatomic) NSArray *activityList;
@property (copy, nonatomic) NSString *activityMessage;

@property (assign, nonatomic) float onePrice;
@property (assign, nonatomic) BOOL canRefund;

@property (assign, nonatomic) BOOL isSupportClub;
@property (assign, nonatomic) ClubStatus userClubStatus;
@property (retain, nonatomic) NSString *clubDisableMsg;
@property (retain, nonatomic) NSString *noBuyClubMsg;
@property (retain, nonatomic) NSString *noUsedClubOrderMsg;
@property (assign, nonatomic) BOOL isClubPay;
@property (assign, nonatomic) BOOL isNoUsedClubOrder;
@property (assign, nonatomic) BOOL isRefreshSelection;
@property (strong, nonatomic) BusinessOrderConfirmBottomView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *bottomHolderView;
//@property (assign, nonatomic) float userMoney;
//@property (assign, nonatomic) float selectedUserMoney;

@property (strong, nonatomic) InputGoodsCountView *inputGoodsCountView;
@property (weak, nonatomic) IBOutlet UILabel *packageTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailTimeLabel;
@property (assign, nonatomic) ConfirmPayType selectedConfirmPayType;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *courseViewHeight;
@property (weak, nonatomic) IBOutlet UIView *plusMinusHolderView;
@property (strong, nonatomic) SportPlusMinusView *plusMinusView;
@property (strong, nonatomic) ConfirmOrder *confirmOrder;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingAnimator;
@end

@implementation SingleBookingController

- (void) dealloc {
    [self.orderConfirmPriceView removeObserver:self forKeyPath:NSStringFromSelector(@selector(needPayPriceString))];
}

- (instancetype)initWithCourse:(MonthCardCourse *)course
{
    // 为了重用原来人次结构，若为课程都构造goods
    Goods *goods = [[Goods alloc]init];
    goods.name = course.courseName;
    goods.goodsId = course.courseId;
    goods.totalCount = 999;
    goods.limitCount = 999;
    self = [self initWithGoods:goods businessName:course.venuesName isSpecialSale:NO];
    
    if (self) {
        self.course = course;
    }

    return self;
}


- (instancetype)initWithGoods:(Goods *)goods
                 businessName:(NSString *)businessName
                isSpecialSale:(BOOL)isSpecialSale
{
     self = [super init];
     if (self) {
         self.goods = goods;
         self.businessName = businessName;
         self.isSpecialSale = isSpecialSale;
         
         self.isRefreshSelection = YES;
     }
    
     return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"订单确认";
    
    [self createRightTopButton:@"订单"];
    
    self.count = 1;
    
    self.topHolderView.hidden = YES;
    self.priceHolderView.hidden = YES;
    self.refundTipsHolderView.hidden = YES;

    self.isNoUsedClubOrder = NO;
    
    if (_isSpecialSale) {
        [MobClickUtils event:umeng_event_enter_promotion_order_confirm];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [SportProgressView showWithStatus:DDTF(@"加载中...") hasMask:YES];
    
    //购买完动Club之后，需要重新刷新页面
    [self queryConfirmOrderData];
    [self queryNeedPay];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updatePhone];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)queryConfirmOrderData
{
    [self.loadingAnimator startAnimating];
    User *user = [[UserManager defaultManager] readCurrentUser];
    NSString *goodsId = (_goods != nil)?_goods.goodsId:_course.courseId;
    int orderType;
    if (self.course) {
        orderType = OrderTypeCourse;
    } else {
        orderType = (_isSpecialSale ? OrderTypePackage : OrderTypeSingle);
    }
    
    [OrderService confirmOrder:self
                        userId:user.userId
                   goodsIdList:goodsId
                     orderType:orderType
                         count:_count];
}

-(void) didConfirmOrder:(NSString *)status msg:(NSString *)msg confirmOrder:(ConfirmOrder *)confirmOrder {
    [self.loadingAnimator stopAnimating];

    if ([status isEqualToString:STATUS_SUCCESS]) {
        self.confirmOrder = confirmOrder;
        [SportProgressView dismiss];
        
        self.activityList = confirmOrder.activityList;
        
        if (_selectedActivityId) {//如果用户之前选择过活动
            BOOL isValid = NO;
            for (FavourableActivity *activity in confirmOrder.activityList) {
                if ([_selectedActivityId isEqualToString:activity.activityId] && activity.activityStatus == FavourableActivityStatusAvailable) {
                    isValid = YES;
                    break;
                }
            }
            if (isValid == NO) {//如果之前选择的活动不可用，则用新默认的活动
                self.selectedActivityId = confirmOrder.selectedActivityId;
            }
        } else if (_selectedVoucher) { //如果用户之前选择过代金券
            if (![_selectedVoucher validToUse:confirmOrder.totalAmount]) {
                
                NSString *message = [NSString stringWithFormat:@"此代金劵只适用于支付金额大于%d元的订单", (int)([_selectedVoucher minAmountToUse])];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
                
                
                self.selectedVoucher = nil;
                self.selectedActivityId = confirmOrder.selectedActivityId;
            }
        } else {
            self.selectedActivityId = confirmOrder.selectedActivityId;
        }
        
        self.onePrice = confirmOrder.onePrice;
        
        //self.userMoney = userMoney;
        self.canRefund = confirmOrder.canRefund;
        
//        self.activityMessage = confirmOrder.activityMessage;
        
        self.topHolderView.hidden = NO;
        self.priceHolderView.hidden = NO;
        self.refundTipsHolderView.hidden = NO;
        
//        self.isSupportClub = confirmOrder.isSupportClub;
//        self.userClubStatus = confirmOrder.userClubStatus;
//        self.clubDisableMsg = confirmOrder.clubDisableMsg;
//        self.noBuyClubMsg = confirmOrder.noBuyClubMsg;
//        self.noUsedClubOrderMsg = confirmOrder.noUsedClubOrderMsg;
        
        [self initUI];
        
    } else {
        NSString *message = nil;
        if (msg) {
            message = msg;
        } else {
            message = @"网络错误";
        }
        
        [SportProgressView dismissWithError:message];
        
        self.topHolderView.hidden = YES;
        self.priceHolderView.hidden = YES;
    }
    
    //无数据时的提示
    if ([status isEqualToString:STATUS_SUCCESS] == NO) {
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44);
        [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"请返回重试"];
    } else {
        [self removeNoDataView];
    }


}

- (void)clickRightTopButton:(id)sender
{
    if ([UserManager isLogin]) {
        OrderListController *controller = [[OrderListController alloc] init] ;
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        LoginController *controller = [[LoginController alloc] init] ;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)queryNeedPay
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    if ([user.userId length] > 0) {
        [OrderService queryNeedPayOrderCount:self userId:user.userId];
        [UserService getMessageCountList:nil
                                  userId:user.userId
                                deviceId:[SportUUID uuid]];
    }
}

- (void)didQueryNeedPayOrderCount:(NSString *)status
                            count:(NSUInteger)count
                            order:(Order *)order
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        self.needPayOrder = order;
        
        if (order) {
            [self showRightTopRedPoint];
        } else {
            [self hideRightTopRedPoint];
        }
    }
}

- (void)updatePhone
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    if ([user.phoneNumber length] > 0) {
        self.phoneLabel.text = [NSString stringWithFormat:@"%@", user.phoneNumber];
    } else {
        self.phoneLabel.text = @"您未绑定手机号码";
    }
}

- (void)initUI
{
    self.businessNameLabel.text = _businessName;
    self.packageNameLabel.text = _goods.name;
    
    if (self.course) {
        self.packageTitleLabel.text = @"课程名称：";
        self.amountTimeLabel.text = @"上课时间：";
        self.detailTimeLabel.hidden = NO;
        NSString *startTimeString = [DateUtil stringFromDate:self.course.startTime DateFormat:@"yyyy.MM.dd HH:mm"];
        NSString *endTimeString = [DateUtil stringFromDate:self.course.endTime DateFormat:@"HH:mm"];
        self.detailTimeLabel.text = [NSString stringWithFormat:@"%@-%@",startTimeString,endTimeString];
        
        self.courseViewHeight.constant = 45;
    } else {
        self.packageTitleLabel.text = @"套餐：";
//        self.amountTimeLabel.text = @"数量：";
        self.amountTimeLabel.hidden = YES;
        self.detailTimeLabel.hidden = YES;
        self.courseViewHeight.constant = 0;
    }
    
    //v2.1.0 不显示价钱
//    if (_isSpecialSale) {
//        //Package *package = (Package *)_goods;
//        self.packagePriceLabel.text = [NSString stringWithFormat:@"%@元", [PriceUtil toValidPriceString:_onePrice]];
//    } else {
//        self.packagePriceLabel.text = [NSString stringWithFormat:@"%@元", [PriceUtil toValidPriceString:_onePrice]];
//    }
    
    //如果选择了个数，则认为是人次。重新选择动Club时，需要重置个数
//    if (self.isRefreshSelection && self.isSupportClub) {
//        
//        self.isRefreshSelection = NO;
//        if(self.userClubStatus == CLUB_STATUS_UNPAID || self.userClubStatus == CLUB_STATUS_EXPIRE) {
//            
//            if (self.clubPromoteView.hidden) { //加这个判断为了防止重复统计
//                [MobClickUtils event:umeng_event_show_affirm_order_club_recommend_enter];
//            }
//            
//            self.clubPromoteView.hidden = NO;
//            self.confirmPayTypeTableView.hidden = YES;
//            self.noBuyClubMessageLabel.text = self.noBuyClubMsg;
//        } else {
//            self.clubPromoteView.hidden = YES;
//            
//            self.confirmPayTypeTableView.hidden = NO;
//            if(self.userClubStatus == CLUB_STATUS_PAID_VALID) {
//                self.isClubPay = YES;
//            } else {
//                self.isClubPay = NO;
//            }
//            
//            [self.confirmPayTypeTableView reloadData];
//        }
//        
//        if ([self.noUsedClubOrderMsg length] == 0) {
//            self.isNoUsedClubOrder = NO;
//        } else {
//            self.isNoUsedClubOrder = YES;
//        }
//    }
    
    [self updateSelectionButton];
    
    [self updatePriceHolderView];
    
    [self updateRefundHolderView];
}

- (void)updateRefundHolderView
{
    //设置退款提示
    if (_canRefund || self.selectedConfirmPayType == ConfirmPayTypeClub) {
        [self.refundTipsImageView setImage:[SportImage markButtonImage]];
        self.refundTipsLabel.textColor = [SportColor hex6TextColor];
        self.refundTipsLabel.text = @"随时退换";
    } else {
        [self.refundTipsImageView setImage:[UIImage imageNamed:@"can_not"]];
        self.refundTipsLabel.textColor = [SportColor content2Color];
        self.refundTipsLabel.text = @"暂不支持退换";
    }
}

- (void)updatePriceHolderView
{
    // 要提前初始化才能够显示支付金额
    if (self.bottomView == nil) {
        self.bottomView = [BusinessOrderConfirmBottomView createBusinessOrderConfirmBottomView];
        self.bottomView.delegate = self;
        [LayoutConstraintUtil view:self.bottomView addConstraintsWithSuperView:self.bottomHolderView];
    }
    
    if (_orderConfirmPriceView == nil) {
        self.orderConfirmPriceView = [OrderConfirmPriceView createOrderConfirmPriceView];
        _orderConfirmPriceView.delegate = self;
        [self registerControllerAsObserver];
    } else {
        
        [_orderConfirmPriceView removeFromSuperview];
    }
    
    BOOL canUseActivityAndVoucher = !_isSpecialSale;
    
    int orderType;
    if (self.course) {
        orderType = OrderTypeCourse;
    } else {
        orderType = (_isSpecialSale ? OrderTypePackage : OrderTypeSingle);
    }
    
    NSString *goodsId = (_goods != nil)?_goods.goodsId:_course.courseId;
    [_orderConfirmPriceView updateViewWithAmount:[self totalPrice]
                        canUseActivityAndVoucher:canUseActivityAndVoucher
                              selectedActivityId:_selectedActivityId
                                         voucher:_selectedVoucher
                                      controller:self
                                        goodsIds:goodsId
                                       orderType:orderType
                                    confirmOrder:self.confirmOrder];
    
//    [self.priceHolderView addSubview:_orderConfirmPriceView];
    [LayoutConstraintUtil view:_orderConfirmPriceView addConstraintsWithSuperView:self.priceHolderView];
    [self.priceHolderView bringSubviewToFront:self.loadingAnimator];
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

//- (void)didSelectUserMoney:(float)selectUserMoney
//{
//    self.selectedUserMoney = selectUserMoney;
//}

#define SECTION_SPACE 25

//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//    if ([textField.text intValue] < 1) {
//        _count = 1;
//    } else if ([textField.text intValue] > _goods.limitCount) {
//        _count = 1;
//        
//        NSString *message = [NSString stringWithFormat:@"超过购买数量限制，最多购买%d张", _goods.limitCount];
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
//        [alertView show];
//    }
//    else {
//        _count = [textField.text intValue];
//    }
//    
//    [self updateMinusButtonAndPlusButton];
//    [self updateCoutTextField];
//}

- (float)totalPrice
{
    float price = 0;
    
    price = _onePrice * _count;
    
    return price;
}

#pragma mark - SportPlusMinusDelegate
-(void) updateSelectNumber:(int) number {
    int tempCount = number;
    
    if (tempCount < 1) {
        tempCount = 1;
    }
    else if (number > _goods.limitCount) {
        
        tempCount = _count;
        
        NSString *message = [NSString stringWithFormat:@"超过购买数量限制，最多购买%d张", _goods.limitCount];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alertView show];
    }
    else {
        tempCount = number;
    }
    
    if (_count != tempCount) {
        self.count = tempCount;
        self.isRefreshSelection = NO;
        [self queryConfirmOrderData];
    } else {
        self.count = tempCount;
    }
    
//    [self updateMinusButtonAndPlusButton];
//   [self updateCoutTextField];
}

//- (void)updateCoutTextField
//{
//    int orderType;
//    if (self.course) {
//        orderType = OrderTypeCourse;
//    } else {
//        orderType = (_isSpecialSale ? OrderTypePackage : OrderTypeSingle);
//    }
//    
//    BOOL canUseActivityAndVoucher = !_isSpecialSale;
//    [_orderConfirmPriceView updateViewWithAmount:[self totalPrice]
//                        canUseActivityAndVoucher:canUseActivityAndVoucher
//                              selectedActivityId:_selectedActivityId
//                                         voucher:_selectedVoucher
//                                      controller:self
//                                        goodsIds:_goods.goodsId
//                                       orderType:orderType
//                                    confirmOrder:self.confirmOrder];
//}

//- (void)updateMinusButtonAndPlusButton
//{
//    if (_count <= 1) {
//        self.minusButton.enabled = NO;
//    } else {
//        self.minusButton.enabled = YES;
//    }
//    
//    if (_count >= _goods.limitCount) {
//        self.plusButton.enabled = NO;
//    } else {
//        self.plusButton.enabled = YES;
//    }
//}

//- (IBAction)clickMinusButton:(id)sender {
//    if (_count > 1) {
//        _count --;
//    }
//    
//    [self updateMinusButtonAndPlusButton];
//    
//    [self updateCoutTextField];
//}
//
//- (IBAction)clickPlusButton:(id)sender {
//    if (_count < _goods.limitCount) {
//        _count ++;;
//    }
//    
//    [self updateMinusButtonAndPlusButton];
//    
//    [self updateCoutTextField];
//}

//- (IBAction)clickChangeCountButton:(id)sender {
//    self.inputGoodsCountView = [InputGoodsCountView createInputGoodsCountView];
//    self.inputGoodsCountView.delegate = self;
//    [self.inputGoodsCountView updateViewCount:_count maxCount:_goods.limitCount];
//    [self.inputGoodsCountView show];
//}

//- (void)didClickInputGoodsCountViewOKButton:(int)count
//{
//    int tempCount = count;
//    
//    if (tempCount < 1) {
//        tempCount = 1;
//    }
//    else if (count > _goods.limitCount) {
//        
//        tempCount = _count;
//        
//        NSString *message = [NSString stringWithFormat:@"超过购买数量限制，最多购买%d张", _goods.limitCount];
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
//        [alertView show];
//    }
//    else {
//        tempCount = count;
//    }
//    
//    if (_count != tempCount) {
//         self.count = tempCount;
//        self.isRefreshSelection = NO;
//        [self queryConfirmOrderData];
//    } else {
//        self.count = tempCount;
//    }
//    
//    [self updateMinusButtonAndPlusButton];
//    [self updateCoutTextField];
//}

#define TAG_ALERTVIEW_BIND_PHONE    2014121001
#define TAG_ALERT_VIEW_CANCEL_ORDER 2014121201
#define TAG_ALERT_VIEW_CANCEL_CLUB_ORDER 2015081314
- (void)submitOrder
{
    if (_count > _goods.totalCount) {
        NSString *message = [NSString stringWithFormat:@"无法购买，只剩下%d张", _goods.totalCount];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:DDTF(@"kOK")
                                                  otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    if (_needPayOrder) {
        UnpaidOrderAlertView *alertView = [UnpaidOrderAlertView createUnpaidOrderAlertView];
        alertView.delegate = self;
        [alertView updateViewWithOrder:_needPayOrder];
        [alertView show];
        return;
    }
    
    User *user  = [[UserManager defaultManager] readCurrentUser];
    
    if ([user.phoneNumber length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"为了您的账号安全，请绑定手机号码再提交订单" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        alertView.tag = TAG_ALERTVIEW_BIND_PHONE;
        [alertView show];
        return;
    }
    
    //如果已经有一个动Club订单，提示取消或继续
    if (self.isClubPay == YES && self.isNoUsedClubOrder == YES) {
        NSArray *titleArray = [self.noUsedClubOrderMsg componentsSeparatedByString:@"\n"];
        NSString *mainTitle = titleArray[0];
        NSString *subTitle = @"";
        if ([titleArray count] > 1) {
            subTitle = titleArray[1];
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:mainTitle message:subTitle delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
        alertView.tag = TAG_ALERT_VIEW_CANCEL_CLUB_ORDER;
        
        [alertView show];
        return;
    }
    
    NSString *goodsId = _goods.goodsId;
    [SportProgressView showWithStatus:DDTF(@"kSubmitting") hasMask:YES];
    
    NSString *inviteCode = nil;
    if (_selectedActivityId) {
        for (FavourableActivity *activity in _activityList) {
            if ([_selectedActivityId isEqualToString:activity.activityId]) {
                inviteCode = activity.activityInviteCode;
                break;
            }
        }
    }
    
    int orderType;
    if (self.course) {
        orderType = OrderTypeCourse;
    } else {
        orderType = (_isSpecialSale ? OrderTypePackage : OrderTypeSingle);
    }
    
    if (orderType == OrderTypeCourse) {
        [MobClickUtils event:umeng_event_click_submit_order_button label:@"课程订单"];
    } else if (orderType == OrderTypePackage) {
        [MobClickUtils event:umeng_event_click_submit_order_button label:@"特惠订单"];
    } else if (orderType == OrderTypeSingle) {
        [MobClickUtils event:umeng_event_click_submit_order_button label:@"人次订单"];
    }
    
    [OrderService submitOrder:self
                       userId:user.userId
                  goodsIdList:goodsId
                        count:_count
                         type:orderType
                   activityId:_selectedActivityId
                   inviteCode:inviteCode
                    voucherId:_selectedVoucher.voucherId
                  voucherType:_selectedVoucher.type
                        phone:user.phoneEncode
                    isClubPay:_isClubPay
                       cityId:[CityManager readCurrentCityId]
                   cardNumber:nil
                  insuranceId:nil
            insuranceQuantity:0
                     saleList:nil];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_ALERTVIEW_BIND_PHONE) {
        RegisterController *controller = [[RegisterController alloc] initWithVerifyPhoneType:VerifyPhoneTypeBind] ;
        [self.navigationController pushViewController:controller animated:YES];
    } else if (alertView.tag == TAG_ALERT_VIEW_CANCEL_ORDER) {
        [self cancelOrder];
    } else if (alertView.tag == TAG_ALERT_VIEW_CANCEL_CLUB_ORDER) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            //将标志位清空
            self.isNoUsedClubOrder = NO;
            
            [self submitOrder];
        }
    }
}

- (void)didSubmitOrder:(NSString *)status resultOrder:(Order *)resultOrder msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismiss];
        PayController *controller = [[PayController alloc] initWithOrder:resultOrder] ;
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        if (msg) {
            [SportProgressView dismissWithError:msg];
        } else {
            [SportProgressView dismissWithError:@"网络有点问题，请稍后重试"];
        }
    }
}

- (void)didClickUnpaidOrderAlertViewPayButton
{
    [OrderManager checkOrderStatus:_needPayOrder];
    
    if (_needPayOrder.status == OrderStatusCancelled) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"你的未支付订单已超时，点击确定取消订单" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        alertView.tag = TAG_ALERT_VIEW_CANCEL_ORDER;
        [alertView show];
        return;
    }
    
    PayController *controller = [[PayController alloc] initWithOrder:_needPayOrder];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)cancelOrder
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    [SportProgressView showWithStatus:@"正在取消订单..." hasMask:YES];
    [OrderService cancelOrder:self
                        order:_needPayOrder
                       userId:user.userId];
}

- (void)didClickUnpaidOrderAlertViewCancelButton
{
    [self cancelOrder];
}

- (void)didCancelOrder:(NSString *)status orderId:(NSString *)orderId
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismissWithSuccess:@"取消成功"];
        self.needPayOrder = nil;
        [self queryNeedPay];
    } else {
        [SportProgressView dismissWithError:@"取消失败,请重试"];
    }
}

//- (void)keyboardWasShown:(NSNotification *) notif
//{
//    self.isKeyboardShown = YES;
//    NSDictionary *info = [notif userInfo];
//    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
//    CGSize keyboardSize = [value CGRectValue].size;
//    
//    if (self.inputGoodsCountView) {
//        UIView *contentView = self.inputGoodsCountView.contentHolderView;
//        CGFloat offset = contentView.frame.origin.y + contentView.frame.size.height - self.inputGoodsCountView.frame.size.height + keyboardSize.height;
//        
//        if (offset > 0)
//        {
//            [UIView animateWithDuration:0.3 animations:^{
//                self.inputGoodsCountView.contentHolderView.center = CGPointMake(contentView.center.x, contentView.center.y - offset);
//            }];
//        }
//    }
//    
//    ///keyboardWasShown = YES;
//}
//
//- (void)keyboardWasHidden:(NSNotification *) notif
//{
//    self.isKeyboardShown = NO;
//    
//    if (self.inputGoodsCountView) {
//        [self.inputGoodsCountView updateMinusButtonAndPlusButton];
//        
//        [UIView animateWithDuration:0.3 animations:^{
//            self.inputGoodsCountView.contentHolderView.center = CGPointMake(self.inputGoodsCountView.center.x, self.inputGoodsCountView.center.y - 20);
//        }];
//    }
//
//}

- (void) didClickBackground
{
    if (self.isKeyboardShown == YES && self.inputGoodsCountView) {
        [self.inputGoodsCountView.countTextField resignFirstResponder];
    }
    else
    {
        [self.inputGoodsCountView removeFromSuperview];
    }
}

- (BOOL)isLoginAndShowLoginIfNotWithMessage:(NSString *)message
{
    if ([UserManager isLogin]) {
        return YES;
    } else {
        LoginController *controller = [[LoginController alloc] init];
       
        controller.loginDelegate = self;
        controller.loginDelegateParameter = message;
        [self.navigationController pushViewController:controller animated:YES];
        return NO;
    }
}

- (void)pushClubIntroduceController
{
    ActClubIntroduceController *controller = [[ActClubIntroduceController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)clickClubPromoteButton:(id)sender {
    [MobClickUtils event:umeng_event_click_affirm_order_club_recommend_enter];
    self.isRefreshSelection = YES;
    if ([self isLoginAndShowLoginIfNotWithMessage:@"buy"]) {
        [self pushClubIntroduceController];
    }
}

- (void)didLoginAndPopController:(NSString *)parameter
{
    //buy
    if ([parameter isEqualToString:@"buy"]) {
        [self pushClubIntroduceController];
    }
}

-(void)updateSelectionButton
{
    self.selectedConfirmPayType = ConfirmPayTypeOnline;

    self.priceHolderView.hidden = NO;
    
    self.packagePriceLabel.hidden = NO;
    
    if (self.plusMinusView == nil) {
        self.plusMinusView = [SportPlusMinusView createSportPlusMinusViewWithMaxNumber:self.goods.limitCount minNumber:1];
        self.plusMinusView.delegate = self;
    }
    
    [self.plusMinusHolderView addSubview:self.plusMinusView];

}

-(void)updateClupPayUI {
    
    [self updateSelectionButton];
    
    [self updateRefundHolderView];

}

- (IBAction)clickClubPayButton:(id)sender {
    self.isClubPay = YES;
    [self updateClupPayUI];
}

- (IBAction)clickNormalPayButton:(id)sender {
    self.isClubPay = NO;
    [self updateClupPayUI];
}

#pragma mark -BusinessOrderConfirmBottomViewDelegate
-(void) prepareForPriceDetailView:(NSMutableArray *)priceDetailArray {
    NSString *goodsPriceString = [PriceUtil toPriceStringWithYuan:self.goods.promotePrice > 0?self.goods.promotePrice:self.goods.price];
    [priceDetailArray addObject:@[self.goods.name,self.count > 1?[NSString stringWithFormat:@"%@×%d",goodsPriceString,self.count]:goodsPriceString]];
    
    if (self.selectedActivityId) {
        FavourableActivity *selectedActivity = nil;
        for (FavourableActivity *activity in _activityList) {
            if ([_selectedActivityId isEqualToString:activity.activityId]) {
                selectedActivity = activity;
                break;
            }
        }

        if (selectedActivity) {
            NSString *activityAmountString = [PriceUtil toPriceStringWithYuan:selectedActivity.activityPrice];
            [priceDetailArray addObject:@[selectedActivity.activityName,[NSString stringWithFormat:@"-%@",activityAmountString]]];
        }
        
    } else if (self.selectedVoucher) {
        NSString *voucherAmountString = [PriceUtil toPriceStringWithYuan:self.selectedVoucher.amount];
        [priceDetailArray addObject:@[@"卡券",[NSString stringWithFormat:@"-%@",voucherAmountString]]];
    }
    
}

-(void) didClickSubmitButton {
    if ([UserManager isLogin]) {
        [self submitOrder];
    } else {
        LoginController *controller = [[LoginController alloc] init] ;
        [self.navigationController pushViewController:controller animated:YES];
    }
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
        }
    }
}


@end
