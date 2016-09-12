//
//  OrderDetailController.m
//  Sport
//
//  Created by haodong  on 14-8-20.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "OrderDetailController.h"
#import "Order.h"
#import "SportProgressView.h"
#import "UserManager.h"
#import "UIView+Utils.h"
#import "BusinessDetailController.h"
#import "PayController.h"
#import "PriceUtil.h"
#import "SportPopupView.h"
#import "OrderConfirmController.h"
#import "SingleBookingController.h"
#import "RegisterController.h"
#import "WriteReviewController.h"
#import "ProductDetailGroupView.h"
#import "QrCodeController.h"
#import "RefundController.h"
#import "BaseConfigManager.h"
#import "QrCodeView.h"
#import "BusinessMapController.h"
#import "OrderAmountView.h"
#import "ForumEntranceView.h"
#import "ForumEntrance.h"
#import "ShareView.h"
#import "DateUtil.h"
#import "UIUtils.h"
#import "OrderDetailCourtJoinInfoView.h"

@interface OrderDetailController () <OrderDetailCourtJoinInfoViewDelegate>
@property (strong, nonatomic) ForumEntrance *entrance;
@property (strong, nonatomic) Order *order;
@property (weak, nonatomic) IBOutlet UILabel *refundDescLabel;
@property (weak, nonatomic) IBOutlet UIView *orderAmountView;
@property (weak, nonatomic) IBOutlet UIImageView *orderAmountAnchorLine;
@property (weak, nonatomic) IBOutlet UIImageView *orderAmountTopLine;
@property (weak, nonatomic) IBOutlet UIButton *refundRuleTextButton;
@property (weak, nonatomic) IBOutlet UIImageView *refundRuleImageView;
@property (assign, nonatomic) BOOL isReload;
@property (weak, nonatomic) IBOutlet UILabel *packageNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *singleBottomView;
@property (weak, nonatomic) IBOutlet UIImageView *venuesArrowImageView;
@property (weak, nonatomic) IBOutlet UIButton *venuesButton;
@property (strong, nonatomic) IBOutlet UIImageView *lineImageView;
@property (strong, nonatomic) IBOutlet UIView *singleBottomHolderView;
@property (strong, nonatomic) IBOutlet UIButton *singleQRCodeButton;
@property (weak, nonatomic) IBOutlet UILabel *businessPhoneLabel;

@property (weak, nonatomic) IBOutlet UIView *sportInsuranceHolderView;
@property (weak, nonatomic) IBOutlet UILabel *insuranceContentLabel;

@end

@implementation OrderDetailController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NAME_FINISH_WRITE_REVIEW object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NAME_FINISH_APPLY_REFUND object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NAME_FINISH_PAY_ORDER object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithOrder:(Order *)order
{
    return [self initWithOrder:order isReload:NO];
}

- (id)initWithOrder:(Order *)order isReload:(BOOL)isReload
{
    self = [super init];
    if (self) {
        self.order = order;
        self.isReload = isReload;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(finishWriteReview:)
                                                     name:NOTIFICATION_NAME_FINISH_WRITE_REVIEW
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(finishApplyRefund:)
                                                     name:NOTIFICATION_NAME_FINISH_APPLY_REFUND
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(finishPayOrder:)
                                                     name:NOTIFICATION_NAME_FINISH_PAY_ORDER
                                                   object:nil];
    }
    return self;
}

- (void)finishPayOrder:(NSNotification *)notification
{
    NSString *orderId = [notification.userInfo objectForKey:@"order_id"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_order.orderId isEqualToString:orderId]) {
            self.order.status = OrderStatusPaid;

            [self updateOrderUI];
        }
    });
}

- (void)finishApplyRefund:(NSNotification *)notification
{
    NSString *orderId = [notification.userInfo objectForKey:@"order_id"];
    NSNumber *status = [notification.userInfo objectForKey:@"refund_status"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_order.orderId isEqualToString:orderId]) {
            self.order.status = OrderStatusRefund;
            self.order.refundStatus = status.intValue;
            
            [self updateOrderUI];
        }
    });
}

- (void)finishWriteReview:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *orderId = [notification.userInfo objectForKey:@"order_id"];
        if ([_order.orderId isEqualToString:orderId]) {
            self.order.commentStatus = CommentStatusAlreadyComment;
            [self updateOrderUI];
        }
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"订单详情";
    [self.useDescriptionLabel setTextColor:[SportColor defaultColor]];
    if (_isReload) {
        self.mainScrollView.hidden = YES;
        [SportProgressView showWithStatus:@"加载中"];
        User *user = [[UserManager defaultManager] readCurrentUser];

        [OrderService queryOrderDetail:self
                               orderId:self.order.orderId
                                userId:user.userId
                               isShare:@"0"];
    } else {
        //删除运动券在订单详情的显示
//        [self queryHotTopic];
    }
    
    [self initBaseUI];
//    [self createRightTopImageButton:[SportImage shareButtonImage]];
}

#pragma mark - OrderServiceDelegate
- (void)didQueryOrderDetail:(NSString *)status
                        msg:(NSString *)msg
                resultOrder:(Order *)resultOrder
{
    self.mainScrollView.hidden = NO;
    [SportProgressView dismiss];
    if ([status isEqualToString:STATUS_SUCCESS]) {
        
        self.order = resultOrder;
        
        [self updateOrderUI];
        //2.0删除运动券在订单详情的显示
//        [self queryHotTopic];
    }
    
    //无数据时的提示
    if (resultOrder == nil) {
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44);
        if ([status isEqualToString:STATUS_SUCCESS]) {
            [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"没有相关数据"];
        } else {
            [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:msg];
        }
    } else {
        [self removeNoDataView];
    }
}

- (void)didClickNoDataViewRefreshButton
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    [OrderService queryOrderDetail:self
                           orderId:self.order.orderId
                            userId:user.userId
                           isShare:@"0"];
}

//2.0删除运动券在订单详情的显示
- (void)queryHotTopic
{
    //如果是特惠订单，则不显示圈子入口
    if (_order.type == OrderTypePackage || _order.type == OrderTypeCourse) {
        return;
    }
    
    [ForumService hotTopic:self
                  venuesId:self.order.businessId
                    userId:[[UserManager defaultManager] readCurrentUser].userId];
}

- (void)didHotTopic:(ForumEntrance *)forumEntrance status:(NSString *)status msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS] && forumEntrance) {
        self.entrance = forumEntrance;
        ForumEntranceView *view = [ForumEntranceView createViewWithForumEntrance:_entrance controller:self];
        [self.forumEntranceHolderView addSubview:view];
        [self.forumEntranceHolderView updateHeight:view.frame.size.height];
        
        [self updateOrderUI];
    }
}

- (void)clickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self updateOrderUI];

}

#define TAG_ACTION_SHEET_SHARE      2014082601
#define TAG_ACTION_SHEET_FORWARD    2014082602
//- (void)clickRightTopButton:(id)sender
//{
//    [MobClickUtils event:umeng_event_order_detail_click_share];
//    
//    ShareContent *shareContent = [[ShareContent alloc] init] ;
//    shareContent.thumbImage = [SportImage appIconImage];
//    shareContent.title = @"推荐一个预订运动场地的应用";
//    shareContent.subTitle = @"趣运动手机客户端，数百间优质球馆在线查询预订，低至1折免预约订场，赶紧来试试吧！";
//    shareContent.content = [NSString stringWithFormat:@"%@%@", shareContent.title, shareContent.subTitle];
//    shareContent.linkUrl = @"http://m.quyundong.com";
//    
//    [ShareView popUpViewWithContent:shareContent channelList:@[@(ShareChannelWeChatTimeline), @(ShareChannelSina),@(ShareChannelQQ)] viewController:self delegate:nil];
//}


#define TAG_BACKGROUND_IMAGEVIEW    102
#define TAG_LINE                    300
#define TAG_LINE_VERTICAL           301
- (void)updateLineImageView:(UIView *)view
{
    if ([view isKindOfClass:[UIImageView class]]) {
        if (view.tag == TAG_LINE) {
//            [(UIImageView *)view setImage:[SportImage lineImage]];
            [(UIImageView *)view setBackgroundColor:[UIColor hexColor:@"f5f5f9"]];
            [(UIImageView *)view updateHeight:0.5f];
        } else if (view.tag == TAG_LINE_VERTICAL) {
//            [(UIImageView *)view setImage:[SportImage lineVerticalImage]];
            [(UIImageView *)view setBackgroundColor:[UIColor hexColor:@"f5f5f9"]];
            [(UIImageView *)view updateWidth:0.5f];
        }
    }
}

- (void)initBaseUI
{
    //设置所有holderview的背景、横线
    for (UIView *firstSubview in self.mainScrollView.subviews) {
        for (UIView *secondSubiew in firstSubview.subviews) {
            [self updateLineImageView:secondSubiew];
            
            //圆角背景图
            if (secondSubiew.tag == TAG_BACKGROUND_IMAGEVIEW && [secondSubiew isKindOfClass:[UIImageView class]]) {
                [(UIImageView *)secondSubiew setImage:[SportImage whiteBackgroundImage]];
            }
            
            for (UIView *thirdSubView in secondSubiew.subviews) {
                [self updateLineImageView:thirdSubView];
                for (UIView *fourthSubView in thirdSubView.subviews) {
                    [self updateLineImageView:fourthSubView];
                }
            }
        }
    }
    
    for (UIView *firstSubview in self.bottomHolderView.subviews) {
        [self updateLineImageView:firstSubview];
    }
    
//    [self.payButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateNormal];

//    [self.writeReviewButton setBackgroundImage:[SportImage blueRoundButtonImage] forState:UIControlStateNormal];
//    [self.writeReviewButton setBackgroundImage:[SportImage blueButtonImage] forState:UIControlStateHighlighted];
}

#define SPACE 8
- (void)updateOrderUI
{
    //先检查是否有bottomHolderView，这决定ScrollView的高度
    [self updateBottomHolderView];

    if (_order.isClubPay == YES) {
        self.payWayLabel.text = @"动Club";
    }else{
        if (self.order.type == OrderTypeMembershipCard) {
            self.payWayLabel.text = @"场馆会员卡";
        } else {
            self.payWayLabel.text=@"在线支付";
        }
    }

    CGFloat y = SPACE;
    
    //设置businessHolderView
    if (_order.type == OrderTypePackage) {//特惠
        self.businessHolderView.hidden = YES;
    } else {
        self.businessHolderView.hidden = NO;
        self.businessNameLabel.text = _order.businessName;
        self.addressLabel.text = _order.businessAddress;
        self.businessPhoneLabel.text = _order.businessPhone;
        [self.businessHolderView updateOriginY:y];
        y = y + _businessHolderView.frame.size.height + SPACE;
    }
    
    //不显示圈子，换成球局信息
    if (_order.courtJoin != nil && _order.isCourtJoinParent) {
        _forumEntranceHolderView.hidden = NO;
        if (_forumEntranceHolderView.subviews.count == 0) {
            OrderDetailCourtJoinInfoView *courtJoinInfoView = [OrderDetailCourtJoinInfoView createViewWithOrder:_order delegate:self];
            [courtJoinInfoView updateWidth:[UIApplication sharedApplication].keyWindow.frame.size.width];
            [_forumEntranceHolderView addSubview:courtJoinInfoView];
            [_forumEntranceHolderView updateHeight:courtJoinInfoView.frame.size.height];
        }
        //这里由子view控制SPACE
        [_forumEntranceHolderView updateOriginY:y - SPACE];
        y = y + _forumEntranceHolderView.frame.size.height + SPACE;
    } else {
        _forumEntranceHolderView.hidden = YES;
    }
    
    //设置支付按钮、评论按钮
    if (_order.status == OrderStatusUnpaid) {
        self.payButton.hidden = NO;
        self.writeReviewButton.hidden = YES;
        
        [self.payButton updateOriginY:y];
        y = y + _payButton.frame.size.height + SPACE;
    } else {
        self.payButton.hidden = YES;
        if (_order.commentStatus == CommentStatusValid &&
            (_order.status == OrderStatusUsed || _order.status == OrderStatusExpired || _order.status == OrderStatusPaid)) {
            self.writeReviewButton.hidden = NO;
            
            [self.writeReviewButton updateOriginY:y];
            y = y + _writeReviewButton.frame.size.height + SPACE;
        } else {
            self.writeReviewButton.hidden = YES;
        }
    }
    
    //设置detailHolderView
    [self.detailHolderView updateOriginY:y];
    self.venuesArrowImageView.hidden = NO;
    self.venuesButton.enabled = YES;
    
//    if (_order.type == OrderTypeSingle || _order.type == OrderTypeCourse){
//        self.useDescriptionLabel.text = @"使用说明";
//    }else{
        self.useDescriptionLabel.text = @"图文详情";
//    }
    
    
    if (_order.type == OrderTypeSingle || _order.type == OrderTypePackage || _order.type == OrderTypeCourse) {
        self.singleHolderView.hidden = NO;
        self.defaultHolderView.hidden = YES;

        if (_order.type == OrderTypeSingle || _order.type == OrderTypePackage) {
            //人次或特惠
            self.packageNameLabel.text = @"套餐：";
            self.amountTimeLabel.text = @"数量：";
            self.goodsNameLabel.text = _order.goodsName;
            self.countLabel.text = [NSString stringWithFormat:@"%d", _order.count];
        } else {
            //课程
            self.packageNameLabel.text = @"课程名称：";
            self.amountTimeLabel.text = @"上课时间：";
            
            self.goodsNameLabel.text = _order.goodsName;
            NSString *startTimeString = [DateUtil stringFromDate:self.order.courseStartTime DateFormat:@"yyyy.MM.dd HH:mm"];
            NSString *endTimeString = [DateUtil stringFromDate:self.order.courseEndTime DateFormat:@"HH:mm"];
            self.countLabel.text = [NSString stringWithFormat:@"%@-%@",startTimeString,endTimeString];
            
            //课程订单不跳转场馆
            self.venuesArrowImageView.hidden = YES;
            self.venuesButton.enabled = NO;
        }

        if (_order.isClubPay == YES) {
            self.orderAmountView.hidden = YES;
            [self.singleBottomView updateOriginY:_orderAmountAnchorLine.frame.origin.y];
            //[self.orderAmountView updateOriginY:_orderAmountAnchorLine.frame.origin.y + _defaultHolderView.frame.size.height];
            [self.singleHolderView updateHeight:CGRectGetMaxY(_singleBottomView.frame)];
        } else {
            self.orderAmountView.hidden = NO;
            [self.orderAmountView updateOriginY:_orderAmountAnchorLine.frame.origin.y + _defaultHolderView.frame.size.height];
        }
        
        [self.detailHolderView updateHeight:_singleHolderView.frame.origin.y + _singleHolderView.frame.size.height];
    } else {
        self.singleHolderView.hidden = YES;
        self.defaultHolderView.hidden = NO;
        self.amountHolderView.hidden = NO;
        self.orderAmountTopLine.hidden = NO;
        self.categoryLabel.text = _order.categoryName;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        self.useDateLabel.text = [dateFormatter stringFromDate:_order.useDate];
        
        NSInteger tag = 2014112701;
        if (tag) {
            UIView *view = [self.defaultHolderView viewWithTag:tag];
            [view removeFromSuperview];
        }
        
        ProductDetailGroupView *view = [ProductDetailGroupView createProductDetailGroupView];

        view.tag = tag;
        
        BOOL showPrice = YES;
        if (self.order.type == OrderTypeMembershipCard) {
            showPrice = NO;
        }
        
        [view updateViewWithOrder:_order showPrice:showPrice];
        [view updateOriginX:0];
        [view updateOriginY:43];
        [self.defaultHolderView addSubview:view];

        [self.defaultHolderView updateHeight: 43 + view.frame.size.height];
        
        if (_order.type == OrderTypeMembershipCard) { //会员订单隐藏价格
            self.orderAmountView.hidden = YES;
            [self.detailHolderView updateHeight:self.defaultHolderView.frame.origin.y+ self.defaultHolderView.frame.size.height];

        } else {
            self.orderAmountView.hidden = NO;
            [self.orderAmountView updateOriginY:self.defaultHolderView.frame.origin.y + self.defaultHolderView.frame.size.height];
            [self.detailHolderView updateHeight:self.orderAmountView.frame.origin.y+ self.orderAmountView.frame.size.height];
        }
    }
    
    //有保险的话:
    if (_order.insuranceContent.length > 0) {
        _sportInsuranceHolderView.hidden = NO;
        self.insuranceContentLabel.text = self.order.insuranceContent;
        //保险和价钱
        [_sportInsuranceHolderView updateOriginY:CGRectGetMinY(_orderAmountView.frame)];
        [_orderAmountView updateOriginY:CGRectGetMaxY(_sportInsuranceHolderView.frame)];
        //有图文详情(人次/课程)
        if (_order.type == OrderTypeSingle || _order.type == OrderTypeCourse) {
            CGFloat singleBottomOriginY;
            if (_order.isClubPay) {//动Club没有价钱
                singleBottomOriginY = CGRectGetMinY(_orderAmountAnchorLine.frame) + CGRectGetHeight(_sportInsuranceHolderView.frame);
            } else {
                
                singleBottomOriginY = CGRectGetMaxY(_orderAmountAnchorLine.frame) + CGRectGetHeight(_orderAmountView.frame) + CGRectGetHeight(_sportInsuranceHolderView.frame);
            }
            //图文详情
            [_singleBottomView updateOriginY:singleBottomOriginY];
            //图文详情父view
            [_singleHolderView updateHeight:CGRectGetMaxY(_singleBottomView.frame) + 0];
            //消费明细holder
            [self.detailHolderView updateHeight:CGRectGetMaxY(_singleHolderView.frame) + 1];
        } else {
            [self.detailHolderView updateHeight:CGRectGetMaxY(_orderAmountView.frame)];
        }
    } else {
        _sportInsuranceHolderView.hidden = YES;
    }
    
    [(UIImageView *)[_detailHolderView viewWithTag:TAG_BACKGROUND_IMAGEVIEW] updateHeight:_detailHolderView.frame.size.height];
    y = y + _detailHolderView.frame.size.height + SPACE;
    self.totalPriceLabel.text = [NSString stringWithFormat:@"%@元", [PriceUtil toValidPriceString:_order.totalAmount]];
    
    //设置orderHoderView;
    if (self.order.type == OrderTypeMembershipCard) {
        self.consumeCodeHolderView.hidden = YES;
        [self.orderBottomHolderView updateOriginY:43];
        [self.orderHoderView updateHeight:self.orderBottomHolderView.frame.origin.y + self.orderBottomHolderView.frame.size.height];
        //[[self.orderHoderView viewWithTag:TAG_BACKGROUND_IMAGEVIEW] updateHeight:172];
    } else {
        self.consumeCodeLabel.text = ([_order.consumeCode length] > 0 ? _order.consumeCode : @"暂无");
    }
    self.orderNumberLabel.text = _order.orderNumber;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    self.orderTimeLabel.text = [dateFormatter stringFromDate:_order.createDate];
    self.orderStatusLabel.text = [_order orderStatusText];
   // self.payWayLabel.text=_order.consumeCode;
    
    [self.orderHoderView updateOriginY:y];
    y = y + _orderHoderView.frame.size.height + SPACE;
    
    //动Club订单，orderType可能为OrderTypeSingle或者OrderTypeCourse
    if (_order.isClubPay == YES) {
        if (_order.status == OrderStatusPaid) {
            //设置cardRefundButton
            self.refundHolderView.hidden = YES;
            self.refundButton.hidden = YES;
            [self.cardRefundButton setTitle:@"取消订单" forState:UIControlStateNormal];
            [self.cardRefundButton setTitleColor:[SportColor defaultColor] forState:UIControlStateNormal];
            self.cardRefundButton.hidden = NO;
            [self.cardRefundButton updateOriginY:y];
            y = y + _cardRefundButton.frame.size.height + SPACE;
        } else {
            self.cardRefundButton.hidden = YES;
        }
    } else if (_order.type == OrderTypeMembershipCard) {
        
        //已用会员卡支付订单且允许会员卡退订的场馆
        if (_order.status == OrderStatusCardPaid && _order.refundStatus != RefundStatusMembershipCardRefundDisable) {
            [self.cardRefundButton setBackgroundImage:[SportImage grayFrameButtonImage] forState:UIControlStateDisabled];

            if (_order.refundStatus == RefundStatusRefundIn30d || _order.refundStatus == RefundStatusExpire) {
                
                self.cardRefundButton.enabled = NO;
                [self.cardRefundButton.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
                [self.cardRefundButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
                
                NSString *mainTitle = @"无法退订";
                NSString *subTitle = @"";
                if (_order.refundStatus == RefundStatusRefundIn30d) {
                    subTitle = [NSString stringWithFormat:@"30天之内仅可退订%d次",self.order.monthRefundTimes];
                } else {
                    subTitle = @"已超过退订期限";
                }
                
                NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@\n%@",mainTitle,subTitle] attributes:@{NSForegroundColorAttributeName:[SportColor content2Color]}];
                
                [attributedTitle addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} range:NSMakeRange(0, [mainTitle length])];
                [attributedTitle addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10]} range:NSMakeRange([mainTitle length]+1,[subTitle length])];
                
                [self.cardRefundButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
            } else {
                [self.cardRefundButton setTitle:@"取消订单" forState:UIControlStateNormal];
                [self.cardRefundButton setTitleColor:[SportColor defaultColor] forState:UIControlStateNormal];
            }

            self.cardRefundButton.hidden = NO;
            [self.cardRefundButton updateOriginY:y];
            y = y + _cardRefundButton.frame.size.height + SPACE;
             
        } else {
            self.cardRefundButton.hidden = YES;
        }
    } else {
        //设置refundHolderView
        if ((_order.status == OrderStatusPaid || _order.status == OrderStatusRefund)) {
            if (_order.canRefund) {
                self.refundRuleTextButton.hidden = NO;
                self.refundRuleImageView.hidden = NO;
                [self.refundImageView setImage:[SportImage markButtonImage]];
                self.refundDescLabel.textColor = [SportColor defaultColor];
                self.refundDescLabel.text = @"支持退款";
            }
            else {
                self.refundRuleTextButton.hidden = YES;
                self.refundRuleImageView.hidden = YES;
                [self.refundImageView setImage:[SportImage canNotImage]];
                self.refundDescLabel.textColor = [SportColor content2Color];
                self.refundDescLabel.text = @"不支持退款";
                
            }
            
            self.refundHolderView.hidden = NO;
            [self.refundHolderView updateOriginY:y];
            y = y + _refundHolderView.frame.size.height + SPACE;
        }
        else {
            self.refundHolderView.hidden = YES;
        }
        
        //设置refundButton
//        [self.refundButton setBackgroundImage:[SportImage blueRoundButtonImage] forState:UIControlStateNormal];
//        [self.refundButton setBackgroundImage:[SportImage grayFrameButtonImage] forState:UIControlStateDisabled];
        [self.refundButton updateOriginY:y];
        y = y + _refundButton.frame.size.height + SPACE;
        
        if ((_order.status == OrderStatusPaid && _order.canRefund)
            || _order.status == OrderStatusRefund) {
            
            self.refundButton.hidden = NO;
            [self updateRefundButtonTitle];
            
        } else {
            self.refundButton.hidden = YES;
        }
    }
    
    [self.mainScrollView setContentSize:CGSizeMake(self.mainScrollView.frame.size.width, y)];
}

- (IBAction)clickBusinessButton:(id)sender {
    [MobClickUtils event:umeng_event_order_detail_click_business];
    
    BusinessDetailController *controller = [[BusinessDetailController alloc] initWithBusinessId:_order.businessId categoryId:_order.categoryId] ;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)clickAddressButton:(id)sender {
    BusinessMapController *controller = [[[BusinessMapController alloc] init] initWithLatitude:_order.latitude
                                                                                      longitude:_order.longitude
                                                                                   businessName:_order.businessName
                                                                                businessAddress:_order.businessAddress
                                                                                parkingLotList:nil
                                                                                    businessId:_order.businessId
                                                                                    categoryId:_order.categoryId
                                                                                          type:0];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)clickBusinessPhoneButton:(id)sender {
    BOOL result = [UIUtils makePromptCall:_order.businessPhone];
    if (result == NO) {
        [SportPopupView popupWithMessage:@"此设备不支持打电话"];
    }
}

- (IBAction)clickUseDescriptionButton:(id)sender {
    NSString *title = @"";
    if (_order.type == OrderTypeSingle || _order.type == OrderTypeCourse) {
        title = @"套餐详情";
    }else{
        title = @"图文详情";
    }
    SportWebController *controller = [[SportWebController alloc] initWithUrlString:_order.detailUrl title:title];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)clickPayButton:(id)sender {
    PayController *controller = [[PayController alloc] initWithOrder:_order];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)clickWriteReviewButton:(id)sender {
    WriteReviewController *controller = [[WriteReviewController alloc] initWithBusinessId:_order.businessId businessName:_order.businessName orderId:_order.orderId] ;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)clickLookUpInsuranceButton:(UIButton *)sender {
    // status=2表示从订单详情进入
    NSString *warpUrlString = [NSString stringWithFormat:@"%@&status=2", _order.insuranceUrl];
    SportWebController *webController = [[SportWebController alloc] initWithUrlString:warpUrlString title:nil channelList:[NSArray arrayWithObjects:@(ShareChannelWeChatSession), @(ShareChannelQQ), @(ShareChannelSMS), nil]];
    [self.navigationController pushViewController:webController animated:YES];
}


- (void)updateBottomHolderView
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
//    [self.forwardButton setBackgroundImage:[SportImage blueRoundButtonImage] forState:UIControlStateNormal];
//    [self.forwardButton setBackgroundImage:[SportImage blueButtonImage] forState:UIControlStateHighlighted];
//    
//    [self.qrCodeButton setBackgroundImage:[SportImage blueRoundButtonImage] forState:UIControlStateNormal];
//    [self.qrCodeButton setBackgroundImage:[SportImage blueButtonImage] forState:UIControlStateHighlighted];
    
//    [self.singleQRCodeButton setBackgroundImage:[SportImage blueRoundButtonImage] forState:UIControlStateNormal];
//    [self.singleQRCodeButton setBackgroundImage:[SportImage blueButtonImage] forState:UIControlStateHighlighted];
    
    if (_order.status == OrderStatusPaid
        || _order.status == OrderStatusRefund) {
        
        if (_order.type == OrderTypeSingle || _order.type == OrderTypeCourse) {
            self.bottomHolderView.hidden = YES;
            [self.bottomHolderView updateOriginY:[UIScreen mainScreen].bounds.size.height - 20 - 44 - _bottomHolderView.frame.size.height];
            
            //没有验证码
            if ([_order.consumeCode length] > 0) {
                self.singleBottomHolderView.hidden = NO;
                [self.singleBottomHolderView updateOriginY:[UIScreen mainScreen].bounds.size.height - 20 - 44 - _singleBottomHolderView.frame.size.height];
            } else {
                self.singleBottomHolderView.hidden = YES;
                
            }
        }else{
            self.bottomHolderView.hidden = NO;
            [self.bottomHolderView updateOriginY:[UIScreen mainScreen].bounds.size.height - 20 - 44 - _bottomHolderView.frame.size.height];
            self.singleBottomHolderView.hidden = YES;
            [self.singleBottomHolderView updateOriginY:[UIScreen mainScreen].bounds.size.height - 20 - 44 - _singleBottomHolderView.frame.size.height];
        }
        
        [self.mainScrollView updateHeight:[UIScreen mainScreen].bounds.size.height - 20 - 44 - _bottomHolderView.frame.size.height];
        if (_order.status == OrderStatusRefund) {
            self.bottomHolderView.hidden = YES;
            self.singleBottomHolderView.hidden = YES;
            
        } else {
            self.forwardButton.frame = CGRectMake(30, 7, (screenWidth - 90) / 2, _forwardButton.frame.size.height);
            self.qrCodeButton.frame = CGRectMake(self.forwardButton.frame.size.width + self.forwardButton.frame.origin.x + 30, 7, (screenWidth - 90) / 2, _forwardButton.frame.size.height);
        }
        
    } else {
        self.bottomHolderView.hidden = YES;
        self.singleBottomHolderView.hidden = YES;
        [self.mainScrollView updateHeight:[UIScreen mainScreen].bounds.size.height - 20 - 44];
    }
}

- (void)updateRefundButtonTitle
{
    self.refundButton.enabled = YES;
    [self.refundButton setTitleColor:[SportColor defaultColor] forState:UIControlStateNormal];

    [self.refundButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    if (_order.refundStatus == RefundStatusRefunding) {
        [self.refundButton setTitle:@"退款中" forState:UIControlStateNormal];
    } else if (_order.refundStatus == RefundStatusAlreadyRefund) {
        [self.refundButton setTitle:@"已退款" forState:UIControlStateNormal];
    } else if (_order.refundStatus == RefundStatusUnrefund){
        [self.refundButton setTitle:@"申请退款" forState:UIControlStateNormal];
    } else if (_order.refundStatus == RefundStatusRefundIn30d || _order.refundStatus == RefundStatusExpire) {
        self.refundButton.enabled = NO;
        [self.refundButton.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.refundButton.titleLabel setTextAlignment:NSTextAlignmentCenter];

        NSString *mainTitle = @"无法退款";
        NSString *subTitle = @"";
        if (_order.refundStatus == RefundStatusRefundIn30d) {
            subTitle = [NSString stringWithFormat:@"30天之内仅可退款或换场%d次",self.order.monthRefundTimes];
        } else {
            subTitle = @"已超过退款期限";
        }
        
        NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@\n%@",mainTitle,subTitle] attributes:@{NSForegroundColorAttributeName:[SportColor content2Color]}];
        
        [attributedTitle addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} range:NSMakeRange(0, [mainTitle length])];
        [attributedTitle addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10]} range:NSMakeRange([mainTitle length]+1,[subTitle length])];
        
        [self.refundButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
    }
    
}

- (void)updateRefundView{
    
}

- (IBAction)clickForwardButton:(id)sender {
    [MobClickUtils event:umeng_event_order_detail_click_forward];
    
    ShareContent *shareContent = [[ShareContent alloc] init] ;
    shareContent.thumbImage = [UIImage imageNamed:@"ForwardOrder"];
    shareContent.title = @"场地搞定了,就等你了!";
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM月dd日"];
    
    NSString *st = [formatter stringFromDate:_order.useDate];
    
    shareContent.content = [NSString stringWithFormat:@"场馆名:%@ ,使用日期:%@ 点击查看订单详情(含订单信息，注意信息安全)",_order.businessName,st];
    shareContent.subTitle= [NSString stringWithFormat:@"场馆名:%@ ,使用日期:%@ 点击查看订单详情(含订单信息，注意信息安全)",_order.businessName,st];
    
    shareContent.linkUrl = _order.shareUrl;
    
//    ShareContent *shareContent = [[ShareContent alloc] init] ;
//    shareContent.content = [_order createForwardText];
    
    [ShareView popUpViewWithContent:shareContent channelList:@[@(ShareChannelWeChatSession), @(ShareChannelQQ), @(ShareChannelSMS)] viewController:self delegate:nil];
}

- (IBAction)clickQrCodeButton:(id)sender {
    [MobClickUtils event:umeng_event_order_detail_click_qrcode];

    QrCodeView *view = [QrCodeView createQrCodeViewWithCode:_order.consumeCode];
    [view showWithOrderCodeView];
}

#define TAG_ALERTVIEW_ORDER_REFUND    2015081919
- (IBAction)clickRefundButton:(id)sender {
    [MobClickUtils event:umeng_event_order_detail_click_refund];
    
    if (_order.status == OrderStatusRefund) {
        [OrderService getRefundStatus:self userId:[[UserManager defaultManager] readCurrentUser].userId orderId:_order.orderId];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"你确定吗？" message:[NSString stringWithFormat:@"30天内只能使用%d次退款或换场功能",self.order.monthRefundTimes] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = TAG_ALERTVIEW_ORDER_REFUND;
        [alertView show];
    }
}

#define TAG_ALERTVIEW_CARD_REFUND    2015050501
#define TAG_ALERTVIEW_CLUB_REFUND    2015081516
- (IBAction)clickCardRefundButton:(id)sender {
    
    if (self.order.isClubPay) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"真的要取消订单吗?" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
        alertView.tag = TAG_ALERTVIEW_CLUB_REFUND;
        [alertView show];
    } else {
        [MobClickUtils event:umeng_event_order_detail_click_card_refund];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"真的要退订吗?" delegate:self cancelButtonTitle:@"不退订" otherButtonTitles:@"退订", nil];
        alertView.tag = TAG_ALERTVIEW_CARD_REFUND;
        [alertView show];
    }
}

- (void)didApplyUserCardRefund:(NSString *)status msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [MobClickUtils event:umeng_event_order_detail_card_refund_success];
        [SportProgressView dismissWithSuccess:@"退场成功"];
        self.order.status = OrderStatusCancelled;
        [self updateOrderUI];
    } else {
        [SportProgressView dismissWithError:msg];
    }
}

- (IBAction)clickRefundRuleButton:(id)sender {
    [MobClickUtils event:umeng_event_order_detail_click_refund_rule];
    
    SportWebController *controller = [[SportWebController alloc] initWithUrlString:[[BaseConfigManager defaultManager] refundRuleUrl] title:@"退款规则"] ;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didGetRefundStatus:(NSString *)status
                       msg:(NSString *)msg
              refundStatus:(int)refundStatus
              refundAmount:(float)refundAmount
                 refundWay:(NSString *)refundWay
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismiss];
        
        
        RefundController *controller = [[RefundController alloc] initWithStatus:refundStatus
                                                                       refundWay:refundWay
                                                                          amount:refundAmount] ;
        [self.navigationController pushViewController:controller animated:YES];
    } else
    {
        [SportProgressView dismissWithError:msg];
    }
}


#define TAG_ALERTVIEW_REFUND    2015031701
- (void)didCheckOrderRefund:(NSString *)status
                        msg:(NSString *)msg
               refundAmount:(float)refundAmount
              refundWayList:(NSArray *)refundWayList
            refundCauseList:(NSArray *)refundCauseList
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismiss];

        RefundController *controller = [[RefundController alloc] initWithAmount:refundAmount
                                                                   refundWayList:refundWayList
                                                                 refundCauseList:refundCauseList
                                                                         orderId:_order.orderId];
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        if ([status isEqualToString:@"0311"]
            || [status isEqualToString:@"0312"]) {
            [SportProgressView dismiss];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:msg
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"确定", @"退款规则", nil];
            alertView.tag = TAG_ALERTVIEW_REFUND;
            [alertView show];
            
        } else {
            [SportProgressView dismissWithError:msg];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_ALERTVIEW_REFUND) {
        if (buttonIndex == 1) {
            SportWebController *controller = [[SportWebController alloc] initWithUrlString:[[BaseConfigManager defaultManager] refundRuleUrl] title:@"退款规则"] ;
            [self.navigationController pushViewController:controller animated:YES];
        } else {
            [MobClickUtils event:umeng_event_click_order_details_cancel_order_button];
        }
    } else if (alertView.tag == TAG_ALERTVIEW_CARD_REFUND) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [MobClickUtils event:umeng_event_click_order_details_affirm_refund_window];
            //    if ([[NSDate date] timeIntervalSince1970] > [self.order.lastRefundTime timeIntervalSince1970]) {
            //        [SportPopupView popupWithMessage:@"超过最后允许退订时间"];
            //        return;
            //    }
            
            [SportProgressView showWithStatus:@"申请中"];
            [MembershipCardService applyUserCardRefund:self
                                                userId:[[UserManager defaultManager]
                                                        readCurrentUser].userId
                                               orderId:_order.orderId];
        }else{
            [MobClickUtils event:umeng_event_click_order_details_cancel_refund_window];
        }
    } else if (alertView.tag == TAG_ALERTVIEW_CLUB_REFUND) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            
            //    if ([[NSDate date] timeIntervalSince1970] > [self.order.lastRefundTime timeIntervalSince1970]) {
            //        [SportPopupView popupWithMessage:@"超过最后允许退订时间"];
            //        return;
            //    }
            
            [SportProgressView showWithStatus:@"取消中"];
            [OrderService cancelClubOrder:self
                                    order:_order
                                   userId:[[UserManager defaultManager] readCurrentUser].userId];
        }
    
    } else if (alertView.tag == TAG_ALERTVIEW_ORDER_REFUND) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [SportProgressView showWithStatus:@"加载中"];
            
            if (_order.status != OrderStatusRefund) {
                [OrderService checkOrderRefund:self
                                        userId:[[UserManager defaultManager] readCurrentUser].userId
                                       orderId:_order.orderId];
            }
        }
    }
}

- (void)didCancelClubOrder:(NSString *)status
                       msg:(NSString *)msg
                   orderId:(NSString *)orderId
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        //[MobClickUtils event:umeng_event_order_detail_card_refund_success];
        [SportProgressView dismissWithSuccess:@"取消成功"];
        self.order.status = OrderStatusCancelled;
        [self updateOrderUI];
    } else {
        [SportProgressView dismissWithError:msg];
    }
}

- (void)orderDetailCourtJoinInfoViewDidChangeHeight:(CGFloat)height {
    [_forumEntranceHolderView updateHeight:height];
    [self updateOrderUI];
}

- (IBAction)clickOrderAmountDetailButton:(id)sender {
    
    // crash in IOS 6, just workaround here, invesgate later
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_7_0)
    {
        return;
    }
    OrderAmountView *view = [OrderAmountView createOrderAmountViewWithOrder:_order];
    [view show];
}

@end
