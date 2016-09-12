//
//  PaymentAnimator+Test.h
//  Sport
//
//  Created by lzy on 16/4/27.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaymentAnimator.h"
#import "UPAPayPlugin.h"

@interface PaymentAnimator ()
- (id)didFinishVerifyPayPassword:(NSString *)payPassword status:(NSString *)status;
- (void)UPAPayPluginResult:(UPPayResult *)payResult;
@end
