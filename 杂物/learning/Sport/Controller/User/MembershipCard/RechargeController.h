//
//  RechargeController.h
//  Sport
//
//  Created by haodong  on 15/4/14.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportController.h"
#import "MembershipCardService.h"
#import "MembershipCard.h"
#import "PayService.h"
#import "WebPayController.h"
#import "UnionPayManager.h"
#import "OrderService.h"

@protocol RechargeControllerDelegate <NSObject>
@optional
- (void)didClickRechargeControllerBookButton;
@end


@interface RechargeController : SportController<UITableViewDataSource, UITableViewDelegate, MembershipCardServiceDelegate, PayServiceDelegate, WebPayControllerrDelegate, UPPayPluginDelegate, OrderServiceDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *unpayHolderView;

@property (weak, nonatomic) IBOutlet UIView *baseHolderView;

@property (weak, nonatomic) IBOutlet UILabel *businessNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardPhoneLabel;

@property (weak, nonatomic) IBOutlet UITableView *amountTableView;
@property (weak, nonatomic) IBOutlet UITableView *payTypeTableView;
@property (weak, nonatomic) IBOutlet UIView *payAmountHolderView;
@property (weak, nonatomic) IBOutlet UIButton *payButton;
@property (weak, nonatomic) IBOutlet UILabel *needPayAmount;

@property (weak, nonatomic) IBOutlet UIView *rechargeSuccessHolderView;
@property (weak, nonatomic) IBOutlet UILabel *cardAmountLabel;
@property (weak, nonatomic) IBOutlet UIButton *bookButton;

@property (weak, nonatomic) IBOutlet UIView *timeDelayHolderView;
@property (weak, nonatomic) IBOutlet UILabel *timeDelayAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeDelayCardNumberLabel;


@property (weak, nonatomic) IBOutlet UIButton *refreshButton;

@property (assign, nonatomic) id<RechargeControllerDelegate> delegate;

- (instancetype)initWithGoodsList:(NSArray *)goodsList card:(MembershipCard *)card;

@end
