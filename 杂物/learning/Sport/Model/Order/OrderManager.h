//
//  OrderManager.h
//  Sport
//
//  Created by haodong  on 13-9-10.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Order.h"

@interface OrderManager : NSObject

+ (OrderManager *)defaultManager;

+ (void)checkOrderStatus:(Order *)order;

@end
