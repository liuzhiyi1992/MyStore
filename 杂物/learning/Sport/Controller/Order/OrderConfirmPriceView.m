//
//  OrderConfirmPriceView.m
//  Sport
//
//  Created by haodong  on 15/1/12.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "OrderConfirmPriceView.h"
#import "Voucher.h"
#import "PriceUtil.h"
#import "FavourableActivity.h"
#import "UIView+Utils.h"
#import "MyVouchersController.h"
#import "Insurance.h"
#import "Product.h"
#import "DateUtil.h"
#import "NSDate+Utils.h"
#import "Order.h"
#import "SportPopUpView.h"
#import "BusinessService.h"
#import "BusinessGoodsListCell.h"
#import "BusinessGoodsListController.h"
#import "ZYKeyboardUtil.h"
#import "UIView+Utils.h"

@interface OrderConfirmPriceView()<BusinessGoodsListCellDelegate,UITableViewDelegate,UITableViewDataSource,BusinessGoodsListControllerDelegate>
@property (assign, nonatomic) float amount; //总额
@property (assign, nonatomic) BOOL canUseActivityAndVoucher;
@property (strong, nonatomic) NSArray *activityList;
@property (copy, nonatomic) NSString *selectedActivityId;
@property (strong, nonatomic) Voucher *voucher;
@property (assign, nonatomic) UIViewController *controller;
@property (copy, nonatomic) NSString *activityMessage;
@property (copy, nonatomic) NSString *goodsIds;
@property (assign, nonatomic) int orderType;
@property (copy, nonatomic) NSString *categoryId;
@property (strong, nonatomic) IBOutlet UIImageView *lineImage1;
@property (strong, nonatomic) IBOutlet UIImageView *lineImage2;
@property (strong, nonatomic) IBOutlet UIImageView *lineImage3;
@property (weak, nonatomic) IBOutlet UIImageView *lineImage4;
@property (weak, nonatomic) IBOutlet UIImageView *lineImage5;
@property (weak, nonatomic) IBOutlet UILabel *insuranceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *insuranceTotalPricelLabel;
@property (weak, nonatomic) IBOutlet UILabel *insuranceTipsLabel;
@property (weak, nonatomic) UISwitch *insuranceSwitch;
@property (weak, nonatomic) IBOutlet UITextField *insuranceNumberLabel;
@property (weak, nonatomic) IBOutlet UIView *insuranceDetailView;
@property (weak, nonatomic) IBOutlet UIView *insuranceHolderView;
@property (weak, nonatomic) IBOutlet UIView *insurancePriceView;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *lineImageArray;

@property (weak, nonatomic) IBOutlet UILabel *insuranceTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;
@property (weak, nonatomic) IBOutlet UIButton *minusButton;

@property (strong, nonatomic) Insurance *insurance;
@property (assign, nonatomic) BOOL isIncludeInsurance;  //是否包括保险的功能
@property (copy, nonatomic) NSString *tips;

@property (assign, nonatomic) float insuranceTotalPrice; //重写set方法
@property (strong, nonatomic) Order *order;
@property (strong, nonatomic) ConfirmOrder *confirmOrder;
@property (assign, nonatomic) int insuranceOrderTime;

@property (copy,nonatomic) NSString *insuranceLimitTips;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *selectButtonArray;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *totalPriceHolderTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *insuranceHolderViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *insurancePriceViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *promoteHolderViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voucherHolderViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *promoteNameButtonWidth;

@property (weak, nonatomic) IBOutlet UILabel *validVoucherNumberLabel;
@property (weak, nonatomic) IBOutlet UITableView *goodsListTableView;
@property (strong, nonatomic) NSArray *goodsList;
@property (strong, nonatomic) NSMutableArray *displayGoodsList;
@property (weak, nonatomic) IBOutlet UILabel *guideLabel;
@property (weak, nonatomic) IBOutlet UIView *goodsListHolderView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *goodsListHolderViewHeight;
@property (assign, nonatomic) float goodsTotalPrice;
@property (weak, nonatomic) IBOutlet UILabel *goodsTotalPriceLabel;
@property (weak, nonatomic) IBOutlet UIButton *moreGoodsButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *payPriceHolderViewHeight;
@property (strong, nonatomic) ZYKeyboardUtil *keyboardUtil;

@end

@implementation OrderConfirmPriceView


#define DEFAULT_INSURANCE_NUMBER 5
#define MAX_INSURANCE_NUMBER 15 //最大购买数量
- (void)awakeFromNib {

    // v2.1.0 不在这里显示订单总额，暂时隐藏
    self.payPriceHolderViewHeight.constant = 0;
    self.payPriceHolderView.hidden = YES;
    
    self.promoteNameButton.userInteractionEnabled = NO;
    

    [self updateWidth:[UIScreen mainScreen].bounds.size.width];
    
    for (UIImageView *imageView in self.lineImageArray) {
        [imageView updateHeight:0.5];
    }
    
    //默认不包含保险
    self.isIncludeInsurance = NO;
    self.insuranceNumber = DEFAULT_INSURANCE_NUMBER;
    //[view.buttonBackgroundImageView setImage:[SportImage whiteBackgroundImage]];
    self.insuranceNumberLabel.layer.borderColor = [UIColor hexColor:@"dddddd"].CGColor;
    self.insuranceNumberLabel.layer.borderWidth = 0.5;
    self.insuranceNumberLabel.layer.cornerRadius = 10.0;
    self.insuranceNumberLabel.layer.masksToBounds = YES;
    
    UISwitch *insuranceSwitch = [[UISwitch alloc]init];
    insuranceSwitch.transform = CGAffineTransformMakeScale(0.75, 0.75);
    [insuranceSwitch updateCenterY:self.insuranceTitleLabel.center.y];
    [insuranceSwitch updateOriginX:[UIScreen mainScreen].bounds.size.width - 15 - insuranceSwitch.frame.size.width];
    [insuranceSwitch addTarget:self action:@selector(clickInsuranceSwitch:) forControlEvents:UIControlEventValueChanged];
    
    //默认不开启保险，但这不会触发action事件，所以慎用 2016-01-08 by jyc
    [insuranceSwitch setOn:NO];
    [insuranceSwitch setOnTintColor:[SportColor defaultColor]];
    [self.insuranceHolderView addSubview:insuranceSwitch];
    self.insuranceSwitch = insuranceSwitch;
    
    UIButton *maskButton = [[UIButton alloc]initWithFrame:self.insuranceSwitch.frame];
    [maskButton addTarget:self action:@selector(checkInsuranceSwitchStatus) forControlEvents:UIControlEventTouchUpInside];
    [self.insuranceHolderView addSubview:maskButton];
    
    for(UIButton *button in self.selectButtonArray){
        [button setBackgroundImage:[SportColor createImageWithColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.2]] forState:UIControlStateHighlighted];
    }
}

- (void)setInsuranceNumber:(int)insuranceNumber {
    _insuranceNumber = insuranceNumber;
    
    self.insuranceNumberLabel.text = [@(self.insuranceNumber) stringValue];
    self.insuranceTotalPrice = insuranceNumber * self.insurance.unitPrice;
}

- (void) setInsuranceTotalPrice:(float)insuranceTotalPrice {
    _insuranceTotalPrice = insuranceTotalPrice;
    self.insuranceTotalPricelLabel.text = [PriceUtil toPriceStringWithYuan:insuranceTotalPrice];
    
    [self updateNeedPayPirce];
}

+ (OrderConfirmPriceView *)createOrderConfirmPriceView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"OrderConfirmPriceView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    OrderConfirmPriceView *view = [topLevelObjects objectAtIndex:0];
    
    view.cancelVoucherButton.layer.borderColor = [SportColor content2Color].CGColor;
    view.cancelVoucherButton.layer.borderWidth = 1.0f;
    view.cancelVoucherButton.layer.cornerRadius = view.cancelVoucherButton.frame.size.height/2;
    view.cancelVoucherButton.layer.masksToBounds = YES;
    
    view.goodsListHolderView.hidden = YES;
    view.goodsListHolderViewHeight.constant = 0;
    view.goodsListTableView.delegate = view;
    view.goodsListTableView.dataSource = view;
    
    UINib *cellNib = [UINib nibWithNibName:[BusinessGoodsListCell getCellIdentifier] bundle:nil];
    [view.goodsListTableView registerNib:cellNib forCellReuseIdentifier:[BusinessGoodsListCell getCellIdentifier]];
    
    return view;
}

// 给人次用
- (void)updateViewWithAmount:(float)amount
    canUseActivityAndVoucher:(BOOL)canUseActivityAndVoucher
          selectedActivityId:(NSString *)selectedActivityId
                     voucher:(Voucher *)voucher
                  controller:(UIViewController *)controller
                    goodsIds:(NSString *)goodsIds
                   orderType:(int)orderType
                confirmOrder:(ConfirmOrder *)confirmOrder
{
    self.confirmOrder = confirmOrder;
    self.amount = amount;
    self.canUseActivityAndVoucher = canUseActivityAndVoucher;
    self.activityList = confirmOrder.activityList;
    self.selectedActivityId = selectedActivityId;
    self.voucher = voucher;
    self.controller = controller;
    self.activityMessage = confirmOrder.activityMessage;
    self.goodsIds = goodsIds;
    self.orderType = orderType;
    
    [self updateViewHeight];
    
    [self updateAllViews];
}

// 准备废弃
- (void)updateViewWithAmount:(float)amount
    canUseActivityAndVoucher:(BOOL)canUseActivityAndVoucher
                activityList:(NSArray *)activityList
          selectedActivityId:(NSString *)selectedActivityId
                     voucher:(Voucher *)voucher
                  controller:(UIViewController *)controller
             activityMessage:(NSString *)activityMessage
                    goodsIds:(NSString *)goodsIds
                   orderType:(int)orderType
{
    self.amount = amount;
    self.canUseActivityAndVoucher = canUseActivityAndVoucher;
    self.activityList = activityList;
    self.selectedActivityId = selectedActivityId;
    self.voucher = voucher;
    self.controller = controller;
    self.activityMessage = activityMessage;
    self.goodsIds = goodsIds;
    self.orderType = orderType;
    
    [self updateViewHeight];
    
    [self updateAllViews];
}

//场次订单用（包含保险信息）
-(void) updateViewWithOrder:(Order *)order
               confirmOrder:(ConfirmOrder *)confirmOrder
   canUseActivityAndVoucher:(BOOL)canUseActivityAndVoucher
                    voucher:(Voucher *)voucher
                 controller:(UIViewController *)controller
                   goodsIds:(NSString *)goodsIds
{
    self.confirmOrder = confirmOrder;
    self.isIncludeInsurance = confirmOrder.isIncludeInsurance;
    
    if (confirmOrder.insuranceList.count > 0) {
        self.insurance = confirmOrder.insuranceList[0];
    }

    self.tips = confirmOrder.insuranceTips;
    self.order = order;
    self.insuranceOrderTime = confirmOrder.insuranceOrderTime;
    self.insuranceLimitTips = confirmOrder.insuranceLimitTips;
    self.amount = confirmOrder.totalAmount;
    self.canUseActivityAndVoucher = canUseActivityAndVoucher;
    self.activityList = confirmOrder.activityList;
    self.selectedActivityId = confirmOrder.selectedActivityId;
    self.voucher = voucher;
    self.controller = controller;
    self.activityMessage = confirmOrder.activityMessage;
    self.goodsIds = goodsIds;
    self.orderType = order.type;
    
    [self updateViewHeight];
    
    [self updateAllViews];
    
    [BusinessService getBusinessGoodsListWithBusinessId:self.order.businessId
                                             categoryId:self.order.categoryId complete:^(NSString *status,NSString *msg,NSArray *goodsList,NSString *guide){
                                                 [self didGetGoodsList:status msg:msg goodsList:goodsList guide:guide];
                                                 
                                             }];

}
#define GOODS_LIST_HOLDER_HEIGHT(CELL_NUM) (194 + (int)((CELL_NUM)-2)*[BusinessGoodsListCell getCellHeight])
-(void) didGetGoodsList:(NSString *)status msg:(NSString *)msg goodsList:(NSArray *)list guide:(NSString *)guide {
    if ([status isEqualToString:STATUS_SUCCESS]) {
        
        self.goodsList = list;
        if ([self.goodsList count] > 0) {
            self.goodsListHolderView.hidden = NO;
            if ([self.goodsList count] == 1) {
                self.displayGoodsList = [NSMutableArray arrayWithArray:self.goodsList];

            } else {
                if ([self.goodsList count] > 2) {
                    self.moreGoodsButton.hidden = NO;
                    [self.moreGoodsButton setTitle:[NSString stringWithFormat:@"更多卖品(%lu)>",(unsigned long)[self.goodsList count]] forState:UIControlStateNormal];
                } else {
                    self.moreGoodsButton.hidden = YES;
                }
                
                self.displayGoodsList = [NSMutableArray arrayWithArray:@[self.goodsList[0],self.goodsList[1]]];
                
            }
            
            self.goodsListHolderView.hidden = NO;
            self.goodsListHolderViewHeight.constant = GOODS_LIST_HOLDER_HEIGHT([self.displayGoodsList count]);
            
        } else {
            self.goodsListHolderView.hidden = YES;
            self.goodsListHolderViewHeight.constant = 0;
        }
        
        [self.goodsListTableView reloadData];
        self.guideLabel.text = guide;
        
    }
    
}

-(void) isShowGoodsList:(BOOL)isShow{
    if (isShow && [self.displayGoodsList count] > 0) {
        self.goodsListHolderView.hidden = NO;
        self.goodsListHolderViewHeight.constant = GOODS_LIST_HOLDER_HEIGHT([self.displayGoodsList count]);
    } else {
        self.goodsListHolderView.hidden = YES;
        self.goodsListHolderViewHeight.constant = 0;
    }
}

- (void)updateAllViews
{
    [self updateActivityAndVoucher];
    [self updateTotalPrice];
    [self updateNeedPayPirce];
    [self updateInsuranceView];
}

#define HEIGHT_ONE  45
#define SPACE 10
//调整高度
- (void)updateViewHeight
{
    CGFloat y = 0;
    
    if (_isIncludeInsurance) {
        
        self.insuranceHolderView.hidden = NO;
        self.insurancePriceView.hidden = NO;
        if (self.insuranceSwitch.on) {
            y = y + HEIGHT_ONE*3;
            self.insuranceDetailView.hidden = NO;
            self.insuranceHolderViewHeight.constant = HEIGHT_ONE*2;
        } else {
            y = y + HEIGHT_ONE;
            self.insuranceDetailView.hidden = YES;
            self.insuranceHolderViewHeight.constant = HEIGHT_ONE;
        }

        y = y + SPACE;
        
        self.totalPriceHolderTop.constant = 10;
        self.insurancePriceViewHeight.constant = 45;
    } else {
        self.totalPriceHolderTop.constant = 0;
        self.insurancePriceViewHeight.constant = 0;
        self.insuranceHolderViewHeight.constant = 0;
        self.insuranceHolderView.hidden = YES;
        self.insurancePriceView.hidden = YES;
    }
    
    if (_canUseActivityAndVoucher) {
        self.promoteHolderViewHeight.constant = 45;
        self.voucherHolderViewHeight.constant = 45;
        if ([_activityList count] == 0) {
            self.promoteHolderViewHeight.constant = 0;
            self.promoteHolderView.hidden = YES;

        }

    } else {
        self.promoteHolderViewHeight.constant = 0;
        self.voucherHolderViewHeight.constant = 0;
        self.promoteHolderView.hidden = YES;
        self.voucherHolderView.hidden = YES;
    }

    [self updateHeight:_payPriceHolderView.frame.origin.y + _payPriceHolderView.frame.size.height];
}

- (void)updateTotalPrice
{
    self.totalPriceLabel.text = [NSString stringWithFormat:@"%@元", [PriceUtil toValidPriceString:self.amount]];
}

- (IBAction)clickUsePromoteButton:(id)sender {
    [MobClickUtils event:umeng_event_confirm_order_click_activity];
    FavourableActivityView *view = [FavourableActivityView createViewWithActivityList:_activityList selectedActivityId:_selectedActivityId];
    view.delegate = self;
    [view show];
}

- (void)didSelectFavourableActivityView:(FavourableActivity *)favourableActivity inviteCode:(NSString *)inviteCode
{
    self.selectedActivityId = favourableActivity.activityId;
    self.voucher = nil;
    [self updateAllViews];
    
    if ([_delegate respondsToSelector:@selector(didSelectActivity:)]) {
        [_delegate didSelectActivity:favourableActivity.activityId];
    }
}

- (void)updateActivityAndVoucher
{
    [self.promoteRadioImageView setImage:[SportImage arrowRightImage]];
    [self.voucherRadioImageView setImage:[SportImage arrowRightImage]];
    
    if ([_selectedActivityId length] > 0) {

        [self updateActivityUse];
        [self updateVoucherCancel];
        
    } else if (_voucher) {
        
        [self updateActivityCancel];
        [self updateVoucherUse];
    
    } else {
        [self updateActivityCancel];
        [self updateVoucherCancel];
    
    }
}

- (FavourableActivity *)selectedActivity
{
    FavourableActivity *activity = nil;
    for (FavourableActivity *one in _activityList) {
        if ([one.activityId isEqualToString:_selectedActivityId]) {
            activity = one;
            break;
        }
    }
    return activity;
}

- (void)updateActivityUse
{
    //设置活动显示内容
    FavourableActivity *activity = [self selectedActivity];
    if (activity) {
        self.promoteNameButton.hidden = NO;
        [self.promoteNameButton setTitle:activity.activityName forState:UIControlStateNormal];
        //CGSize size = self.promoteNameButton.frame.size;  -- static analyze warning
        CGSize size;
        if ([self.promoteNameButton.titleLabel.text respondsToSelector:@selector(sizeWithAttributes:)]) {
            size = [self.promoteNameButton.titleLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObject:self.promoteNameButton.titleLabel.font forKey:NSFontAttributeName]];
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            size = [self.promoteNameButton.titleLabel.text sizeWithFont:self.promoteNameButton.titleLabel.font];
#pragma clang diagnostic pop
        }
        self.promoteNameButtonWidth.constant = size.width + 20;
//        [self.promoteNameButton updateWidth:size.width + 10];`
    } else {
        self.promoteNameButton.hidden = YES;
    }
    
    self.promotePriceLabel.text = [NSString stringWithFormat:@"-%@元", [PriceUtil toValidPriceString:activity.activityPrice]];
}

- (void)updateActivityCancel
{
    self.promoteNameButton.hidden = YES;
    self.promotePriceLabel.textColor = [SportColor content2Color];
    
    if ([_activityMessage length] > 0) {
        self.promotePriceLabel.text = _activityMessage;
    } else {
        self.promotePriceLabel.text = @"选择活动";
    }
}

- (void)updateVoucherUse
{
    self.useVoucherHolderView.hidden = YES;
    self.voucherAmountLabel.hidden = NO;
    self.cancelVoucherButton.hidden = NO;
    
    self.voucherAmountLabel.text = [NSString stringWithFormat:@"-%@元", [PriceUtil toValidPriceString:_voucher.amount]];
}

- (void)updateVoucherCancel
{
    self.useVoucherHolderView.hidden = NO;
    self.voucherAmountLabel.hidden = YES;
    self.cancelVoucherButton.hidden = YES;
    
    self.voucherAmountLabel.text = @"0元";
    self.validVoucherNumberLabel.text = [NSString stringWithFormat:@"点击使用卡券"];
}

- (IBAction)clickUseVoucherButton:(id)sender {
    [MobClickUtils event:umeng_event_confirm_order_click_coupon];
    
    MyVouchersController *controller = [[MyVouchersController alloc] init] ;
    controller.title = @"卡券";
    controller.delegate = self;
    controller.canSelect = YES;
    controller.orderAmount = _amount;
    controller.goodsIds = _goodsIds;
    controller.entry = @"1";
    controller.orderType = [@(self.orderType) stringValue];
    [_controller.navigationController pushViewController:controller animated:YES];
}

- (void)didMoveToSuperview {
    [self configureKeyboardUtil];
}

- (void)configureKeyboardUtil {
    self.keyboardUtil = [[ZYKeyboardUtil alloc] init];
    UIViewController *sponsorController;
    [self findControllerWithResultController:&sponsorController];
    if (sponsorController) {
        __weak typeof(sponsorController) weakController = sponsorController;
        __weak typeof(self) weakSelf = self;
        [_keyboardUtil setAnimateWhenKeyboardAppearAutomaticAnimBlock:^(ZYKeyboardUtil *keyboardUtil) {
            [keyboardUtil adaptiveViewHandleWithController:weakController adaptiveView:weakSelf, nil];
        }];
    }
}

- (void)didSelectedVoucher:(Voucher *)voucher
{
    self.voucher = voucher;
    self.selectedActivityId = nil;
    [self updateAllViews];

    if ([_delegate respondsToSelector:@selector(didSelectVoucher:)]) {
        [_delegate didSelectVoucher:voucher];
    }
}


-(void)didAddVoucher:(Voucher *)voucher{

    self.voucher = voucher;
    self.selectedActivityId = nil;
    [self updateAllViews];
    
    if ([_delegate respondsToSelector:@selector(didSelectVoucher:)]) {
        [_delegate didSelectVoucher:voucher];
    }
}

- (IBAction)clickCancelVoucherButton:(id)sender {
    self.voucher = nil;
    [self updateAllViews];
    
    if ([_delegate respondsToSelector:@selector(didCancelSelectVoucher)]) {
        [_delegate didCancelSelectVoucher];
    }
}

//- (void)updateUserMoney
//{
//    self.userMoneyLabel.text = [NSString stringWithFormat:@"%@元", [PriceUtil toValidPriceString:_userMoney]];
//    
//    float temp = _selectUserMoney;
//    
//    if (_isSelectUserMoney) {
//        float willUseAmount = 0; //要用的钱
//        
//        if ([_selectedActivityId length] > 0) {
//            FavourableActivity *activity = [self selectedActivity];
//            willUseAmount= _amount - activity.activityPrice;
//        } else if (_voucher) {
//            willUseAmount = _amount - _voucher.amount;
//        } else {
//            willUseAmount = _amount;
//        }
//        
//        if (willUseAmount <= _userMoney) {
//            self.selectUserMoney = willUseAmount;
//        } else {
//            self.selectUserMoney = _userMoney;
//        }
//        
//        self.selectMoneyLabel.hidden = NO;
//        self.selectMoneyLabel.text = [NSString stringWithFormat:@"%@元", [PriceUtil toValidPriceString:_selectUserMoney]];
//        [self.selectMoneyImageView setImage:[SportImage selectBoxOrangeImage]];
//    } else {
//        self.selectUserMoney = 0;
//        self.selectMoneyLabel.hidden = YES;
//        [self.selectMoneyImageView setImage:[SportImage selectBoxUnselectImage]];
//    }
//    
//    if (temp != _selectUserMoney) {
//        if ([_delegate respondsToSelector:@selector(didSelectUserMoney:)]) {
//            [_delegate didSelectUserMoney:_selectUserMoney];
//        }
//    }
//}

//- (IBAction)clickUserMoneyButton:(id)sender {
//    self.isSelectUserMoney = !self.isSelectUserMoney;
//    [self updateAllViews];
//    
//    if (self.isSelectUserMoney) {
//        [MobClickUtils event:umeng_event_confirm_order_click_money];
//    }
//}

//计算还需另外支付多少钱
- (void)updateNeedPayPirce
{
    FavourableActivity *activity = [self selectedActivity];
    self.needPayPriceString = [NSString stringWithFormat:@"%@元", [PriceUtil toValidPriceString:_amount - activity.activityPrice - _voucher.amount + self.insuranceTotalPrice+ self.goodsTotalPrice]];
    self.needPayPriceLabel.text = self.needPayPriceString;
    
    return;
}

- (void) checkInsuranceSwitchStatus {
    BOOL isForceClose = NO;
    
    //if (![self isValidTimeForBuyingInsurance]) {
    if([self.insuranceLimitTips length] != 0 ){
        [SportPopupView popupWithMessage:self.insuranceLimitTips];
        isForceClose = YES;
    }
    
    if (self.insuranceSwitch.on || isForceClose) {
        [self updateInsuranceSwitchWithAction:NO];
    } else {
        [self updateInsuranceSwitchWithAction:YES];
    }
}

- (void)clickInsuranceSwitch:(UISwitch *)sender {
    //重新刷新所有UI，因为涉及外面按钮的位置
    if ([_delegate respondsToSelector:@selector(didChangeInsurance)]) {
        [_delegate didChangeInsurance];
    }
}

-(void)updateInsuranceView {
    if (self.isIncludeInsurance && self.insuranceSwitch.on) {
        self.insuranceNameLabel.text = [NSString stringWithFormat:@"%@ %@/人",self.insurance.insuranceName,[PriceUtil toPriceStringWithYuan:self.insurance.unitPrice]];
        
        self.insuranceTipsLabel.text = self.tips;
        
        [self updateMinusButtonAndPlusButton];
        self.isEnableInsurance = YES;
        
        self.insuranceTotalPrice = self.insuranceNumber * self.insurance.unitPrice;
    } else {
        self.isEnableInsurance = NO;
        self.insuranceTotalPrice = 0;
    }
}

- (void)updateMinusButtonAndPlusButton
{
    if (self.insuranceNumber <= 1) {
        self.minusButton.enabled = NO;
        self.insuranceNumber = 1;
    } else {
        self.minusButton.enabled = YES;
    }
    
    if (self.insuranceNumber >= MAX_INSURANCE_NUMBER) {
        self.plusButton.enabled = NO;
        self.insuranceNumber = MAX_INSURANCE_NUMBER;
    } else {
        self.plusButton.enabled = YES;
    }
}

- (IBAction)clickMinusButton:(id)sender {
    if (self.insuranceNumber > 1) {
        self.insuranceNumber --;
    }
    
    [self updateMinusButtonAndPlusButton];
}

- (IBAction)clickPlusButton:(id)sender {
    if (self.insuranceNumber < MAX_INSURANCE_NUMBER) {
        self.insuranceNumber++;;
    }
    
    [self updateMinusButtonAndPlusButton];
}

- (IBAction)clickInsuranceUrlButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickInsuranceUrl)]) {
        [_delegate didClickInsuranceUrl];
    }
}

//提前N小时判断是否可以买保险, 改为后台配置
- (BOOL)isValidTimeForBuyingInsurance {
    NSTimeInterval validTimeBeforehand = self.insuranceOrderTime*60;
    
    NSTimeInterval dateInterval = self.order.useDate.timeIntervalSince1970;
    NSTimeInterval nowInterval = [NSDate date].timeIntervalSince1970;
    
    for (Product *product in self.order.productList) {
        NSTimeInterval timeInterval = dateInterval + product.startTimeHour*60*60 + product.startTimeMinuteString.integerValue*60;
        if (timeInterval - nowInterval <= validTimeBeforehand) {
            return NO;
        }
    }
    
    return YES;
}

- (void) updateInsuranceSwitchWithAction:(BOOL)isOn {
    if (self.insuranceSwitch.on == isOn) {
        return;
    }
    
    //如只是修改switch状态，并不会发送action
    [self.insuranceSwitch setOn:isOn];
    [self.insuranceSwitch sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.displayGoodsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [BusinessGoodsListCell getCellIdentifier];
    BusinessGoodsListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.delegate = self;
    [cell updateCellWithGoods:self.displayGoodsList[indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [BusinessGoodsListCell getCellHeight];
    
}

-(void) setGoodsTotalPrice:(float)goodsTotalPrice {
    _goodsTotalPrice = goodsTotalPrice;
    self.goodsTotalPriceLabel.text = [PriceUtil toPriceStringWithYuan:goodsTotalPrice];
}

#pragma mark -BusinessListCellDelegate
- (void) updateSelectedGoods:(BusinessGoods *) goods {
     float totalPrice = 0;
    for (BusinessGoods *oneGoods in self.displayGoodsList) {
        if (goods && [oneGoods.goodsId isEqualToString:goods.goodsId]) {
            oneGoods.totalCount = goods.totalCount;
        }
        
         totalPrice += oneGoods.totalCount*oneGoods.price;
    }
    
    if ([_delegate respondsToSelector:@selector(didSelectGoodsList:)]) {
        [_delegate didSelectGoodsList:self.displayGoodsList];
    }
    
    self.goodsTotalPrice = totalPrice;
    [self updateNeedPayPirce];
    
}

- (IBAction)clickMoreGoodsListButton:(id)sender {
    
    for (BusinessGoods *targetGoods in self.displayGoodsList) {
        
        for (__strong BusinessGoods *oriGoods in self.goodsList) {
            if ([targetGoods.goodsId isEqualToString:oriGoods.goodsId]) {
                oriGoods = targetGoods;
                break;
            }
        }
    }
    
    //深拷贝，保证值传递
    NSArray *passGoodsList = [[NSArray alloc] initWithArray:self.goodsList copyItems:YES];
    BusinessGoodsListController *controller = [[BusinessGoodsListController alloc]initWithGoodsList:passGoodsList];
    controller.delegate = self;
    UIViewController *sponsorController = nil;
    [self findControllerWithResultController:&sponsorController];
    if (sponsorController) {
        [sponsorController.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark BusinessGoodsListControllerDelegate
-(void) refreshSelectedGoodsList:(NSArray *)list {
    if ([list count] == 0) {
        return;
    }
    
    self.goodsList = list;
    NSMutableArray *targetList = [NSMutableArray array];
    for (BusinessGoods *oriGoods in self.goodsList) {
        if (oriGoods.totalCount > 0) {
            [targetList addObject:oriGoods];
        }
    }
    
    self.displayGoodsList = targetList;

    self.goodsListHolderViewHeight.constant = GOODS_LIST_HOLDER_HEIGHT([self.displayGoodsList count]);

    [self.goodsListTableView reloadData];
    
    [self updateSelectedGoods:nil];
}

@end
