//
//  PayRequest.h
//  Sport
//
//  Created by lzy on 16/3/18.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Order.h"
#import "PayMethod.h"


@interface PayRequest : NSObject

@property (strong, nonatomic) Order *order;
@property (strong, nonatomic) PayMethod *paymethod;
@property (copy, nonatomic) NSString *password;
@property (assign, nonatomic) double thirdPartyPayAmount;
@property (assign, nonatomic) BOOL isUsedBalance;

+ (PayRequest *)requestWithOrder:(Order *)order
                     payMethod:(PayMethod *)paymethod
                      password:(NSString *)password
           thirdPartyPayAmount:(double)thirdPartyPayAmount
                 isUsedBalance:(BOOL)isUsedBalance;

@end
