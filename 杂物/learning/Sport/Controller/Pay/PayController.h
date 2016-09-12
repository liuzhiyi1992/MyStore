//
//  PayController.h
//  Sport
//
//  Created by haodong  on 14-8-18.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportController.h"
#import "MyVouchersController.h"
#import "OrderService.h"
#import "SNSService.h"
#import "FavourableActivityView.h"
#import "PayTypeCell.h"
#import "WebPayController.h"
#import "UnionPayManager.h"
#import "InputPasswordView.h"
#import "RegisterController.h"
#import "ForumService.h"
#import "PayAmountView.h"
#import "PayTypeView.h"
#import "PayDelayView.h"
#import "PaySuccessView.h"
#import "PaySuccessWithRedPacketView.h"
#import "PaymentAnimator.h"

@class Order;

@interface PayController : SportController <MyVouchersControllerDelegate, OrderServiceDelegate, UIActionSheetDelegate, SNSServiceDelegate, FavourableActivityViewDelegate, UIAlertViewDelegate, RegisterControllerDelegate, ForumServiceDelegate, PayAmountViewDelegate, PayTypeViewDelegate, PayDelayViewDelegate, PaySuccessViewDelegate, PaySuccessWithRedPacketViewDelegate, PaymentAnimatorDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *unpayHolderView;
@property (weak, nonatomic) IBOutlet UIView *orderHolderView;
@property (weak, nonatomic) IBOutlet UILabel *orderNameLabel;
@property (weak, nonatomic) IBOutlet UIView *tipsHolderView;
@property (weak, nonatomic) IBOutlet UILabel *remainingTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *payTypeHolderView;
@property (weak, nonatomic) IBOutlet UIView *priceHolderView;
@property (weak, nonatomic) IBOutlet UIView *cardInfoHolderView;
@property (weak, nonatomic) IBOutlet UIButton *payButton;
//@property (weak, nonatomic) IBOutlet UIScrollView *paySuccessHoldView;

@property (weak, nonatomic) IBOutlet UIView *paySuccessHolderView;

@property (weak, nonatomic) IBOutlet UIView *timeDelayHolderView;


- (instancetype)initWithOrder:(Order *)order;
- (void)showShortTipsView:(NSString *)tips;

@end
