//
//  SportOrderDetailFactoryTest.m
//  Sport
//
//  Created by lzy on 16/7/23.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCHamcrest/OCHamcrest.h>
#import <OCMock/OCMock.h>

#import "SportOrderDetailFactory.h"
#import "Order.h"
#import "OrderDetailController.h"
#import "CourtJoinOrderDetailController.h"
#import "CoachOrderDetailController.h"

@interface SportOrderDetailFactoryTest : XCTestCase

@end

@implementation SportOrderDetailFactoryTest
{
    Order *_order;
}

- (void)setUp {
    [super setUp];
    _order = [[Order alloc] init];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testOutPutCommonOrderDetail {
    _order.type = arc4random() % 6;
    NSLog(@"arc4random:%d", _order.type);
    UIViewController *orderDetailController = [SportOrderDetailFactory orderDetailControllerWithOrder:_order];
    assertThatBool([orderDetailController isKindOfClass:[OrderDetailController class]], isTrue());
}

- (void)testOutPutCourtJoinOrderDetail {
    _order.type = OrderTypeCourtJoin;
    UIViewController *orderDetailController = [SportOrderDetailFactory orderDetailControllerWithOrder:_order];
    assertThatBool([orderDetailController isKindOfClass:[CourtJoinOrderDetailController class]], isTrue());
}

- (void)testOutPutCoachOrderDetail {
    _order.type = OrderTypeCoach;
    UIViewController *orderDetailController = [SportOrderDetailFactory orderDetailControllerWithOrder:_order];
    assertThatBool([orderDetailController isKindOfClass:[CoachOrderDetailController class]], isTrue());
}

@end
