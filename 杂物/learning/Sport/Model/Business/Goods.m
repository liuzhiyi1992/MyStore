//
//  Goods.m
//  Sport
//
//  Created by haodong  on 14-8-15.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "Goods.h"

@implementation Goods


- (float)validPrice
{
    if (self.promotePrice > 0) {
        return self.promotePrice;
    } else {
        return self.price;
    }
}

@end
