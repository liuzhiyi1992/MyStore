//
//  SportOrderDetailFactory.m
//  Sport
//
//  Created by lzy on 16/7/22.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "SportOrderDetailFactory.h"
#import "Order.h"
#import "OrderDetailController.h"
#import "CourtJoinOrderDetailController.h"
#import "CoachOrderDetailController.h"
#import "OrderDetailsController.h"

@implementation SportOrderDetailFactory
+ (UIViewController *)orderDetailControllerWithOrder:(Order *)order {
    UIViewController *orderDetailController = nil;
    NSString *classString = @"";
    switch (order.type) {
        case OrderTypeCourtJoin:
            classString = @"CourtJoinOrderDetailController";
            break;
        case OrderTypeCoach:
            classString = @"CoachOrderDetailController";
            break;
        default:
            classString = @"OrderDetailController";
//            orderDetailController = [[OrderDetailController alloc] initWithOrder:order isReload:YES];
            orderDetailController = [[OrderDetailsController alloc] initWithOrder:order isReload:YES];
            break;
    }
    
    [self operationWithOrderDetailController:&orderDetailController classString:classString order:order];
    return orderDetailController;
}

+ (void)validateKindOfViewController:(id)object {
    if (![object isKindOfClass:[UIViewController class]]) {
        NSAssert(NO, @"SportOrderDetailFactory ERROR");
    }
}

+ (void)validateClassString:(NSString *)classString {
    if (classString.length <= 0) {
        NSAssert(NO, @"SportOrderDetailFactory ERROR");
    }
}

+ (void)operationWithOrderDetailController:(UIViewController **)controller classString:(NSString *)classString order:(Order *)order {
    if (nil == *controller) {
        [self validateClassString:classString];
        *controller = [[NSClassFromString(classString) alloc] initWithOrder:order];
    }
    [self validateKindOfViewController:*controller];
}
@end
