//
//  BusinessOrderConfirmController.h
//  Sport
//
//  Created by 江彦聪 on 16/8/3.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "SportController.h"
#import "OrderService.h"
#import "OrderConfirmPriceView.h"
#import "ConfirmPayTypeCell.h"
@class Order;

typedef NS_ENUM(NSInteger,FromController) {
    FromControllerHome = 0,
    FromControllerOther = 1,
};

#define KEY_LAST_CONFIRM_PAY @"key_last_confirm_pay"

@interface BusinessOrderConfirmController : SportController
<OrderServiceDelegate, UIAlertViewDelegate, OrderConfirmPriceViewDelegate, UITableViewDataSource, UITableViewDelegate,ConfirmPayTypeCellDelegate>


@property (weak, nonatomic) IBOutlet UIView *confirmPayTypeHolderView;

@property (weak, nonatomic) IBOutlet UITableView *confirmPayTypeTableView;

@property (weak, nonatomic) IBOutlet UILabel *businessNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *useDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *courtDetailLabel;

@property (weak, nonatomic) IBOutlet UIView *priceHolderView;

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;

@property (weak, nonatomic) IBOutlet UILabel *refundTipsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *refundTipsImageView;
@property (strong, nonatomic) IBOutlet UIButton *refundButton;
@property (strong, nonatomic) IBOutlet UIImageView *refundDetailImageView;

@property (strong, nonatomic) OrderConfirmPriceView *orderConfirmPriceView;
- (id)initWithOrder:(Order *)order;
- (id)initWithOrderFromQuickBooking:(Order *)order;

@end
