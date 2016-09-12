//
//  SingleBookingController.h
//  Sport
//
//  Created by haodong  on 13-12-19.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SportController.h"
#import "SelectGoodsKindView.h"
#import "OrderService.h"
#import "UnpaidOrderAlertView.h"
#import "OrderConfirmPriceView.h"
#import "InputGoodsCountView.h"

@class ProductInfo;
@class MonthCardCourse;
@interface SingleBookingController : SportController<UITextFieldDelegate, OrderServiceDelegate, UnpaidOrderAlertViewDelegate, UIAlertViewDelegate, OrderConfirmPriceViewDelegate, InputGoodsCountViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *topHolderView;
@property (weak, nonatomic) IBOutlet UIView *refundTipsHolderView;

@property (weak, nonatomic) IBOutlet UILabel *businessNameLabel;


@property (weak, nonatomic) IBOutlet UILabel *packageNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *packagePriceLabel;

@property (weak, nonatomic) IBOutlet UIView *priceHolderView;

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;

@property (weak, nonatomic) IBOutlet UIImageView *refundTipsImageView;
@property (weak, nonatomic) IBOutlet UILabel *refundTipsLabel;
@property (strong, nonatomic) OrderConfirmPriceView *orderConfirmPriceView;
@property (assign, nonatomic) BOOL isKeyboardShown;

- (instancetype)initWithGoods:(Goods *)goods
                 businessName:(NSString *)businessName
                isSpecialSale:(BOOL)isSpecialSale;

- (instancetype)initWithCourse:(MonthCardCourse *)course;

@end
