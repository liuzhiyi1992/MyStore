//
//  RefundController.h
//  Sport
//
//  Created by haodong  on 15/3/9.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportController.h"
#import "RefundTypeView.h"
#import "OrderService.h"
#import "InputPasswordView.h"

@interface RefundController : SportController <RefundTypeViewDelegate, UITableViewDataSource, UITableViewDelegate, OrderServiceDelegate,UITextFieldDelegate,InputPasswordViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

@property (weak, nonatomic) IBOutlet UIView *wayHolderView;
@property (weak, nonatomic) IBOutlet UILabel *refundAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *causeTitleLabel;
@property (weak, nonatomic) IBOutlet UITableView *causeTableView;

@property (weak, nonatomic) IBOutlet UIImageView *suggestionBackgroundImageView;

@property (weak, nonatomic) IBOutlet UITextField *suggestionTextField;

@property (weak, nonatomic) IBOutlet UIView *bottomHolderView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

//未退款订单，申请退款
- (instancetype)initWithAmount:(float)amount
                 refundWayList:(NSArray *)refundWayList
               refundCauseList:(NSArray *)refundCauseList
                       orderId:(NSString *)orderId
                     priceList:(NSArray *)priceList;

//已退款订单查看退款状态
- (instancetype)initWithStatus:(int)status
                     refundWay:(NSString *)refundWay
                        amount:(float)amount;

@end
