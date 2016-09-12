//
//  PayAmountView.h
//  Sport
//
//  Created by qiuhaodong on 15/6/12.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"

@protocol PayAmountViewDelegate <NSObject>
@optional
- (void)didClickPayAmountViewMoneyButton:(BOOL)isSelectedMoney;

- (void)didCalculateThirdPartyPayAmount:(double)thirdPartyPayAmount;

@end

@interface PayAmountView : UIView

+ (PayAmountView *)createViewWithOrder:(Order *)order
                       isSelectedMoney:(BOOL)isSelectedMoney
                              delegate:(id<PayAmountViewDelegate>)delegate;

@end
