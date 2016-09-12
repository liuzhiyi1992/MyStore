//
//  PayMonthCardRechargeOrderView.m
//  Sport
//
//  Created by qiuhaodong on 15/6/14.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "PayMonthCardRechargeOrderView.h"
#import "UIView+SportBackground.h"
#import "PriceUtil.h"
#import "UIView+Utils.h"

@interface PayMonthCardRechargeOrderView()
@property (weak, nonatomic) IBOutlet UILabel *onePriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@end

@implementation PayMonthCardRechargeOrderView


+ (PayMonthCardRechargeOrderView *)createViewWithOrder:(Order *)order
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PayMonthCardRechargeOrderView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    PayMonthCardRechargeOrderView *view = (PayMonthCardRechargeOrderView *)[topLevelObjects objectAtIndex:0];
    [view updateWidth:[UIScreen mainScreen].bounds.size.width];
    [view sportUpdateAllBackground];
    view.onePriceLabel.text = [PriceUtil toPriceStringWithYuan:order.singlePrice];
    view.countLabel.text  = [NSString stringWithFormat:@"%d", order.count];
    return view;
}



@end
