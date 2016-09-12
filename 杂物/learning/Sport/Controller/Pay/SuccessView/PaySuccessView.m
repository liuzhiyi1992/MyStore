//
//  PaySuccessView.m
//  Sport
//
//  Created by qiuhaodong on 15/6/12.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "PaySuccessView.h"
#import "UIView+SportBackground.h"
#import "UIView+Utils.h"
#import "ForumEntrance.h"
#import "ForumEntranceView.h"
#import "OrderDetailController.h"
#import "MyPointController.h"
#import "ShareContent.h"
#import "ShareView.h"
#import "UserManager.h"
#import "OrderService.h"
#import "NSString+Utils.h"
#import "CoachOrderDetailController.h"
#import "HomeController.h"
#import "Product.h"
#import "Order.h"
#import "SponsorCourtJoinView.h"
#import "PayMethod.h"
#import <objc/runtime.h>
#import "BusinessGoods.h"

NSString * const INSURANCE_TIPS = @"您已购买保险，可在 我的>我的订单>订单详情 中查看并领取，请尽快领取，祝运动愉快！";
int const OFFSET_CONTENT_SIZE_BOTTOM = 20;
const char KEY_SELECTED_PAY_METHOD;
NSString * const PAY_ID_APPLE_PAY = @"19";

@interface PaySuccessView()<OrderServiceDelegate, ShareViewDelegate>

@property (weak, nonatomic) UIViewController *controller;
@property (strong, nonatomic) Order *order;
@property (weak, nonatomic) IBOutlet UILabel *orderInforLabel;
@property (weak, nonatomic) IBOutlet UILabel *OrderNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *OrderTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *showWayLabel;

@property (weak, nonatomic) IBOutlet UILabel *jiFenLabel;
- (IBAction)callFrends:(id)sender;
- (IBAction)backToHome:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *callFrendsButton;
@property (weak, nonatomic) IBOutlet UIButton *orderInfoButton;
@property (weak, nonatomic) IBOutlet UIButton *backToHomeButton;
@property (weak, nonatomic) IBOutlet UIView *applePaySuccessLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodsLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderInfoTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderNameTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderTimeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkNumberTitleLabel;

@end

@implementation PaySuccessView

+ (PaySuccessView *)createViewWithOrder:(Order *)order
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PaySuccessView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    PaySuccessView *view = (PaySuccessView *)[topLevelObjects objectAtIndex:0];
    [view updateWidth:[UIScreen mainScreen].bounds.size.width];
    [view updateHeight:[UIScreen mainScreen].bounds.size.height - 64];
    
    view.scrollEnabled=YES;
    
    [view sportUpdateAllBackground];
    view.order = order;
    
    view.callFrendsButton.layer.borderColor = [UIColor hexColor:@"5b73f2"].CGColor;
    [view.callFrendsButton addTarget:view action:@selector(callFrends:) forControlEvents:UIControlEventTouchUpInside];
    
    view.orderInfoButton.layer.borderColor = [UIColor hexColor:@"666666"].CGColor;
    [view.orderInfoButton addTarget:view action:@selector(viewOrderInfo:) forControlEvents:UIControlEventTouchUpInside];
    
    //callFrendsButton orderInfoButton 布局
    CGFloat screemWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat buttonWidth = 0.4 * screemWidth;
    CGFloat margin = (screemWidth - 2 * buttonWidth) / 3;
    [view.callFrendsButton updateWidth:buttonWidth];
    [view.orderInfoButton updateWidth:buttonWidth];
    [view.callFrendsButton updateOriginX:margin];
    [view.orderInfoButton updateOriginX:CGRectGetMaxX(view.callFrendsButton.frame) + margin];
    UILabel *topCheckNumberLabel = view.placeLabel;
    
    if (order.type == OrderTypeCoach) {//约练
        view.orderInforLabel.text=[NSString stringWithFormat:@"%@",order.coachName];
        view.orderInfoTitleLabel.text = @"姓名：";
        view.OrderNameLabel.text=[NSString stringWithFormat:@"%@",order.coachCategory];
        view.orderNameTitleLabel.text = @"项目: ";
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM月dd日 HH:mm"];
        NSString *st = [formatter stringFromDate:order.coachStartTime];
        NSString *et=[formatter stringFromDate:order.coachEndTime];
        NSArray *array = [et componentsSeparatedByString:@" "];
        NSString *endt=array[1];
        view.OrderTimeLabel.text=[NSString stringWithFormat:@"%@-%@",st,endt];
        view.orderTimeTitleLabel.text = @"日期: ";
        view.placeTitleLabel.hidden = YES;
        view.placeLabel.hidden=YES;
        view.checkNumberTitleLabel.hidden = YES;
        view.checkNumberLabel.hidden=YES;
        view.orderInfoButton.hidden = YES;
        [view hideCallFrendButton];
    }else if(order.type == OrderTypeCourse){//课程订单
        view.orderInforLabel.text=[NSString stringWithFormat:@"%@",order.businessName];
        view.orderInfoTitleLabel.text = @"场馆: ";
        view.OrderNameLabel.text=[NSString stringWithFormat:@"%@",order.coachCategory];
        view.orderNameTitleLabel.text = @"项目: ";
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM月dd日 HH:mm"];
        NSString *st = [formatter stringFromDate:order.coachStartTime];
        NSString *et=[formatter stringFromDate:order.coachEndTime];
        NSArray *array = [et componentsSeparatedByString:@" "];
        NSString *endt=array[1];

        view.OrderTimeLabel.text=[NSString stringWithFormat:@"%@-%@",st,endt];
        view.orderTimeTitleLabel.text = @"日期: ";
           NSString *s =[order.consumeCode isEqualToString:@""]?@"-":order.consumeCode;
        view.placeTitleLabel.text = @"验证码：";
        view.placeLabel.text=[NSString stringWithFormat:@"%@",s];
        view.checkNumberTitleLabel.hidden = YES;
        view.checkNumberLabel.hidden=YES;
        [view hideCallFrendButton];
    }else if(order.type == OrderTypeDefault || order.type == OrderTypeMembershipCard || order.type == OrderTypeCourtJoin) {
        //羽足乒网蓝壁 球局
        NSString *shareTitle=order.shareBtnMsg.length>0?order.shareBtnMsg:@"通知朋友们";
        [view.callFrendsButton setTitle:shareTitle forState:UIControlStateNormal];
        view.orderInforLabel.text=[NSString stringWithFormat:@"%@",order.businessName];
        view.orderInfoTitleLabel.text = @"场馆: ";

        view.OrderNameLabel.text=[NSString stringWithFormat:@"%@",order.categoryName];
        view.orderNameTitleLabel.text = @"项目: ";
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM月dd日"];
        NSString *st = [formatter stringFromDate:order.useDate];
        view.OrderTimeLabel.text=[NSString stringWithFormat:@"%@",st];
        view.orderTimeTitleLabel.text = @"日期: ";
        NSString *s1=[[NSString alloc] init];
        int number = 0;
        for (Product * p in order.productList) {
            NSString *s=[NSString stringWithFormat:@"%@(%@)\n",p.courtName,p.startTimeToEndTime];
            s1=[s1 stringByAppendingString:s];
            number ++;
        }

        s1= [ s1 substringToIndex:([s1 length]-1)];
        view.placeTitleLabel.text = @"场次：";
        view.placeLabel.text = [NSString stringWithFormat:@"%@",s1];
        CGSize placeLabelSize = [view.placeLabel.text boundingRectWithSize:CGSizeMake(view.placeLabel.bounds.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:view.placeLabel.font} context:nil].size;
        [view.placeLabel updateHeight:placeLabelSize.height];
        
        if ([order.goodsList count] > 0) {
            view.goodsTitleLabel.hidden = NO;
            view.goodsLabel.hidden = NO;
            [view.goodsLabel updateOriginY:view.placeLabel.frame.origin.y + view.placeLabel.frame.size.height + 5];
            [view.goodsTitleLabel updateOriginY:view.goodsLabel.frame.origin.y];
            topCheckNumberLabel = view.goodsLabel;
            NSString *s2=[[NSString alloc] init];
            number = 0;
            for (BusinessGoods * g in order.goodsList) {
                NSString *s=[NSString stringWithFormat:@"%@×%d\n",g.name,g.totalCount];
                s2=[s2 stringByAppendingString:s];
                number ++;
            }
            
            s2= [s2 substringToIndex:([s2 length]-1)];
            view.goodsLabel.text = [NSString stringWithFormat:@"%@",s2];
            CGSize goodsLabelSize = [view.goodsLabel.text boundingRectWithSize:CGSizeMake(view.goodsLabel.bounds.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:view.goodsLabel.font} context:nil].size;
            [view.goodsLabel updateHeight:goodsLabelSize.height];
        
        }else {
            view.goodsLabel.hidden = YES;
            view.goodsTitleLabel.hidden = YES;

        }
        
        //验证码
        NSString *s =[order.consumeCode isEqualToString:@""]?@"-":order.consumeCode;
        
        view.checkNumberTitleLabel.text = @"验证码：";
        if (order.type == OrderTypeMembershipCard) {
            view.checkNumberLabel.text=[NSString stringWithFormat:@"会员卡"];
            [view hideCallFrendButton];
        } else if (order.type == OrderTypeCourtJoin) {
                
            [MobClickUtils event:umeng_event_court_join_pay_success];
            //callFrendsButton
            [view hideCallFrendButton];
            view.checkNumberLabel.text = [NSString stringWithFormat:@"-"];
            
        } else {
            
            NSString *phone = [[UserManager defaultManager] readCurrentUser].phoneNumber;
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:phone];
            [str addAttribute:NSForegroundColorAttributeName value:[SportColor defaultColor] range:NSMakeRange(phone.length -4,4)];
            
            NSAttributedString *tipsStr = [[NSAttributedString alloc]initWithString:@"  凭预定手机号后4位验证开场" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10.0],NSForegroundColorAttributeName:[SportColor content2Color]}];
            [str appendAttributedString:tipsStr];
            
            view.checkNumberLabel.attributedText = str;
            view.callFrendsButton.hidden = NO;
        }
        
    }else if(order.type == OrderTypeMonthCardRecharge){//购买动Club
        [view hideCallFrendButton];
        view.jiFenLabel.hidden=YES;
        view.showWayLabel.hidden=YES;
        view.orderInforLabel.text=[NSString stringWithFormat:@"%d个月",order.count];
        view.orderInfoTitleLabel.text = @"会员期限: ";

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy年MM月dd日"];
        NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[order.clubEndTime integerValue]];
        NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];

        view.OrderNameLabel.text=[NSString stringWithFormat:@"%@", confromTimespStr];
        view.orderNameTitleLabel.text = @"到期时间：";
        view.orderTimeTitleLabel.hidden = YES;
        view.OrderTimeLabel.hidden=YES;
        view.placeTitleLabel.hidden = YES;
        view.placeLabel.hidden=YES;
        view.checkNumberTitleLabel.hidden = YES;
        view.checkNumberLabel.hidden=YES;

//    } else if (order.type == OrderTypeCourtPool) {//拼场
//           view.jiFenLabel.hidden = YES;
//           view.orderInforLabel.text=[NSString stringWithFormat:@"场馆: %@",order.businessName];
//           view.OrderNameLabel.text=[NSString stringWithFormat:@"项目: %@",order.categoryName];
//           view.OrderTimeLabel.text=[NSString stringWithFormat:@"场地：开场前30分钟分配"];
//           NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//           [formatter setDateFormat:@"MM月dd日 HH:mm"];
//           NSString *startTimeString = [formatter stringFromDate:order.courtPool.startTime];
//           [formatter setDateFormat:@"HH:mm"];
//           NSString *endTimeString = [formatter stringFromDate:order.courtPool.endTime];
//           view.placeLabel.text=[NSString stringWithFormat:@"日期: %@-%@",startTimeString,endTimeString];
//           view.checkNumberLabel.hidden = YES;
//           view.showWayLabel.text = view.order.courtPool.payTips;
//           view.callFrendsButton.tag = order.courtPool.courtPoolId.intValue;
//           [view.callFrendsButton removeTarget:view action:@selector(callFrends:) forControlEvents:UIControlEventTouchUpInside];
//           
//           //拼场1.0订单支付成功仅有查看订单详情一个按钮,无通知朋友们
//           view.callFrendsButton.hidden = YES;
//           [view.orderInfoButton removeTarget:self action:@selector(viewOrderInfo:) forControlEvents:UIControlEventTouchUpInside];
//           [view.orderInfoButton addTarget:self action:@selector(pushCourtPoolDetail) forControlEvents:UIControlEventTouchUpInside];
//           
//           NSString *shareTitle = order.shareBtnMsg.length > 0 ? order.shareBtnMsg : @"查看拼场订单";
//           [view.callFrendsButton setTitle:shareTitle forState:UIControlStateNormal];
//       
   } else {//([order.businessName isEqual:@"健卡舞游"])
       view.orderInforLabel.text=[NSString stringWithFormat:@"%@",order.businessName];
       view.orderInfoTitleLabel.text = @"场馆：";
       view.OrderNameLabel.text=[NSString stringWithFormat:@"%@",order.categoryName];
       view.orderNameTitleLabel.text = @"项目：";
       view.OrderTimeLabel.text=[NSString stringWithFormat:@"%@",order.goodsName];
        view.orderTimeTitleLabel.text = @"套餐：";
       view.placeTitleLabel.text = @"数量：";
       view.placeLabel.text=[NSString stringWithFormat:@"%d",order.count];
       
       NSString *s;
       if (order.count > 1) {
           s = [NSString stringWithFormat:@"%d个，请在订单详情中查看", order.count];
       } else {
           s =[order.consumeCode isEqualToString:@""]?@"-":order.consumeCode;
       }
       view.checkNumberTitleLabel.text = @"验证码：";
       view.checkNumberLabel.text=[NSString stringWithFormat:@"%@",s];
       [view hideCallFrendButton];
    }
    
    [view.checkNumberLabel updateOriginY:topCheckNumberLabel.frame.origin.y + topCheckNumberLabel.frame.size.height + 5];
    [view.checkNumberTitleLabel updateOriginY:view.checkNumberLabel.frame.origin.y];
    
    if (view.order.courtJoin.sponsorPermission) {
        //SponsorCourtJoinView
        view.sponsorCourtJoinView = [SponsorCourtJoinView createViewWithOrder:view.order sponsorType:SponsorTypePaySucceed];
        [[[UIApplication sharedApplication] keyWindow] addSubview:view.sponsorCourtJoinView];
        [view updateHeight:[UIScreen mainScreen].bounds.size.height - view.sponsorCourtJoinView.bounds.size.height - 64];
        //PaySuccessView scroll contentSize
        [view setContentSize:CGSizeMake(view.contentSize.width, CGRectGetMaxY(view.backToHomeButton.frame) + OFFSET_CONTENT_SIZE_BOTTOM - view.sponsorCourtJoinView.bounds.size.height)];
    }
    
    //积分tips
    if (order.givePoint>0&&order.type!=3) {
        view.jiFenLabel.hidden=NO;
        view.jiFenLabel.text=[NSString stringWithFormat:@"赠送您%d积分,请坚持运动,永不言弃哦!",order.givePoint];
        [view.jiFenLabel updateOriginY:CGRectGetMaxY(view.checkNumberLabel.frame) + 10];
    } else {
        view.jiFenLabel.hidden = YES;
    }
    
    //--------调整布局--------
    //友情tips 保险优先
    //showWayLabel orderInfoButton callFriendButton backToHomeButton updateFrame
    CGFloat referY;
    if (YES == view.jiFenLabel.hidden) {
        referY = CGRectGetMaxY(view.checkNumberLabel.frame) + 20;
    } else {
        referY = CGRectGetMaxY(view.jiFenLabel.frame) + 20;
    }
    [view.showWayLabel updateOriginY:referY];
    
    if ([view.order.insuranceUrl length] > 0){//保险
        view.showWayLabel.text = INSURANCE_TIPS;
        [view.orderInfoButton updateOriginY:CGRectGetMaxY(view.showWayLabel.frame) + 30];
        [view.callFrendsButton updateOriginY:CGRectGetMaxY(view.showWayLabel.frame) + 30];
    } else if ([view.order.courtJoin.remindTips length] > 0 && view.order.type == OrderTypeCourtJoin) {//退款
        view.showWayLabel.text = view.order.courtJoin.remindTips;
        [view.orderInfoButton updateOriginY:CGRectGetMaxY(view.showWayLabel.frame) + 30];
        [view.callFrendsButton updateOriginY:CGRectGetMaxY(view.showWayLabel.frame) + 30];
    } else {
        view.showWayLabel.hidden = YES;
        [view.orderInfoButton updateOriginY:referY];
        [view.callFrendsButton updateOriginY:referY];
    }
    
    
    [view.backToHomeButton updateOriginY:CGRectGetMaxY(view.orderInfoButton.frame) + 20];
    
    //PaySuccessView scroll contentSize
    [view setContentSize:CGSizeMake(view.contentSize.width, CGRectGetMaxY(view.backToHomeButton.frame) + OFFSET_CONTENT_SIZE_BOTTOM)];
    return view;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    PayMethod *method = objc_getAssociatedObject(self, &KEY_SELECTED_PAY_METHOD);
    if ([method.payId isEqualToString:PAY_ID_APPLE_PAY] && 0 != _order.amount) {
        self.applePaySuccessLabel.hidden = NO;
    }
}

- (void)hideCallFrendButton {
    _callFrendsButton.hidden = YES;
    [_orderInfoButton updateWidth:[[UIScreen mainScreen] bounds].size.width * 0.85];
    _orderInfoButton.center = CGPointMake([[[UIApplication sharedApplication] keyWindow] center].x, _orderInfoButton.center.y);
}

- (IBAction)callFrends:(id)sender {
    if ([self.paydelegate respondsToSelector:@selector(shareOrderInfoWith:)]) {
        [self.paydelegate shareOrderInfoWith:self.order];
    }
}

- (void)viewOrderInfo:(UIButton *)sender {
    if ([self.paydelegate respondsToSelector:@selector(pushOrderDetailController)]) {
        [self.paydelegate pushOrderDetailController];
    }
}

- (IBAction)backToHome:(id)sender {
    [_sponsorCourtJoinView removeFromSuperview];
    if ([self.paydelegate respondsToSelector:@selector(PaySuccessViewBackToHome)]) {
        [self.paydelegate PaySuccessViewBackToHome];
    }
}

- (void)hideSponsorCourtJoinView {
    _sponsorCourtJoinView.hidden = YES;
}

- (void)appearSponsorCourtJoinView {
    _sponsorCourtJoinView.hidden = NO;
    _sponsorCourtJoinView.alpha = 0;
    [UIView animateWithDuration:0.5f animations:^{
        _sponsorCourtJoinView.alpha = 1;
    }];
}

@end
