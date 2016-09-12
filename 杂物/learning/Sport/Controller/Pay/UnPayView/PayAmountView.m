//
//  PayAmountView.m
//  Sport
//
//  Created by qiuhaodong on 15/6/12.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "PayAmountView.h"
#import "UIView+SportBackground.h"
#import "PriceUtil.h"
#import "UIView+Utils.h"

@interface PayAmountView()

@property (assign, nonatomic) BOOL isSelectedMoney;
@property (assign, nonatomic) id<PayAmountViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *moneyHolderView;
@property (weak, nonatomic) IBOutlet UIView *needPayHolderView;
@property (weak, nonatomic) IBOutlet UILabel *availableMoneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *useMoneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *payAmountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *moneyBoxImageView;
@property (strong, nonatomic) IBOutlet UIView *lineImageView;

@end

@implementation PayAmountView


+ (PayAmountView *)createViewWithOrder:(Order *)order
                       isSelectedMoney:(BOOL)isSelectedMoney
                              delegate:(id<PayAmountViewDelegate>)delegate
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PayAmountView" owner:self options:nil];
    if ([topLevelObjects count] <= 0) {
        return nil;
    }
    PayAmountView *view = (PayAmountView *)[topLevelObjects objectAtIndex:0];
    [view updateWidth:[UIScreen mainScreen].bounds.size.width];
    view.isSelectedMoney = isSelectedMoney;
    view.delegate = delegate;
    [view sportUpdateAllBackground];
    [view.lineImageView updateHeight:0.5];
    
    float needPayFrom3thAmount;
    float totalBalance = order.money + order.userBalance;
    float orderAmount;//支付金额
    
    if (order.isClubPay) { //如果动club则支付金额是0
        orderAmount = 0;
    } else {
        orderAmount = order.totalAmount - order.promoteAmount;
    }
    
    CGFloat y = 0;
    if (totalBalance > 0   //用户余额大于0才能用余额
        && orderAmount > 0 ) { //订单金额大于0才能用余额，因为用月卡支付的金额是0
        view.moneyHolderView.hidden = NO;
        y = y + view.moneyHolderView.frame.size.height;
        
        if (isSelectedMoney) {
            view.useMoneyLabel.hidden = NO;
            [view.moneyBoxImageView setImage:[SportImage selectBoxOrangeImage]];
            
            if (totalBalance >= orderAmount) {
                needPayFrom3thAmount = 0;
                view.availableMoneyLabel.text = [PriceUtil toPriceStringWithYuan:totalBalance - orderAmount];
                view.useMoneyLabel.text = [PriceUtil toPriceStringWithYuan:orderAmount];
            } else {
                needPayFrom3thAmount = orderAmount - totalBalance;
                view.availableMoneyLabel.text = [PriceUtil toPriceStringWithYuan:0];
                view.useMoneyLabel.text =  [PriceUtil toPriceStringWithYuan:totalBalance];
            }
            
        } else {
            view.useMoneyLabel.hidden = YES;
            [view.moneyBoxImageView setImage:[SportImage selectBoxUnselectImage]];
            needPayFrom3thAmount = orderAmount;
            view.availableMoneyLabel.text = [PriceUtil toPriceStringWithYuan:totalBalance];
        }
        
    } else {
        view.moneyHolderView.hidden = YES;
        needPayFrom3thAmount = orderAmount;
    }
    
    [view.needPayHolderView updateOriginY:y];
    [view updateHeight:view.needPayHolderView.frame.origin.y + view.needPayHolderView.frame.size.height];
    
    view.payAmountLabel.text = [NSString stringWithFormat:@"%@元", [PriceUtil toValidPriceString:needPayFrom3thAmount]];
    
    //返回已经计算的需要第三方支付的金额
    if ([view.delegate respondsToSelector:@selector(didCalculateThirdPartyPayAmount:)]) {
        [view.delegate didCalculateThirdPartyPayAmount:needPayFrom3thAmount];
    }
    
    return view;
}

- (IBAction)clickMoneyButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickPayAmountViewMoneyButton:)]) {
        self.isSelectedMoney = !self.isSelectedMoney;
        [_delegate didClickPayAmountViewMoneyButton:_isSelectedMoney];
    }
}

@end
