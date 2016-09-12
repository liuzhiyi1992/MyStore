//
//  OrderDetailQRCodeView.h
//  Sport
//
//  Created by lzy on 16/8/4.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const NOTIFICATION_NAME_VERIFICATION_DID_CHANGE;

@interface OrderDetailQRCodeView : UIView
+ (OrderDetailQRCodeView *)createViewWithVerificationArray:(NSArray *)verificationArray;
@end
