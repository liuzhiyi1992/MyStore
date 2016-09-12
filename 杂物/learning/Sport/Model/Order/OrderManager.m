//
//  OrderManager.m
//  Sport
//
//  Created by haodong  on 13-9-10.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "OrderManager.h"
//#import "Pborder.pb.h"
#import "Product.h"
#import "FileUtil.h"
#import "User.h"
#import "UserManager.h"

@interface OrderManager()
@property (strong, nonatomic) NSMutableArray *orderList;
@end

static OrderManager *_globalOrderManager = nil;

@implementation OrderManager

+ (OrderManager *)defaultManager
{
    if (_globalOrderManager == nil) {
        _globalOrderManager = [[OrderManager alloc] init];
    }
    return _globalOrderManager;
}

//1.70把订单缓存功能去掉了
//注意：记得1.70版本以前的订单缓存数据放在Document下的xxx_order.dat，其中xxx为userId
/*
- (NSString*)getFilePath
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    NSString *fileName = [NSString stringWithFormat:@"%@_order.dat", user.userId];
    NSString *path = [[FileUtil getAppDocumentDir] stringByAppendingPathComponent:fileName];
    //HDLog(@"path:%@", path);
    return path;
}
 */

//不使用此方法，全部使用后台返回字段进行判断
#define MAX_TIME_TO_PAY    (10 * 60)  //如果是未支付状态，10分钟内不支付则变成取消状态
+ (void)checkOrderStatus:(Order *)order
{
    if (order.status == OrderStatusUnpaid) {
        if ([[NSDate date] timeIntervalSince1970] - [order.createDate timeIntervalSince1970] > MAX_TIME_TO_PAY) {
            order.status = OrderStatusCancelled;
        }
    }
}


@end
