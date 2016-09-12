//
//  QydTokenTest.m
//  Sport
//
//  Created by 江彦聪 on 16/7/18.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCHamcrest/OCHamcrest.h>
#import <OCMock/OCMock.h>
#import "AppDelegate.h"
#import "AppDelegate_Test.h"
#import "User.h"
#import "UserManager.h"
#import "GSNetwork.h"
#import "SportUUID.h"
#import "AppGlobalDataManager.h"
#import "BaseService+mock.h"

@interface QydTokenTest : XCTestCase
@property (strong, nonatomic) AppDelegate *sutAppDelegate;
@end

@implementation QydTokenTest
int callCount = 0;
- (void)setUp {
    [super setUp];
    self.sutAppDelegate = OCMPartialMock([[UIApplication sharedApplication] delegate]);
    id sportUUIDMock = OCMClassMock([SportUUID class]);
    OCMStub([sportUUIDMock uuid]).andReturn(@"abcdefg");
    User *user = [[User alloc]init];
    user.userId = @"3358";
    user.hasPayPassWord = YES;

    [[UserManager defaultManager] saveCurrentUser:user];
    [UserManager saveLoginEncode:@"aaabbbcccdddeee"];
    
    OCMStub([self.sutAppDelegate initAppData]).andDo(^(NSInvocation *invocation) {
        ++callCount;
    });
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    self.sutAppDelegate = nil;
    [[UserManager defaultManager] saveCurrentUser:nil];
    [UserManager saveLoginEncode:nil];
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void) testRequestTokenWhenAppStart {
    
    [self.sutAppDelegate didGetQydToken:STATUS_SUCCESS msg:@"success" expire:370];
    OCMVerify([self.sutAppDelegate requestAccessTokenWithTimerInterval: REAL_EXPIRE_TIME(370)]);
    
    [self.sutAppDelegate didGetQydToken:STATUS_SUCCESS msg:@"success" expire:3600];
    
    OCMReject([self.sutAppDelegate initAppData]);
    
    assertThatInt(callCount,equalToInt(1));
    
}

-(void) testRequestAccessTokenWithTimer {

    [BaseService createMock];
    OCMExpect([[BaseService defaultService] getQydTokenWithDevice:@"abcdefg" userId:@"3358" loginEncode:@"aaabbbcccdddeee" complete:[OCMArg any]]);
    [self.sutAppDelegate requestAccessTokenWithTimerInterval:2];
    id BaseServiceMock = [BaseService defaultService];
    OCMVerifyAllWithDelay(BaseServiceMock, 5);
    
    
    [BaseService releaseMock];
}

-(void) testRequestAccessTokenWithLoginEncodeFailed {
    [UserManager saveLoginEncode:nil];
    
    [self.sutAppDelegate requestQydToken];
    OCMVerify([self.sutAppDelegate logoutAndCleanView]);
    
}

-(void) testRequestAccessTokenWithProcessingTokenSuccess {
    id gsNetworkMock = OCMClassMock([GSNetwork class]);

    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    
    [inputDic setValue:VALUE_ACTION_GET_QYD_TOKEN forKey:PARA_ACTION];
    [inputDic setValue:@"abcdefg" forKey:PARA_DEVICE_ID];
    [inputDic setValue:@"3358" forKey:PARA_USER_ID];
    [inputDic setValue:@"aaabbbcccdddeee" forKey:PARA_LOGIN_ENCODE];

    NSDictionary *testResponse = @{@"status": @"0000" , @"message": @"success", @"data":@{@"expire":@(3600),@"server_time":@(1469760626),@"value":@"oiQlQ8IOnKbESc3dh97HM2mlJSPZDe0IE5Q5L9XcSAZvY4N2IUdSWEeIsCOSwHrD"}};
    NSURLResponse *response = [[NSURLResponse alloc]init];
    GSNetworkResponse *stubRespone = [[GSNetworkResponse alloc]initWithJsonResult:testResponse response:response];

    OCMStub([gsNetworkMock getWithBasicUrlString:(GS_URL_USER) parameters:inputDic responseHandler:([OCMArg invokeBlockWithArgs:stubRespone, nil])]);
    
    [self.sutAppDelegate requestQydToken];

    assertThatBool([AppGlobalDataManager defaultManager].isProcessingToken, isFalse());
}

-(void)testRequestAccessTokenWithLoginEncodeError {
    id gsNetworkMock = OCMClassMock([GSNetwork class]);
    
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    
    [inputDic setValue:VALUE_ACTION_GET_QYD_TOKEN forKey:PARA_ACTION];
    [inputDic setValue:@"abcdefg" forKey:PARA_DEVICE_ID];
    [inputDic setValue:@"3358" forKey:PARA_USER_ID];
    [inputDic setValue:@"aaabbbcccdddeee" forKey:PARA_LOGIN_ENCODE];
    
    NSDictionary *testResponse = @{@"status": @"0225" , @"message": @"success", @"data":@{@"expire":@(3600),@"server_time":@(1469760626),@"value":@"oiQlQ8IOnKbESc3dh97HM2mlJSPZDe0IE5Q5L9XcSAZvY4N2IUdSWEeIsCOSwHrD"}};
    NSURLResponse *response = [[NSURLResponse alloc]init];
    GSNetworkResponse *stubRespone = [[GSNetworkResponse alloc]initWithJsonResult:testResponse response:response];
    
    OCMStub([gsNetworkMock getWithBasicUrlString:(GS_URL_USER) parameters:inputDic responseHandler:([OCMArg invokeBlockWithArgs:stubRespone, nil])]);
    id observerMock = OCMObserverMock();
    [[NSNotificationCenter defaultCenter] addMockObserver:observerMock
                                                 name:NOTIFICATION_NAME_LOGIN_ENCODE_ERROR
                                               object:nil];
    [[observerMock expect] notificationWithName:NOTIFICATION_NAME_LOGIN_ENCODE_ERROR object:[OCMArg any]];
    [self.sutAppDelegate requestQydToken];
    
    assertThatBool([AppGlobalDataManager defaultManager].isProcessingToken, isFalse());
    OCMVerifyAll(observerMock);
}

-(void) testRequestAccessTokenWithProcessingTokenFailed {
    id gsNetworkMock = OCMClassMock([GSNetwork class]);
    
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    
    [inputDic setValue:VALUE_ACTION_GET_QYD_TOKEN forKey:PARA_ACTION];
    [inputDic setValue:@"abcdefg" forKey:PARA_DEVICE_ID];
    [inputDic setValue:@"3358" forKey:PARA_USER_ID];
    [inputDic setValue:@"aaabbbcccdddeee" forKey:PARA_LOGIN_ENCODE];
    
    NSDictionary *testResponse = @{@"status": @"" , @"message": @"network issue", @"data":@{}};
    NSURLResponse *response = [[NSURLResponse alloc]init];
    GSNetworkResponse *stubRespone = [[GSNetworkResponse alloc]initWithJsonResult:testResponse response:response];
    __block int retryTime = 0;
    OCMStub([gsNetworkMock getWithBasicUrlString:(GS_URL_USER) parameters:inputDic responseHandler:([OCMArg invokeBlockWithArgs:stubRespone, nil])]).andDo(^(NSInvocation *invocation) {
        ++retryTime;
    });
    
    [self.sutAppDelegate requestQydToken];
    
    assertThatBool([AppGlobalDataManager defaultManager].isProcessingToken, isTrue());
    assertWithTimeout(35, thatEventually(@(retryTime)), is(@(15)));
    
    assertWithTimeout(35, thatEventually([AppGlobalDataManager defaultManager].isProcessingToken?@"YES":@"NO"), is(@"NO"));
}

-(void) testRequestAccessTokenWithNoNetwork {
    id gsNetworkMock = OCMClassMock([GSNetwork class]);
    
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    
    [inputDic setValue:VALUE_ACTION_GET_QYD_TOKEN forKey:PARA_ACTION];
    [inputDic setValue:@"abcdefg" forKey:PARA_DEVICE_ID];
    [inputDic setValue:@"3358" forKey:PARA_USER_ID];
    [inputDic setValue:@"aaabbbcccdddeee" forKey:PARA_LOGIN_ENCODE];
    
    NSDictionary *testResponse = @{@"message": @"network issue", @"data":@{}};
    NSURLResponse *response = [[NSURLResponse alloc]init];
    GSNetworkResponse *stubRespone = [[GSNetworkResponse alloc]initWithJsonResult:testResponse response:response];
    __block int retryTime = 0;
    OCMStub([gsNetworkMock getWithBasicUrlString:(GS_URL_USER) parameters:inputDic responseHandler:([OCMArg invokeBlockWithArgs:stubRespone, nil])]).andDo(^(NSInvocation *invocation) {
        ++retryTime;
    });
    
    [self.sutAppDelegate requestQydToken];
    
    assertThatBool([AppGlobalDataManager defaultManager].isProcessingToken, isFalse());
    assertWithTimeout(35, thatEventually(@(retryTime)), is(@(15)));
    
    assertWithTimeout(35, thatEventually([AppGlobalDataManager defaultManager].isProcessingToken?@"YES":@"NO"), is(@"NO"));
}



- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

