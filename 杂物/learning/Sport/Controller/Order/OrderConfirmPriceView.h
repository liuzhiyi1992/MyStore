//
//  OrderConfirmPriceView.h
//  Sport
//
//  Created by haodong  on 15/1/12.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavourableActivityView.h"
#import "MyVouchersController.h"
#import "AddVoucherController.h"
@class Voucher;
@class Insurance;
@protocol OrderConfirmPriceViewDelegate <NSObject>
@optional

- (void)didSelectActivity:(NSString *)selectedActivityId;
- (void)didSelectVoucher:(Voucher *)voucher;
- (void)didCancelSelectVoucher;
- (void)didChangeInsurance;
- (void)didClickInsuranceUrl;
- (void)didSelectGoodsList:(NSArray *)goodsList;
//- (void)didSelectUserMoney:(float)selectUserMoney;

@end

@interface OrderConfirmPriceView : UIView <FavourableActivityViewDelegate, MyVouchersControllerDelegate,AddVoucherControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *payPriceHolderView;
@property (weak, nonatomic) IBOutlet UIView *voucherHolderView;
@property (weak, nonatomic) IBOutlet UIView *promoteHolderView;
@property (weak, nonatomic) IBOutlet UIView *totalPriceHolderView;

@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;


@property (weak, nonatomic) IBOutlet UIImageView *promoteRadioImageView;
@property (weak, nonatomic) IBOutlet UIImageView *voucherRadioImageView;

@property (weak, nonatomic) IBOutlet UILabel *promotePriceLabel;
@property (weak, nonatomic) IBOutlet UIButton *promoteNameButton;

@property (weak, nonatomic) IBOutlet UIView *useVoucherHolderView;
@property (weak, nonatomic) IBOutlet UILabel *voucherAmountLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelVoucherButton;

@property (weak, nonatomic) IBOutlet UILabel *needPayPriceLabel;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (assign, nonatomic) id<OrderConfirmPriceViewDelegate> delegate;
@property (assign, nonatomic) BOOL isEnableInsurance;  //是否购买保险（标示保险功能是否开启，如开启，是否购买）
@property (assign, nonatomic) int insuranceNumber;  //保险数量，重写set方法
@property (strong, nonatomic) NSString *needPayPriceString;

+ (OrderConfirmPriceView *)createOrderConfirmPriceView;

// 给月卡约练充值用
- (void)updateViewWithAmount:(float)amount
    canUseActivityAndVoucher:(BOOL)canUseActivityAndVoucher
                activityList:(NSArray *)activityList
          selectedActivityId:(NSString *)selectedActivityId
                     voucher:(Voucher *)voucher
                  controller:(UIViewController *)controller
             activityMessage:(NSString *)activityMessage
                    goodsIds:(NSString *)goodsIds
                   orderType:(int)orderType;

- (void)updateViewWithAmount:(float)amount
    canUseActivityAndVoucher:(BOOL)canUseActivityAndVoucher
          selectedActivityId:(NSString *)selectedActivityId
                     voucher:(Voucher *)voucher
                  controller:(UIViewController *)controller
                    goodsIds:(NSString *)goodsIds
                   orderType:(int)orderType
                confirmOrder:(ConfirmOrder *)confirmOrder;

// 场次用
-(void) updateViewWithOrder:(Order *)order
               confirmOrder:(ConfirmOrder *)confirmOrder
   canUseActivityAndVoucher:(BOOL)canUseActivityAndVoucher
                    voucher:(Voucher *)voucher
                 controller:(UIViewController *)controller
                   goodsIds:(NSString *)goodsIds;

- (void) updateInsuranceSwitchWithAction:(BOOL)isOn;
- (FavourableActivity *)selectedActivity;
-(void) isShowGoodsList:(BOOL)isShow;
@end
