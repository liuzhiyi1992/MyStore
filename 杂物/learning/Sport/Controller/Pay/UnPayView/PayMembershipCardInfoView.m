//
//  PayMembershipCardInfoView.m
//  Sport
//
//  Created by qiuhaodong on 15/6/12.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "PayMembershipCardInfoView.h"
#import "UIView+SportBackground.h"
#import "UIView+Utils.h"

@interface PayMembershipCardInfoView()
@property (weak, nonatomic) IBOutlet UILabel *cardUserLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardBalanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardPhoneLabel;

@end


@implementation PayMembershipCardInfoView


+ (PayMembershipCardInfoView *)createViewWithOrder:(Order *)order
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PayMembershipCardInfoView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    PayMembershipCardInfoView *view = (PayMembershipCardInfoView *)[topLevelObjects objectAtIndex:0];
    [view updateWidth:[UIScreen mainScreen].bounds.size.width];
    [view sportUpdateAllBackground];
    view.cardUserLabel.text = order.cardHolder;
    view.cardBalanceLabel.text = [NSString stringWithFormat:@"%@元", order.cardBalance];
    view.cardNumberLabel.text = order.cardNumber;
    view.cardPhoneLabel.text = order.cardPhone;
    return view;
}

@end
