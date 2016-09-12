//
//  BusinessListPickerView.m
//  Sport
//
//  Created by 冯俊霖 on 15/10/20.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "BusinessListPickerView.h"
#import "UIView+Utils.h"
#import "PickerViewDataList.h"
#import "DateUtil.h"
#import "NSDate+Utils.h"
#import "BusinessListPickerView.h"


@interface BusinessListPickerView()
@property (weak, nonatomic) IBOutlet UIView *pickerHolderView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lineImageConstraintHeight;
@property (strong, nonatomic) BusinessPickerData *myData;
@property (copy, nonatomic) NSString *categoryId;
@property (strong, nonatomic) NSDate *selectedDate;
@property (copy, nonatomic) NSString *selectedStartHour;    //例如:@"18"
@property (copy, nonatomic) NSString *selectedTimeTnterval; //例如:@"2"
@property (copy, nonatomic) NSString *selectedSoccerNumber; //例如:@"9"
@property (strong,nonatomic) NSString *tempTime;   //例如:@"18:00"

@property (readwrite, strong, nonatomic) NSArray *firstShowList;
@property (readwrite, strong, nonatomic) NSArray *secondShowList;
@property (readwrite, strong, nonatomic) NSArray *thirdShowList;

@property (strong, nonatomic) NSArray *firstValueList;
@property (strong, nonatomic) NSArray *secondValueList;
@property (strong, nonatomic) NSArray *thirdValueList;

@property(copy, nonatomic) void (^OKHandler)(NSDate *date, NSString *startHour, NSString *timeTnterval, NSString *soccerNumber);
@end


@implementation BusinessListPickerView

+ (BusinessListPickerView *)createBusinessListPickerView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"BusinessListPickerView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    BusinessListPickerView *view = [topLevelObjects objectAtIndex:0];
    [view bringSubviewToFront:view.pickerHolderView];
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat y = screenHeight - view.pickerHolderView.frame.size.height;
    view.lineImageConstraintHeight.constant = 0.5;
    [view.pickerHolderView updateOriginY:y];
    return view;
}

+ (BusinessListPickerView *)showWithCategoryId:(NSString *)categoryId
                                  selectedDate:(NSDate *)selectedDate
                             selectedStartHour:(NSString *)selectedStartHour
                          selectedTimeTnterval:(NSString *)selectedTimeTnterval
                          selectedSoccerNumber:(NSString *)selectedSoccerNumber
                                     OKHandler:(void (^)(NSDate *date, NSString *startHour, NSString *timeTnterval, NSString *soccerNumber))OKHandler
{
    BusinessListPickerView *view = [BusinessListPickerView createBusinessListPickerView];
    view.myData = [PickerViewDataList data];
    
    //保存传入值
    view.categoryId = categoryId;
    view.selectedDate = selectedDate;
    view.selectedStartHour = selectedStartHour;
    view.selectedTimeTnterval = selectedTimeTnterval;
    view.selectedSoccerNumber = selectedSoccerNumber;
    view.OKHandler = OKHandler;
    
    //显示
    UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow];
    view.frame = [UIScreen mainScreen].bounds;
    [keywindow addSubview:view];
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    [view.pickerHolderView updateOriginY:screenHeight];
    [UIView animateWithDuration:0.2 animations:^{
        CGFloat y = screenHeight - view.pickerHolderView.frame.size.height;
        [view.pickerHolderView updateOriginY:y];
    }];
    
    //如果没有选中日期，则默认是列表第一天(即今天);如果今天已经超过21点，则默认显示第二天
    if (view.selectedDate == nil) {
        NSInteger currentHour = [PickerViewDataList currentHour];
        if (21 <= currentHour && currentHour < 23) {
            view.selectedDate = (view.myData.dateArray.count > 1 ? view.myData.dateArray[1] : nil);
        } else {
            view.selectedDate = (view.myData.dateArray.count > 0 ? view.myData.dateArray[0] : nil);
        }
    }
    
    //此updateDataSource一定要放在selectedDate赋值之后，因为根据它来更新数据源
    [view updateDataSource];
    
    //如果没有选中开始小时,则默认是18,如果今天已超过18,则取第一个值
    if (view.selectedStartHour == nil) {
        if ([view.secondValueList containsObject:@"18"]) {
            view.selectedStartHour = @"18";
        } else {
            view.selectedStartHour = (view.secondValueList.count > 0 ? view.secondValueList[0] : nil);
        }
    }
    
    //如果没有选中时长，则默认两小时
    if (view.selectedTimeTnterval == nil && ![view hasSoccerNumber]) {
        if ([view.thirdValueList count] > 1) {
            view.selectedTimeTnterval = view.thirdValueList[1];
        }
    }
    
    [view updateDefaultSelect];
    
    return view;
}

- (void)updateDataSource {

    self.firstShowList  = self.myData.dayWeekArray;
    self.firstValueList = self.myData.dateArray;
    
    if ([self isTodayInFirstComponent] && self.myData.todayHourArrayHaveSuffix.count > 0) {
        self.secondShowList  = self.myData.todayHourArrayHaveSuffix;
        self.secondValueList = self.myData.todayHourArrayNoSuffix ;
    } else {
        self.secondShowList  = self.myData.hourArrayHaveSuffix;
        self.secondValueList = self.myData.hourArrayNoSuffix;
    }
    
    if ([self hasSoccerNumber]) {
        self.thirdShowList  = self.myData.soccerPersonHaveSuffixArray;
        self.thirdValueList = self.myData.soccerPersonNoSuffixArray;
    } else {
        self.thirdShowList = self.myData.timeIntervalArrayHaveSuffix;
        self.thirdValueList = self.myData.timeIntervalArrayNoSuffix;
    }
    
    [self.dataPickerView reloadAllComponents];
}

- (void)setSelectedDate:(NSDate *)selectedDate {
    _selectedDate = selectedDate;
    [self updateDataSource];
}

//切到默认选中行
- (void)updateDefaultSelect {
    
    //第一列
    NSInteger first = 0;
    for (int i = 0 ; i < self.firstValueList.count; i ++) {
        NSDate *one = self.firstValueList[i];
        if ([self.selectedDate isEqualToDateIgnoringTime:one]) {
            first = i;
            break;
        }
    }
    [self perfectSelectRow:first component:0];
    
    //第二列
    NSInteger second = 0;
    for (int i = 0 ; i < self.secondValueList.count; i ++) {
        NSString *one = self.secondValueList[i];
        if ([self.selectedStartHour isEqualToString:one]) {
            second = i;
            break;
        }
    }
    [self perfectSelectRow:second component:1];
    
    //第三列
    NSString *useValue = ([self hasSoccerNumber] ? self.selectedSoccerNumber : self.selectedTimeTnterval);
    NSInteger third = 0;
    for (int i = 0 ; i < self.thirdValueList.count; i ++) {
        NSString *one = self.thirdValueList[i];
        if ([useValue isEqualToString:one]) {
            third = i;
            break;
        }
    }
    [self perfectSelectRow:third component:2];
}

- (void)perfectSelectRow:(NSInteger)row
               component:(NSInteger)component {
    [self.dataPickerView selectRow:row inComponent:component animated:NO];
    if (component == 1) {
        self.tempTime = (self.secondShowList.count > row ? self.secondShowList[row] : nil);
    }
}

- (BOOL)isTodayInFirstComponent
{
    return [self.selectedDate isToday];
}

- (BOOL)hasSoccerNumber {
    return [self.categoryId isEqualToString:@"11"];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return self.firstShowList.count;
    } else if (component == 1) {
        return self.secondShowList.count;
    } else {
        return self.thirdShowList.count;
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    NSString *title = nil;
    if (component == 0) {
        title = self.firstShowList[row];
    } else if (component == 1) {
        title = self.secondShowList[row];
    } else {
        title = self.thirdShowList[row];
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)] ;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    label.text = title;
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        self.selectedDate = (self.firstValueList.count > row ? self.firstValueList[row] : nil);

        //刷新
        [pickerView reloadComponent:1];
        
        //当选完第一列时，自动切换第二列
        NSInteger index = [self.secondShowList indexOfObject:self.tempTime];
        if (index == NSNotFound) {
            index = 0;
        }
        [self perfectSelectRow:index component:1];
        
    } else if (component == 1) {
        self.tempTime = (self.secondShowList.count > row ? self.secondShowList[row] : nil);
    }
}

- (IBAction)clickCancelButton:(id)sender {
    [MobClickUtils event:umeng_event_business_list_click_time label:@"取消"];
    [self removeFromSuperview];
}

- (IBAction)clickOKButton:(id)sender {
    NSInteger first = [self.dataPickerView selectedRowInComponent:0];
    NSInteger second = [self.dataPickerView selectedRowInComponent:1];
    NSInteger third = [self.dataPickerView selectedRowInComponent:2];
    
    NSDate *date = (self.firstValueList.count > first ? self.firstValueList[first] : self.selectedDate);
    NSString *startHour = (self.secondValueList.count > second ? self.secondValueList[second] : self.selectedStartHour);
    NSString *timeTnterval = nil;
    NSString *soccerNumber = nil;
    if ([self hasSoccerNumber]) {
        soccerNumber = (self.thirdValueList.count > third ? self.thirdValueList[third] : self.selectedSoccerNumber);
    } else {
        timeTnterval = (self.thirdValueList.count > third ? self.thirdValueList[third] : self.selectedTimeTnterval);
        
        if ([startHour intValue] + [timeTnterval intValue] > 24) {
            timeTnterval = [@(24 - [startHour intValue]) stringValue];
        }
    }
    
    if (self.OKHandler) {
        self.OKHandler(date, startHour, timeTnterval, soccerNumber);
    }
    
    [MobClickUtils event:umeng_event_business_list_click_time label:@"完成"];
    [self removeFromSuperview];
}

@end
