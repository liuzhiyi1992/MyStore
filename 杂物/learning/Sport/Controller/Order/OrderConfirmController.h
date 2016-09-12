//
//  OrderConfirmController.h
//  Sport
//
//  Created by haodong  on 13-7-22.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SportController.h"
#import "OrderService.h"
#import "FavourableActivityView.h"
#import "OrderConfirmPriceView.h"

@class Order;

typedef NS_ENUM(NSInteger,FromController) {
    FromControllerHome = 0,
    FromControllerOther = 1,
};

#define KEY_LAST_CONFIRM_PAY @"key_last_confirm_pay"

@interface OrderConfirmController : SportController<OrderServiceDelegate, FavourableActivityViewDelegate, UIAlertViewDelegate, OrderConfirmPriceViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *orderHolderView;
@property (weak, nonatomic) IBOutlet UIView *orderBaseHolderView;
@property (weak, nonatomic) IBOutlet UIView *orderBaseBottomHolderView;

@property (weak, nonatomic) IBOutlet UIView *refundTipsHolderView;
@property (weak, nonatomic) IBOutlet UIView *confirmPayTypeHolderView;

@property (weak, nonatomic) IBOutlet UITableView *confirmPayTypeTableView;

@property (weak, nonatomic) IBOutlet UILabel *businessNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *useDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;

@property (weak, nonatomic) IBOutlet UIView *priceHolderView;
@property (weak, nonatomic) IBOutlet UIView *submitHolderView;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;

@property (weak, nonatomic) IBOutlet UILabel *refundTipsLabel;
@property (weak, nonatomic) IBOutlet UILabel *refundRule;

@property (weak, nonatomic) IBOutlet UIImageView *refundRuleImageView;
@property (weak, nonatomic) IBOutlet UIImageView *refundTipsImageView;
@property (strong, nonatomic) IBOutlet UIButton *refundButton;
@property (strong, nonatomic) IBOutlet UIImageView *refundDetailImageView;

@property (strong, nonatomic) OrderConfirmPriceView *orderConfirmPriceView;
- (id)initWithOrder:(Order *)order;
- (id)initWithOrderFromQuickBooking:(Order *)order;

@end
