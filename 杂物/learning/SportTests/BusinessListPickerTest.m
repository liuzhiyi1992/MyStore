//
//  BusinessListPickerTest.m
//  Sport
//
//  Created by 江彦聪 on 15/11/23.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import "BusinessListPickerView.h"
#import "BusinessListController.h"
#import "PickerViewDataList.h"

@interface BusinessListPickerTest : XCTestCase
@property (strong, nonatomic) BusinessListPickerView* view;
@end

@implementation BusinessListPickerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    if (self.view) {
        [self.view removeFromSuperview];
    }
    
    [super tearDown];
}

- (void)basicCheck:(BusinessListPickerView *)view {
    XCTAssertNotNil(view.firstShowList, @"firstShowList is nil");
    XCTAssertNotNil(view.secondShowList, @"secondShowList is nil");
    XCTAssertNotNil(view.thirdShowList, @"thirdShowList is nil");
    
    XCTAssertEqual(view.firstShowList.count, 7,@"firstShowList count is not 7");
    
    NSString *lastHour = [view.secondShowList lastObject];
    XCTAssert([lastHour isEqualToString:@"23:00"],@"最后一个开始时间是%@",lastHour);
    XCTAssert(view.secondShowList.count <= 18,@"currentTimeArray count %lu",(unsigned long)view.secondShowList.count);
}

- (void)testPickerNomal
{
    self.view = [BusinessListPickerView showWithCategoryId:@"11" selectedDate:[NSDate date] selectedStartHour:nil selectedTimeTnterval:nil selectedSoccerNumber:nil OKHandler:^(NSDate *date, NSString *startHour, NSString *timeTnterval, NSString *soccerNumber) {
    }];
    
    [self basicCheck:self.view];
}

//模拟当前时间是10点
- (void)testPickerBeginTimeBy10 {
    
    /*
    BusinessListPickerView *view = [BusinessListPickerView showWithCategoryId:nil selectedDate:[NSDate date] selectedStartHour:nil selectedTimeTnterval:nil selectedSoccerNumber:nil OKHandler:^(NSDate *date, NSString *startHour, NSString *timeTnterval, NSString *soccerNumber) {
    }];
    
    [self basicCheck:view];
    XCTAssertTrue([view.secondShowList[0] isEqualToString:@"11:00"],@"currentTimeArray[0] %@", view.secondShowList[0]);
    */
    
    
//    BusinessListController *controller = [[BusinessListController alloc]init];
 
//    id mockController = OCMPartialMock(controller);
//    
//    //模拟今天11点
//    OCMStub([mockController currentHour])._andReturn(@(10));
//    [controller chooseTimeList];
//    controller.pickerView = nil;
//    [controller showPickView];
//    currentTimeArray = controller.todayTimeArray;
//    
//    //切换数据源后，检查当天日期是否满足要求
//    XCTAssertNotNil(controller.timeArray,@"data list is nil");
//    XCTAssertEqual([controller.timeArray count], 3,@"data list count is not 3");
//    XCTAssertEqual([controller.timeArray[0] count], 7,@"data list count is not 7");
//    XCTAssertEqual([controller.timeArray[1] count], 17,@"data list count is not 17");
//    XCTAssertEqual([controller.timeArray[2] count], 4,@"data list count is not 4");
//    XCTAssertEqual([controller.dayArray count], 7,@"day Array count is not 7");
//    XCTAssertTrue([currentTimeArray[0] isEqualToString:@"11:00"],@"currentTimeArray[0] %@", currentTimeArray[0]);
//    
//    //模拟拨动第一个轮第一行
//    //模拟第一次展示
//    NSInteger row = [controller.pickerView.dataPickerView selectedRowInComponent:1];
//    
//    UILabel *titleView = (UILabel *)[controller.pickerView pickerView:controller.pickerView.dataPickerView viewForRow:row forComponent:1 reusingView:nil];
//    XCTAssertTrue([currentTimeArray[0] isEqualToString:@"11:00"],@"currentTimeArray[0] %@", currentTimeArray[0]);
//    XCTAssert([currentTimeArray[row] isEqualToString:@"18:00"],@"first row is %@",currentTimeArray[row]);
//    XCTAssert([titleView.text isEqualToString:@"18:00"],@"title is %@",titleView.text);
//    
//    //模拟拨动第一个轮第二行,程序指定selectRow,不会出发didSelect,所以这里手动调用
//    [controller.pickerView.dataPickerView selectRow:1 inComponent:0 animated:NO];
//    [controller.pickerView pickerView:controller.pickerView.dataPickerView didSelectRow:1 inComponent:0];
//    
//    row = [controller.pickerView.dataPickerView selectedRowInComponent:1];
//    titleView = (UILabel *)[controller.pickerView pickerView:controller.pickerView.dataPickerView viewForRow:row forComponent:1 reusingView:nil];
//    
//    XCTAssert([controller.timeArray[1][0] isEqualToString:@"7:00"],@"first row is %@",controller.timeArray[1][0]);
//    XCTAssert([controller.timeArray[1][row] isEqualToString:@"18:00"],@"first row is %@",currentTimeArray[row]);
//    XCTAssert([titleView.text isEqualToString:@"18:00"],@"title is %@",titleView.text);
//    
//    //  模拟拨动第一个轮第二行,程序指定selectRow,不会出发didSelect,所以这里手动调用
//    [controller.pickerView.dataPickerView selectRow:6 inComponent:0 animated:NO];
//    [controller.pickerView pickerView:controller.pickerView.dataPickerView didSelectRow:1 inComponent:0];
//    
//    row = [controller.pickerView.dataPickerView selectedRowInComponent:1];
//    titleView = (UILabel *)[controller.pickerView pickerView:controller.pickerView.dataPickerView viewForRow:row forComponent:1 reusingView:nil];
//    XCTAssert([controller.timeArray[1][row] isEqualToString:@"18:00"],@"first row is %@",controller.timeArray[1][row]);
//    XCTAssert([titleView.text isEqualToString:@"18:00"],@"title is %@",titleView.text);
    
}

- (void)testPickerBeginTimeBy23 {
//    BusinessListController *controller = [[BusinessListController alloc]init];
//    
//    id mockController = OCMPartialMock(controller);
//    
//    //模拟今天23点
//    OCMStub([mockController currentHour])._andReturn(@(23));
//    [controller chooseTimeList];
//    [controller showPickView];
//    NSArray *currentTimeArray = controller.todayTimeArray;
//    
//    //切换数据源后，检查当天日期是否满足要求
//    XCTAssertNotNil(controller.timeArray,@"data list is nil");
//    XCTAssertEqual([controller.timeArray count], 3,@"data list count is not 3");
//    XCTAssertEqual([controller.timeArray[0] count], 7,@"data list count is not 7");
//    XCTAssertEqual([controller.timeArray[1] count], 17,@"data list count is not 17");
//    XCTAssertEqual([controller.timeArray[2] count], 4,@"data list count is not 4");
//    XCTAssertEqual([controller.dayArray count], 7,@"day Array count is not 7");
//    XCTAssertTrue([currentTimeArray[0] isEqualToString:@"7:00"],@"currentTimeArray[0] %@", currentTimeArray[0]);
//    
//    //模拟拨动第一个轮第一行
//    //模拟第一次展示
//    NSInteger row = [controller.pickerView.dataPickerView selectedRowInComponent:1];
//    
//    UILabel *titleView = (UILabel *)[controller.pickerView pickerView:controller.pickerView.dataPickerView viewForRow:row forComponent:1 reusingView:nil];
//    XCTAssert([currentTimeArray[row] isEqualToString:@"18:00"],@"first row is %@",currentTimeArray[row]);
//    XCTAssert([titleView.text isEqualToString:@"18:00"],@"title is %@",titleView.text);
//    XCTAssertTrue([currentTimeArray[0] isEqualToString:@"7:00"],@"currentTimeArray[0] %@", currentTimeArray[0]);
//    
//    //模拟拨动第一个轮第二行,程序指定selectRow,不会出发didSelect,所以这里手动调用
//    [controller.pickerView.dataPickerView selectRow:1 inComponent:0 animated:NO];
//    [controller.pickerView pickerView:controller.pickerView.dataPickerView didSelectRow:1 inComponent:0];
//    
//    row = [controller.pickerView.dataPickerView selectedRowInComponent:1];
//    titleView = (UILabel *)[controller.pickerView pickerView:controller.pickerView.dataPickerView viewForRow:row forComponent:1 reusingView:nil];
//    
//    currentTimeArray = controller.timeArray[1];
//    XCTAssert([controller.timeArray[1][row] isEqualToString:@"18:00"],@"first row is %@",currentTimeArray[row]);
//    XCTAssert([titleView.text isEqualToString:@"18:00"],@"title is %@",titleView.text);
//    
}


- (void)testPickerBeginTimeBy1 {
//    BusinessListController *controller = [[BusinessListController alloc]init];
//    
//    id mockController = OCMPartialMock(controller);
//    
//    //模拟今天1点
//    OCMStub([mockController currentHour])._andReturn(@(1));
//    [controller chooseTimeList];
//    [controller showPickView];
//    
//    NSArray *currentTimeArray = controller.todayTimeArray;
//    
//    //切换数据源后，检查当天日期是否满足要求
//    XCTAssertNotNil(controller.timeArray,@"data list is nil");
//    XCTAssertEqual([controller.timeArray count], 3,@"data list count is not 3");
//    XCTAssertEqual([controller.timeArray[0] count], 7,@"data list count is not 7");
//    XCTAssertEqual([controller.timeArray[1] count], 17,@"data list count is not 17");
//    XCTAssertEqual([controller.timeArray[2] count], 4,@"data list count is not 4");
//    XCTAssertEqual([controller.dayArray count], 7,@"day Array count is not 7");
//    XCTAssertTrue([currentTimeArray[0] isEqualToString:@"7:00"],@"currentTimeArray[0] %@", currentTimeArray[0]);
//    
//    //模拟拨动第一个轮第一行
//    //模拟第一次展示
//    NSInteger row = [controller.pickerView.dataPickerView selectedRowInComponent:1];
//    
//    UILabel *titleView = (UILabel *)[controller.pickerView pickerView:controller.pickerView.dataPickerView viewForRow:row forComponent:1 reusingView:nil];
//    
//    XCTAssertTrue([currentTimeArray[0] isEqualToString:@"7:00"],@"currentTimeArray[0] %@", currentTimeArray[0]);
//    XCTAssert([currentTimeArray[row] isEqualToString:@"18:00"],@"first row is %@",currentTimeArray[row]);
//    XCTAssert([titleView.text isEqualToString:@"18:00"],@"title is %@",titleView.text);
//    
//    //模拟拨动第一个轮第二行,程序指定selectRow,不会出发didSelect,所以这里手动调用
//    [controller.pickerView.dataPickerView selectRow:1 inComponent:0 animated:NO];
//    [controller.pickerView pickerView:controller.pickerView.dataPickerView didSelectRow:1 inComponent:0];
//    
//    row = [controller.pickerView.dataPickerView selectedRowInComponent:1];
//    titleView = (UILabel *)[controller.pickerView pickerView:controller.pickerView.dataPickerView viewForRow:row forComponent:1 reusingView:nil];
//    
//    currentTimeArray = controller.timeArray[1];
//    XCTAssertTrue([currentTimeArray[0] isEqualToString:@"7:00"],@"currentTimeArray[0] %@", currentTimeArray[0]);
//    XCTAssert([controller.timeArray[1][row] isEqualToString:@"18:00"],@"first row is %@",currentTimeArray[row]);
//    XCTAssert([titleView.text isEqualToString:@"18:00"],@"title is %@",titleView.text);
//    
//    //模拟拨动第一个轮第一行,程序指定selectRow,不会出发didSelect,所以这里手动调用
//    [controller.pickerView.dataPickerView selectRow:0 inComponent:0 animated:NO];
//    [controller.pickerView pickerView:controller.pickerView.dataPickerView didSelectRow:0 inComponent:0];
//    titleView = (UILabel *)[controller.pickerView pickerView:controller.pickerView.dataPickerView viewForRow:row forComponent:1 reusingView:nil];
//    
//    currentTimeArray = controller.timeArray[1];
//    XCTAssertTrue([currentTimeArray[0] isEqualToString:@"7:00"],@"currentTimeArray[0] %@", currentTimeArray[0]);
//    XCTAssert([currentTimeArray[row] isEqualToString:@"18:00"],@"first row is %@",currentTimeArray[row]);
//    XCTAssert([titleView.text isEqualToString:@"18:00"],@"title is %@",titleView.text);
}

- (void)testPickerBeginTime19 {
//    BusinessListController *controller = [[BusinessListController alloc]init];
//    
//    [controller chooseTimeList];
//    [controller showPickView];
//    NSArray *currentTimeArray = controller.todayTimeArray;
//    
//    id mockController = OCMPartialMock(controller);
//    
//    //模拟今天19点
//    OCMStub([mockController currentHour])._andReturn(@(19));
//    NSString *expectTime = @"20:00";
//    [controller chooseTimeList];
//    controller.pickerView = nil;
//    [controller showPickView];
//    currentTimeArray = controller.todayTimeArray;
//    
//    //切换数据源后，检查当天日期是否满足要求
//    XCTAssertNotNil(controller.timeArray,@"data list is nil");
//    XCTAssertEqual([controller.timeArray count], 3,@"data list count is not 3");
//    XCTAssertEqual([controller.timeArray[0] count], 7,@"data list count is not 7");
//    XCTAssertEqual([controller.timeArray[1] count], 17,@"data list count is not 17");
//    XCTAssertEqual([controller.timeArray[2] count], 4,@"data list count is not 4");
//    XCTAssertEqual([controller.dayArray count], 7,@"day Array count is not 7");
//    XCTAssertTrue([currentTimeArray[0] isEqualToString:expectTime],@"currentTimeArray[0] %@", currentTimeArray[0]);
//    
//    //模拟拨动第一个轮第一行
//    //模拟第一次展示
//    NSInteger row = [controller.pickerView.dataPickerView selectedRowInComponent:1];
//    
//    UILabel *titleView = (UILabel *)[controller.pickerView pickerView:controller.pickerView.dataPickerView viewForRow:row forComponent:1 reusingView:nil];
//    
//    XCTAssertTrue([currentTimeArray[0] isEqualToString:expectTime],@"currentTimeArray[0] %@", currentTimeArray[0]);
//    XCTAssert([currentTimeArray[row] isEqualToString:expectTime],@"first row is %@",currentTimeArray[row]);
//    XCTAssert([titleView.text isEqualToString:expectTime],@"title is %@",titleView.text);
//    
//    //模拟拨动第一个轮第二行,程序指定selectRow,不会出发didSelect,所以这里手动调用
//    [controller.pickerView.dataPickerView selectRow:1 inComponent:0 animated:NO];
//    [controller.pickerView pickerView:controller.pickerView.dataPickerView didSelectRow:1 inComponent:0];
//    
//    row = [controller.pickerView.dataPickerView selectedRowInComponent:1];
//    titleView = (UILabel *)[controller.pickerView pickerView:controller.pickerView.dataPickerView viewForRow:row forComponent:1 reusingView:nil];
//    
//    currentTimeArray = controller.timeArray[1];
//    XCTAssertTrue([currentTimeArray[0] isEqualToString:@"7:00"],@"currentTimeArray[0] %@", currentTimeArray[0]);
//    XCTAssert([currentTimeArray[row] isEqualToString:expectTime],@"first row is %@",currentTimeArray[row]);
//    XCTAssert([titleView.text isEqualToString:expectTime],@"title is %@",titleView.text);
    
}


- (void)testPickerBeginTime14AndChangeTime {
//    BusinessListController *controller = [[BusinessListController alloc]init];
//    
//    [controller chooseTimeList];
//    [controller showPickView];
//    NSArray *currentTimeArray = controller.todayTimeArray;
//    
//    id mockController = OCMPartialMock(controller);
//    
//    //模拟今天14点
//    OCMStub([mockController currentHour])._andReturn(@(14));
//    NSString *expectTime = @"18:00";
//    [controller chooseTimeList];
//    controller.pickerView = nil;
//    [controller showPickView];
//    currentTimeArray = controller.todayTimeArray;
//    
//    //切换数据源后，检查当天日期是否满足要求
//    XCTAssertNotNil(controller.timeArray,@"data list is nil");
//    XCTAssertEqual([controller.timeArray count], 3,@"data list count is not 3");
//    XCTAssertEqual([controller.timeArray[0] count], 7,@"data list count is not 7");
//    XCTAssertEqual([controller.timeArray[1] count], 17,@"data list count is not 17");
//    XCTAssertEqual([controller.timeArray[2] count], 4,@"data list count is not 4");
//    XCTAssertEqual([controller.dayArray count], 7,@"day Array count is not 7");
//    XCTAssertTrue([currentTimeArray[0] isEqualToString:@"15:00"],@"currentTimeArray[0] %@", currentTimeArray[0]);
//    
//    //模拟拨动第一个轮第一行
//    //模拟第一次展示
//    NSInteger row = [controller.pickerView.dataPickerView selectedRowInComponent:1];
//    
//    UILabel *titleView = (UILabel *)[controller.pickerView pickerView:controller.pickerView.dataPickerView viewForRow:row forComponent:1 reusingView:nil];
//    
//    XCTAssertTrue([currentTimeArray[0] isEqualToString:@"15:00"],@"currentTimeArray[0] %@", currentTimeArray[0]);
//    XCTAssert([currentTimeArray[row] isEqualToString:expectTime],@"first row is %@",currentTimeArray[row]);
//    XCTAssert([titleView.text isEqualToString:expectTime],@"title is %@",titleView.text);
//    
//    //模拟拨动第二个轮到row+1,程序指定selectRow,不会出发didSelect,所以这里手动调用
//    [controller.pickerView.dataPickerView selectRow:row+1 inComponent:1 animated:NO];
//    [controller.pickerView pickerView:controller.pickerView.dataPickerView didSelectRow:row+1 inComponent:1];
//    titleView = (UILabel *)[controller.pickerView pickerView:controller.pickerView.dataPickerView viewForRow:row+1 forComponent:1 reusingView:nil];
//    XCTAssert([titleView.text isEqualToString:@"19:00"],@"title is %@",titleView.text);
//    
//    //模拟拨动第一个轮第二行,程序指定selectRow,不会出发didSelect,所以这里手动调用
//    [controller.pickerView.dataPickerView selectRow:1 inComponent:0 animated:NO];
//    [controller.pickerView pickerView:controller.pickerView.dataPickerView didSelectRow:1 inComponent:0];
//    
//    row = [controller.pickerView.dataPickerView selectedRowInComponent:1];
//    titleView = (UILabel *)[controller.pickerView pickerView:controller.pickerView.dataPickerView viewForRow:row forComponent:1 reusingView:nil];
//    
//    currentTimeArray = controller.timeArray[1];
//    XCTAssertTrue([currentTimeArray[0] isEqualToString:@"7:00"],@"currentTimeArray[0] %@", currentTimeArray[0]);
//    XCTAssert([currentTimeArray[row] isEqualToString:@"19:00"],@"first row is %@",currentTimeArray[row]);
//    XCTAssert([titleView.text isEqualToString:@"19:00"],@"title is %@",titleView.text);
//    
//    //模拟拨动第二个轮第三行,程序指定selectRow,不会出发didSelect,所以这里手动调用
//    [controller.pickerView.dataPickerView selectRow:2 inComponent:1 animated:NO];
//    [controller.pickerView pickerView:controller.pickerView.dataPickerView didSelectRow:2 inComponent:1];
//    
//    row = [controller.pickerView.dataPickerView selectedRowInComponent:1];
//    titleView = (UILabel *)[controller.pickerView pickerView:controller.pickerView.dataPickerView viewForRow:row forComponent:1 reusingView:nil];
//    
//    currentTimeArray = controller.timeArray[1];
//    XCTAssertTrue([currentTimeArray[0] isEqualToString:@"7:00"],@"currentTimeArray[0] %@", currentTimeArray[0]);
//    XCTAssert([currentTimeArray[row] isEqualToString:@"9:00"],@"first row is %@",currentTimeArray[row]);
//    XCTAssert([titleView.text isEqualToString:@"9:00"],@"title is %@",titleView.text);
//    
//    //模拟拨动第一个轮第二行，第二个轮第四行,程序指定selectRow,不会出发didSelect,所以这里手动调用
//    [controller.pickerView.dataPickerView selectRow:2 inComponent:0 animated:NO];
//    [controller.pickerView pickerView:controller.pickerView.dataPickerView didSelectRow:2 inComponent:0];
//    [controller.pickerView.dataPickerView selectRow:3 inComponent:1 animated:NO];
//    [controller.pickerView pickerView:controller.pickerView.dataPickerView didSelectRow:3 inComponent:1];
//    
//    row = [controller.pickerView.dataPickerView selectedRowInComponent:1];
//    titleView = (UILabel *)[controller.pickerView pickerView:controller.pickerView.dataPickerView viewForRow:row forComponent:1 reusingView:nil];
//    
//    currentTimeArray = controller.timeArray[1];
//    XCTAssertTrue([currentTimeArray[0] isEqualToString:@"7:00"],@"currentTimeArray[0] %@", currentTimeArray[0]);
//    XCTAssert([currentTimeArray[row] isEqualToString:@"10:00"],@"first row is %@",currentTimeArray[row]);
//    XCTAssert([titleView.text isEqualToString:@"10:00"],@"title is %@",titleView.text);
}

@end
