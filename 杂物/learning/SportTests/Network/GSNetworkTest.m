//
//  GSNetworkTest.m
//  Sport
//
//  Created by qiuhaodong on 16/5/28.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GSNetwork.h"

@interface GSNetworkTest : XCTestCase

@end

@implementation GSNetworkTest

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

- (void)testGet {
    [GSNetwork getWithBasicUrlString:@"http://news-at.zhihu.com/api/3/news/latest" parameters:nil responseHandler:^(GSNetworkResponse *response) {
        XCTAssertNotNil(response.jsonResult);
    }];
}

- (void)testPost {
    NSDictionary *parameters = @{@"name":@"jack",@"age":@"12",@"gender":@"m"};
    [GSNetwork postWithBasicUrlString:@"http://news-at.zhihu.com/api/3/news/latest" parameters:parameters responseHandler:^(GSNetworkResponse *response) {
        XCTAssertNotNil(response.jsonResult);
    }];
}

- (void)testPostImage {
    NSDictionary *parameters = @{@"name":@"jack",@"age":@"12",@"gender":@"m"};
    NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test_post" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    [GSNetwork postWithBasicUrlString:@"http://news-at.zhihu.com/api/3/news/latest"  parameters:parameters image:image responseHandler:^(GSNetworkResponse *response) {
        XCTAssertNotNil(response.jsonResult);
    }];
}

- (void)testGetStaticData {
    [GSNetwork getWithBasicUrlString:@"http://api.qydtest.com/index" parameters:@{@"action":@"get_static_data"} responseHandler:^(GSNetworkResponse *response) {
        XCTAssertNotNil(response.jsonResult);
    }];
}

@end
