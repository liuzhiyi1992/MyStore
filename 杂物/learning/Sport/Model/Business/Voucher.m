//
//  Voucher.m
//  Sport
//
//  Created by haodong  on 14-5-25.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "Voucher.h"

@implementation Voucher


-(BOOL)validToUse:(float)totalAmount {
    return (self.amount <= totalAmount && self.minAmount <= totalAmount);
}

-(float)minAmountToUse {
    return self.amount > self.minAmount?self.amount:self.minAmount;
}

@end
