//
//  PayRequest.m
//  Sport
//
//  Created by lzy on 16/3/18.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "PayRequest.h"


@implementation PayRequest

+ (PayRequest *)requestWithOrder:(Order *)order
                       payMethod:(PayMethod *)paymethod
                        password:(NSString *)password
             thirdPartyPayAmount:(double)thirdPartyPayAmount
                   isUsedBalance:(BOOL)isUsedBalance {
    
    PayRequest *payRequest = [[self alloc] init];
    payRequest.order = order;
    payRequest.paymethod = paymethod;
    payRequest.password = password;
    payRequest.thirdPartyPayAmount = thirdPartyPayAmount;
    payRequest.isUsedBalance = isUsedBalance;
    
    return payRequest;
}


@end
