//
//  SportGASTest.m
//  Sport
//
//  Created by qiuhaodong on 16/5/27.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SportGAS.h"
#import "ConfigData.h"

@interface SportGASTest : XCTestCase

@end

@implementation SportGASTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testMogui {
    XCTAssert([[SportGAS mogui] isEqualToString:@"d67597dddfafb04d80cd7da1fe530bfc"]);
}

- (void)testDesKey {
    XCTAssert([SPORT_DES_KEY isEqualToString:@"ej34uk46"]);
}

- (void)testDesIV {
    XCTAssert([SPORT_DES_IV isEqualToString:@"27wsp85p"]);
}

@end
