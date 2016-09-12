//
//  SportOrderDetailFactory.h
//  Sport
//
//  Created by lzy on 16/7/22.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@class Order;

@interface SportOrderDetailFactory : NSObject
+ (UIViewController *)orderDetailControllerWithOrder:(Order *)order;
@end
