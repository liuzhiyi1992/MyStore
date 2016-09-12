//
//  PayTypeView.h
//  Sport
//
//  Created by qiuhaodong on 15/6/12.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@class PayMethod;

@protocol PayTypeViewDelegate <NSObject>
@optional
- (void)didClickPayTypeView:(PayMethod *)payMethod;
@end

#define KEY_LAST_SELECTED_PAY @"key_last_selected_pay"

@interface PayTypeView : UIView

+ (PayTypeView *)createViewWithMethodList:(NSArray *)methodList
                           selectedMethod:(PayMethod *)selectedMethod
                                 delegate:(id<PayTypeViewDelegate>)delegate;

@end
