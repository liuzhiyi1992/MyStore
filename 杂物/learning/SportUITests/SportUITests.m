//
//  SportUITests.m
//  SportUITests
//
//  Created by 江彦聪 on 16/4/15.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <XCTest/XCTest.h>

@interface SportUITests : XCTestCase

@end

@implementation SportUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testExample {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
//    [[[XCUIApplication alloc] init].tables.scrollViews.otherElements.buttons[@"羽毛球场"] tap];
//    
//    XCUIElementQuery *tablesQuery = [[XCUIApplication alloc] init].tables;
//    [tablesQuery.staticTexts[@"趣运动.东英羽毛球馆"] tap];
//    
//    XCUIApplication *app = [[XCUIApplication alloc] init];
//    
//    XCUIElement *scrollView = [[[[[[[[[[[app childrenMatchingType:XCUIElementTypeWindow] elementBoundByIndex:0] childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeScrollView].element childrenMatchingType:XCUIElementTypeScrollView] elementBoundByIndex:3];
//    XCUIElement *button = [[[scrollView childrenMatchingType:XCUIElementTypeOther] elementBoundByIndex:0] childrenMatchingType:XCUIElementTypeButton].element;
//    [button tap];
//    [button tap];
//    [[[[scrollView childrenMatchingType:XCUIElementTypeOther] elementBoundByIndex:1] childrenMatchingType:XCUIElementTypeButton].element tap];
//    
//    XCUIElementQuery *scrollViewsQuery = app.scrollViews;
//    [scrollViewsQuery.staticTexts[@"3号场"] tap];
//    [[[scrollViewsQuery.otherElements containingType:XCUIElementTypeStaticText identifier:@"周日"] childrenMatchingType:XCUIElementTypeButton].element tap];
//    
    
    
}

@end
