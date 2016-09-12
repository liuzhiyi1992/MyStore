//
//  OrderDetailController.h
//  Sport
//
//  Created by haodong  on 14-8-20.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportController.h"
#import "OrderService.h"
#import "SNSService.h"
#import "MembershipCardService.h"
#import "ForumService.h"

@class Order;

@interface OrderDetailController : SportController<OrderServiceDelegate, UIActionSheetDelegate, SNSServiceDelegate, UIAlertViewDelegate, MembershipCardServiceDelegate, ForumServiceDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

@property (weak, nonatomic) IBOutlet UILabel *businessNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *payButton;
@property (weak, nonatomic) IBOutlet UIButton *writeReviewButton;

@property (weak, nonatomic) IBOutlet UIImageView *refundImageView;

@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *useDateLabel;

@property (weak, nonatomic) IBOutlet UILabel *goodsNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;

@property (weak, nonatomic) IBOutlet UILabel *consumeCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *payWayLabel;

@property (weak, nonatomic) IBOutlet UIView *businessHolderView;
@property (weak, nonatomic) IBOutlet UIView *forumEntranceHolderView;
@property (weak, nonatomic) IBOutlet UIView *refundHolderView;
@property (weak, nonatomic) IBOutlet UIView *detailHolderView;
@property (weak, nonatomic) IBOutlet UIView *amountHolderView;
@property (weak, nonatomic) IBOutlet UIView *orderHoderView;

@property (weak, nonatomic) IBOutlet UIView *singleHolderView;
@property (weak, nonatomic) IBOutlet UIView *defaultHolderView;

@property (weak, nonatomic) IBOutlet UIButton *businessButton;

@property (weak, nonatomic) IBOutlet UIView *bottomHolderView;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UIButton *qrCodeButton;
@property (weak, nonatomic) IBOutlet UIButton *refundButton;

@property (weak, nonatomic) IBOutlet UIButton *cardRefundButton;

@property (weak, nonatomic) IBOutlet UILabel *useDescriptionLabel;

@property (weak, nonatomic) IBOutlet UIView *consumeCodeHolderView;
@property (weak, nonatomic) IBOutlet UIView *orderBottomHolderView;

- (id)initWithOrder:(Order *)order;

- (id)initWithOrder:(Order *)order isReload:(BOOL)isReload;

@end
