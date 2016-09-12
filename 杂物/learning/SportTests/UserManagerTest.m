//
//  UserManagerTest.m
//  Sport
//
//  Created by qiuhaodong on 16/5/14.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UserManager.h"

@interface UserManagerTest : XCTestCase

@end

@implementation UserManagerTest

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

- (void)testSaveUser
{
    User *user_0 = [[User alloc] init];
    XCTAssertTrue([[UserManager defaultManager] saveCurrentUser:user_0]);
    XCTAssertNotNil([[UserManager defaultManager] readCurrentUser]);
    
    User *user_1 = [[User alloc] init];
    user_1.userId = @"123";
    XCTAssertTrue([[UserManager defaultManager] saveCurrentUser:user_1]);
    XCTAssertEqual([[UserManager defaultManager] readCurrentUser].userId, @"123");
    
    XCTAssertTrue([[UserManager defaultManager] saveCurrentUser:nil]);
    XCTAssertNil([[UserManager defaultManager] readCurrentUser]);
}

@end
