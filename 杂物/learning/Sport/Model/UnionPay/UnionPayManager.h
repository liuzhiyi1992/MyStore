//
//  UnionPayManager.h
//  Sport
//
//  Created by haodong  on 15/4/24.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPPayPluginDelegate.h"

#define UPPAY_PAIED_URL_TYPES @"SportUPPay"//需要在项目Info URLTypes里同步修改

@interface UnionPayManager : NSObject

+ (BOOL)startPay:(NSString*)tn
            mode:(NSString*)mode
  viewController:(UIViewController*)viewController
        delegate:(id<UPPayPluginDelegate>)delegate;

+ (BOOL)startPay:(NSString *)tn
            mode:(NSString *)mode
  viewController:(UIViewController *)viewController;

+ (void)handleUPPayResultWithUrl:(NSURL *)url;
@end
