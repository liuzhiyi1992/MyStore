//
//  OrderDetailsController.m
//  Sport
//
//  Created by lzy on 16/8/1.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "OrderDetailsController.h"
#import "Order.h"
#import "OrderDetailViewVenue.h"
#import "OrderDetailViewSingle.h"
#import "OrderDetailPayInventoryView.h"
#import "OrderDetailPhoneNumberView.h"
#import "Product.h"
#import "OrderDetailBusinessInfoView.h"
#import "OrderService.h"
#import "SportProgressView.h"
#import "UserManager.h"
#import "SponsorCourtJoinView.h"
#import "OrderDetailCourtJoinInfoView.h"
#import "OrderDetailQRCodeView.h"
#import "BaseConfigManager.h"
#import "SportWebController.h"
#import "RefundController.h"
#import "MembershipCardService.h"
#import "SportPopupView.h"
#import "UIUtils.h"
#import "SponsorCourtJoinEditingView.h"
#import "UIViewController+SportNavigationItem.h"
#import "CollectAndShareButtonView.h"
#import <objc/runtime.h>
#import "PayController.h"
#import "SportColor.h"

#define PLACEHOLDER @"PLACEHOLDER"
#define SERVICE_BUTTON_STRING @"联系趣运动客服"
const NSInteger PLACEHOLDER_VIEW_SPACE = 15;
const char KEY_CONSTRAINT_INSERT_SPACE_JUST_NOW;

@implementation OrderDetailPlaceholderView
{
    BOOL _nonExistent;//是否不存在
}
@end

@interface OrderDetailsController () <OrderServiceDelegate, OrderDetailCourtJoinInfoViewDelegate, UIAlertViewDelegate, MembershipCardServiceDelegate>
@property (weak, nonatomic) IBOutlet UILabel *orderNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderStatusLabel;
@property (weak, nonatomic) IBOutlet UIView *contentHolderView;
@property (weak, nonatomic) IBOutlet UIButton *refundButton;
@property (weak, nonatomic) IBOutlet UIView *refundRegulationView;
@property (weak, nonatomic) IBOutlet UIButton *refundSupportButton;
@property (weak, nonatomic) IBOutlet UIButton *refundRuleButton;
@property (weak, nonatomic) IBOutlet UIButton *serviceButton;
@property (weak, nonatomic) IBOutlet UIButton *paymentButton;
@property (weak, nonatomic) IBOutlet UIView *networkMaskView;
@property (weak, nonatomic) IBOutlet UIView *orderStatusView;
@property (copy, nonatomic) NSString *verticalVFLString;
@property (copy, nonatomic) NSDictionary *vflLayoutViewsDict;
@property (strong, nonatomic) NSArray *componentViews;
@property (strong, nonatomic) Order *order;
@property (assign, nonatomic) BOOL isReload;
@property (assign, nonatomic) BOOL hadSetupComponent;
@property (assign, nonatomic) BOOL canReplacingCourtJoinInfoView;
@end

@implementation OrderDetailsController
- (id)initWithOrder:(Order *)order {
    return [self initWithOrder:order isReload:NO];
}

- (id)initWithOrder:(Order *)order isReload:(BOOL)isReload {
    self = [super init];
    if (self) {
        self.order = order;
        self.isReload = isReload;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateUI];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"订单详情";
    [self registerNotification];
    [self setupRightTopButton];
    if (_isReload) {
        [SportProgressView showWithStatus:@"加载中"];
        [self queryNewData];
    } else {
        [self setupComponent];
    }
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishApplyRefund:)
                                                 name:NOTIFICATION_NAME_FINISH_APPLY_REFUND
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sponsorCourtJoinSucceed) name:NOTIFICATION_NAME_COURT_JOIN_SUCCESS object:nil];
}

- (void)queryNewData {
    [SportProgressView showWithStatus:@"加载中"];
    User *user = [[UserManager defaultManager] readCurrentUser];
    [_networkMaskView setHidden:NO];
    [OrderService queryOrderDetail:self
                           orderId:self.order.orderId
                            userId:user.userId
                           isShare:@"0"
                        entrance:0];
}

- (void)configurePaymentButton {
    if (_order.status == OrderStatusUnpaid) {
        [_paymentButton setHidden:NO];
    } else {
        [_paymentButton removeFromSuperview];
    }
}

- (void)configureRefundButton {
    if (_order.type != OrderTypeMembershipCard) {
        //非会员卡订单
        if ((_order.status == OrderStatusPaid && _order.canRefund) || _order.status == OrderStatusRefund) {
            [self updateRefundButtonTitle];
        } else {
            //不显示退款按钮
            [_refundButton removeFromSuperview];
        }
    } else if (_order.type == OrderTypeMembershipCard) {
        //会员卡订单
        if (_order.status == OrderStatusCardPaid && _order.refundStatus != RefundStatusMembershipCardRefundDisable) {
            [self updateRefundButtonTitle];
        } else {
            //不显示退款按钮
            [_refundButton removeFromSuperview];
        }
    }
}

- (void)configureRefundRegulationView {
    if (_order.type != OrderTypeMembershipCard && (_order.status == OrderStatusPaid || _order.status == OrderStatusRefund)) {
        //显示
        UIImage *refundSupportImage;
        UIColor *titleColor;
        NSString *titleString;
        BOOL isDisplay;
        if (_order.canRefund) {
            refundSupportImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mark_button@2x.png" ofType:nil]];
            titleColor = [UIColor hexColor:@"5b73f2"];
            titleString = @"支持退款";
            isDisplay = YES;
        } else {
            refundSupportImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"can_not@2x.png" ofType:nil]];
            titleColor = [UIColor hexColor:@"666666"];
            titleString = @"不支持退款";
            isDisplay = NO;
        }
        [_refundSupportButton setImage:refundSupportImage forState:UIControlStateNormal];
        [_refundSupportButton setTitleColor:titleColor forState:UIControlStateNormal];
        [_refundSupportButton setTitle:titleString forState:UIControlStateNormal];
        _refundRuleButton.hidden = !isDisplay;
    } else {
        //不显示
        [_refundRegulationView removeFromSuperview];
    }
}

- (void)setupRightTopButton {
    if (_order.type == OrderTypeDefault && _order.status != OrderStatusUnpaid) {
        CollectAndShareButtonView *rightTopView = [CollectAndShareButtonView createShareButtonView];
        [rightTopView.rightButton addTarget:self action:@selector(clickRightTopButton:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:rightTopView];
        self.navigationItem.rightBarButtonItem = buttonItem;
    }
}

- (void)clickRightTopButton:(id)sender {
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
    [ShareView popUpViewWithContent:shareContent channelList:@[@(ShareChannelWeChatSession), @(ShareChannelQQ), @(ShareChannelSMS)] viewController:self delegate:nil];
}

#define BUTTON_BORDER_COLOR [UIColor hexColor:@"5b73f2"].CGColor
#define BUTTON_BORDER_WIDTH 0.5f
#define BUTTON_CORNER_RADIUS 22
#define BUTTON_BGCOLOR_HIGHTLIGHT [SportColor createImageWithColor:[UIColor hexColor:@"5b73f2"]]
#define BUTTON_TITLECOLOR_HIGHTLIGHT [UIColor whiteColor]
- (void)setupComponent {
    if (_hadSetupComponent) {
        return;
    }
    _refundButton.layer.borderWidth = BUTTON_BORDER_WIDTH;
    _refundButton.layer.borderColor = BUTTON_BORDER_COLOR;
    _refundButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    [_refundButton setBackgroundImage:BUTTON_BGCOLOR_HIGHTLIGHT forState:UIControlStateHighlighted];
    [_refundButton setTitleColor:BUTTON_TITLECOLOR_HIGHTLIGHT forState:UIControlStateHighlighted];
    
    _paymentButton.layer.borderWidth = BUTTON_BORDER_WIDTH;
    _paymentButton.layer.borderColor = BUTTON_BORDER_COLOR;
    _paymentButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    [_paymentButton setBackgroundImage:BUTTON_BGCOLOR_HIGHTLIGHT forState:UIControlStateHighlighted];
    [_paymentButton setTitleColor:BUTTON_TITLECOLOR_HIGHTLIGHT forState:UIControlStateHighlighted];
    
    NSAttributedString *serviceButtonAttrString = [[NSAttributedString alloc] initWithString:SERVICE_BUTTON_STRING attributes:@{NSUnderlineStyleAttributeName:[NSNumber numberWithInt:NSUnderlineStyleSingle], NSForegroundColorAttributeName:[UIColor hexColor:@"5b73f2"], NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    [_serviceButton setAttributedTitle:serviceButtonAttrString forState:UIControlStateNormal];
    
    switch (_order.type) {
        case OrderTypeMembershipCard:
        case OrderTypeDefault:
        {
            UIView *courtJoinView;
            if (_order.courtJoin != nil && _order.isCourtJoinParent) {
                courtJoinView = [OrderDetailCourtJoinInfoView createViewWithOrder:_order delegate:self];
            } else if (_order.courtJoin.sponsorPermission) {
                courtJoinView = [SponsorCourtJoinView createViewWithOrder:_order sponsorType:SponsorTypeOrderDetail];
            } else {
                courtJoinView = [[OrderDetailPlaceholderView alloc] init];
                [courtJoinView setValue:@(YES) forKey:@"_nonExistent"];
            }
            UIView *phoneNumberView;
            if (_order.type != OrderTypeMembershipCard && _order.status != OrderStatusUnpaid) {
                phoneNumberView = [[OrderDetailPhoneNumberView alloc] initWithPhoneNumber:[[UserManager defaultManager] readCurrentUser].phoneNumber];
            } else {
                phoneNumberView = [[OrderDetailPlaceholderView alloc] init];
                [phoneNumberView setValue:@(YES) forKey:@"_nonExistent"];
            }
            
            //setup
            [self setupContentHolderViewWithComponents:
            [OrderDetailViewVenue createViewWithOrder:_order],
            [OrderDetailPayInventoryView createViewWithOrder:_order],
            [[OrderDetailPlaceholderView alloc] init],
            phoneNumberView,
            [[OrderDetailPlaceholderView alloc] init],
            courtJoinView,
            [[OrderDetailPlaceholderView alloc] init],
            [[OrderDetailBusinessInfoView alloc] initWithOrder:_order], nil];
            break;
        }
        case OrderTypeSingle:
        {
            UIView *payInventoryView;
            if (_order.status != OrderStatusUnpaid) {
                payInventoryView = [OrderDetailPayInventoryView createViewWithOrder:_order];
            } else {
                payInventoryView = [[OrderDetailPlaceholderView alloc] init];
                [payInventoryView setValue:@(YES) forKey:@"_nonExistent"];
            }
            UIView *qrcodeView;
            if (_order.status != OrderStatusUnpaid) {
                qrcodeView = [OrderDetailQRCodeView createViewWithVerificationArray:_order.qrCodeList];
            } else {
                qrcodeView = [[OrderDetailPlaceholderView alloc] init];
                [qrcodeView setValue:@(YES) forKey:@"_nonExistent"];
            }
            [self setupContentHolderViewWithComponents:
            [[OrderDetailViewSingle alloc] initWithGoodsName:_order.goodsName goodsPrice:_order.singlePrice count:_order.count detailUrl:_order.detailUrl],
            payInventoryView,
            [[OrderDetailPlaceholderView alloc] init],
            qrcodeView,
            [[OrderDetailPlaceholderView alloc] init],
            [[OrderDetailBusinessInfoView alloc] initWithOrder:_order], nil];
            break;
        }
        default:
            break;
    }
    [self configureUI];
    self.hadSetupComponent = YES;
}

- (void)configureUI {
    [self configureRefundButton];
    [self configurePaymentButton];
    [self configureRefundRegulationView];
    _orderNumberLabel.text = _order.orderNumber;
    if (_order.type != OrderTypeMembershipCard) {
        _orderStatusLabel.text = _order.orderStatusText;
    } else {
        [_orderStatusView removeFromSuperview];
    }
}

- (void)updateUI {
    [self updateRefundButtonTitle];
    _orderStatusLabel.text = _order.orderStatusText;
}

- (void)setupContentHolderViewWithComponents:(UIView *)components, ...NS_REQUIRES_NIL_TERMINATION {
    NSMutableArray *componentViews = [NSMutableArray array];
    [componentViews addObject:components];
    va_list var_list;
    va_start(var_list, components);
    UIView *view;
    while ((view = va_arg(var_list, UIView *))) {
        [componentViews addObject:view];
    }
    va_end(var_list);
    self.componentViews = componentViews;
    
    NSMutableDictionary *layoutViews = [NSMutableDictionary dictionary];
    NSMutableString *vConstraintString = [NSMutableString stringWithString:@"V:|"];
    for (int i = 0; i < componentViews.count; i++) {
        UIView *indexView = componentViews[i];
        if (![indexView isKindOfClass:[OrderDetailPlaceholderView class]]) {
            NSString *className = NSStringFromClass([indexView class]);
            [indexView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [layoutViews setObject:indexView forKey:className];
            [_contentHolderView addSubview:indexView];
            
            //hConstraint
            NSString *hConstraintString = [NSString stringWithFormat:@"H:|[%@]|", className];
            [_contentHolderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:hConstraintString options:NSLayoutFormatAlignAllLeft metrics:nil views:layoutViews]];
            
            //vConstraint
            [vConstraintString appendFormat:@"[%@]", className];
            objc_setAssociatedObject(vConstraintString, &KEY_CONSTRAINT_INSERT_SPACE_JUST_NOW, @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        } else {
            if (![[indexView valueForKey:@"_nonExistent"] boolValue] &&
                ![objc_getAssociatedObject(vConstraintString, &KEY_CONSTRAINT_INSERT_SPACE_JUST_NOW) boolValue]) {
                //space
                [vConstraintString appendFormat:@"-%ld-", (long)PLACEHOLDER_VIEW_SPACE];
                objc_setAssociatedObject(vConstraintString, &KEY_CONSTRAINT_INSERT_SPACE_JUST_NOW, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
    }
    [vConstraintString appendString:@"|"];
    [_contentHolderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vConstraintString options:NSLayoutFormatAlignAllCenterX metrics:nil views:layoutViews]];
    self.verticalVFLString = vConstraintString;
    self.vflLayoutViewsDict = layoutViews;
}

- (void)updateRefundButtonTitle {
    [self enableRefundButton];
    switch (_order.refundStatus) {
        case RefundStatusRefunding:
            [_refundButton setTitle:@"退款中" forState:UIControlStateNormal];
            break;
        case RefundStatusAlreadyRefund:
            [_refundButton setTitle:@"已退款" forState:UIControlStateNormal];
            break;
        case RefundStatusUnrefund:
            if (_order.type != OrderTypeMembershipCard) {
                [_refundButton setTitle:@"申请退款" forState:UIControlStateNormal];
            } else {
                [_refundButton setTitle:@"申请退订" forState:UIControlStateNormal];
            }
            break;
        case RefundStatusRefundIn30d:
        case RefundStatusExpire:
            [self updateRefundButtonCannotRefund];
            break;
        default:
            break;
    }
}

- (void)updateRefundButtonCannotRefund {
    [self disableRefundButton];
    [_refundButton.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [_refundButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    NSString *mainTitle = @"无法退款";
    NSString *subTitle = @"已超过退款期限";
    if (_order.refundStatus == RefundStatusRefundIn30d) {
        subTitle = [NSString stringWithFormat:@"30天之内仅可退款或换场%d次",self.order.monthRefundTimes];
    }
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@\n%@",mainTitle,subTitle]];
    [attributedTitle addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} range:NSMakeRange(0, [mainTitle length])];
    [attributedTitle addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10]} range:NSMakeRange([mainTitle length]+1,[subTitle length])];
    [_refundButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
}

- (void)disableRefundButton {
    _refundButton.enabled = NO;
    _refundButton.layer.borderColor = [UIColor hexColor:@"aaaaaa"].CGColor;
}

- (void)enableRefundButton {
    _refundButton.enabled = YES;
    _refundButton.layer.borderColor = [UIColor hexColor:@"5b73f2"].CGColor;
}

- (void)try2ReplacingCourtJoinInfoView {
    if (_canReplacingCourtJoinInfoView) {
        OrderDetailCourtJoinInfoView *courtjoinInfoView = [OrderDetailCourtJoinInfoView createViewWithOrder:_order delegate:nil];
        [self replacingOccurrencesViewClassString:NSStringFromClass([SponsorCourtJoinView class]) withNewView:courtjoinInfoView];
        self.canReplacingCourtJoinInfoView = NO;
    }
}

- (void)replacingOccurrencesViewClassString:(NSString *)classString withNewView:(UIView *)newView {
    NSString *newClassString = NSStringFromClass([newView class]);
    for (UIView *component in _componentViews) {
        if ([component isKindOfClass:NSClassFromString(classString)]) {
            [component removeFromSuperview];
            [newView setTranslatesAutoresizingMaskIntoConstraints:NO];
            NSMutableDictionary *layoutViews = [NSMutableDictionary dictionaryWithDictionary:_vflLayoutViewsDict];
            [layoutViews setObject:newView forKey:newClassString];
            self.verticalVFLString = [_verticalVFLString stringByReplacingOccurrencesOfString:classString withString:newClassString];
            [_contentHolderView addSubview:newView];
            [_contentHolderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|[%@]|", newClassString] options:0 metrics:nil views:layoutViews]];
            [_contentHolderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:_verticalVFLString options:NSLayoutFormatAlignAllCenterX metrics:nil views:layoutViews]];
            break;
        }
    }
}

- (void)finishApplyRefund:(NSNotification *)notification {
    [self queryNewData];
}

- (void)sponsorCourtJoinSucceed {
    self.canReplacingCourtJoinInfoView = YES;
    User *user = [[UserManager defaultManager] readCurrentUser];
    [OrderService queryOrderDetail:self
                           orderId:self.order.orderId
                            userId:user.userId
                           isShare:@"0"
                          entrance:0];
}

#define TAG_ALERTVIEW_ORDER_REFUND 2015081919
- (IBAction)clickRefundButton:(id)sender {
    if (_order.type != OrderTypeMembershipCard) {
        [self defaultRefund];
    } else {
        [self membershipCardRefund];
    }
}

- (IBAction)clickPayButton:(id)sender {
    PayController *controller = [[PayController alloc] initWithOrder:_order];
    [self.navigationController pushViewController:controller animated:YES];
}


- (IBAction)clickServicesButton:(id)sender {
    BOOL result = [UIUtils makePromptCall:@"4000410480"];
    if (result == NO) {
        [SportPopupView popupWithMessage:@"此设备不支持打电话"];
    }
}

- (IBAction)clickRefundRuleButton:(id)sender {
    [MobClickUtils event:umeng_event_order_detail_click_refund_rule];
    SportWebController *controller = [[SportWebController alloc] initWithUrlString:[[BaseConfigManager defaultManager] refundRuleUrl] title:@"退款规则"];
    [self.navigationController pushViewController:controller animated:YES];
}

#define TAG_ALERTVIEW_CARD_REFUND 2015050501
- (void)membershipCardRefund {
    [MobClickUtils event:umeng_event_order_detail_click_card_refund];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"真的要退订吗?" delegate:self cancelButtonTitle:@"不退订" otherButtonTitles:@"退订", nil];
    alertView.tag = TAG_ALERTVIEW_CARD_REFUND;
    [alertView show];
}

- (void)defaultRefund {
    [MobClickUtils event:umeng_event_order_detail_click_refund];
    if (_order.status == OrderStatusRefund) {
        [OrderService getRefundStatus:self userId:[[UserManager defaultManager] readCurrentUser].userId orderId:_order.orderId];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"你确定吗？" message:[NSString stringWithFormat:@"30天内只能使用%d次退款或换场功能",self.order.monthRefundTimes] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = TAG_ALERTVIEW_ORDER_REFUND;
        [alertView show];
    }
}

- (void)didGetRefundStatus:(NSString *)status
                       msg:(NSString *)msg
              refundStatus:(int)refundStatus
              refundAmount:(float)refundAmount
                 refundWay:(NSString *)refundWay {
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismiss];
        RefundController *controller = [[RefundController alloc] initWithStatus:refundStatus
                                                                      refundWay:refundWay
                                                                         amount:refundAmount] ;
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        [SportProgressView dismissWithError:msg];
    }
}

#pragma - delegate
- (void)didQueryOrderDetail:(NSString *)status msg:(NSString *)msg resultOrder:(Order *)resultOrder {
    [SportProgressView dismiss];
    [_networkMaskView setHidden:YES];
    if ([status isEqualToString:STATUS_SUCCESS]) {
        self.order = resultOrder;
        [self setupRightTopButton];
        [self setupComponent];
        [self try2ReplacingCourtJoinInfoView];
        //更新验证码
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_VERIFICATION_DID_CHANGE object:nil userInfo:@{PARA_QR_CODE_LIST:_order.qrCodeList}];
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

#define TAG_ALERTVIEW_REFUND 2015031701
- (void)didCheckOrderRefund:(NSString *)status
                        msg:(NSString *)msg
               refundAmount:(float)refundAmount
              refundWayList:(NSArray *)refundWayList
            refundCauseList:(NSArray *)refundCauseList
               canRefundNum:(int)canRefundNum
                  priceList:(NSArray *)priceList{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismiss];
        RefundController *controller = [[RefundController alloc] initWithAmount:refundAmount
                                                                  refundWayList:refundWayList
                                                                refundCauseList:refundCauseList
                                                                        orderId:_order.orderId
                                                                      priceList:priceList];
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

- (void)didApplyUserCardRefund:(NSString *)status msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [MobClickUtils event:umeng_event_order_detail_card_refund_success];
        [SportProgressView dismissWithSuccess:@"退场成功"];
        self.order.status = OrderStatusCancelled;
        [self configureUI];
    } else {
        [SportProgressView dismissWithError:msg];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
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
            [SportProgressView showWithStatus:@"申请中"];
            [MembershipCardService applyUserCardRefund:self
                                                userId:[[UserManager defaultManager]
                                                        readCurrentUser].userId
                                               orderId:_order.orderId];
        }else{
            [MobClickUtils event:umeng_event_click_order_details_cancel_refund_window];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
