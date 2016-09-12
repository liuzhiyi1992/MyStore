//
//  QrCodeView.h
//  Sport
//
//  Created by 江彦聪 on 15/3/24.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"
@interface QrCodeView : UIView
+ (QrCodeView *)createQrCodeViewWithCode:(NSString *)code;
-(void)showWithOrderCodeView;
-(void)showWithMonthCardCodeView;
@end
