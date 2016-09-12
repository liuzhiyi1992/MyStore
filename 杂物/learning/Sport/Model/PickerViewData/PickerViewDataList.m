//
//  PickerViewDataList.m
//  Sport
//
//  Created by xiaoyang on 16/5/28.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "PickerViewDataList.h"
#import "DateUtil.h"
#import "NSDate+Utils.h"

@interface PickerViewDataList()

/**
 * 今天的开始小时列表
 * @return 二维数组,例如:[@"18",nil],[@"18:00",nil]
 * (两数组一起生成的原因是防止两组值不对应)
 **/
+ (NSArray *)todayHourDataSource;


/**
 * 开始小时 (没后缀)
 * @return 一维数组,例如:[@"18",nil]
 **/
+ (NSMutableArray *)hourArrayNoSuffix;


/**
 * 开始小时 (有后缀)
 * @return 一维数组,例如:[@"18:00",nil]
 **/
+ (NSMutableArray *)hourArrayHaveSuffix;


/**
 * 时长 (没后缀)
 * @return 一维数组,例如:[@"3",nil]
 **/
+ (NSMutableArray *)timeIntervalArrayNoSuffix;


/**
 * 时长 (有后缀)
 * @return 一维数组,例如:[@"3小时",nil]
 **/
+ (NSMutableArray *)timeIntervalArrayHaveSuffix;


/**
 * 日期数据源
 * @return 二维数组,有四个子数组
 *  例如:
 *  第一个:[@"10月11日(周二)",nil],
 *  第二个:[@"10月11日",nil],
 *  第三个:[@"(周二)",nil],
 *  第四个:[[NSDate date],nil],
 *  第五个:[@"11日(周二)",nil],
 **/
+ (NSMutableArray *)pickerViewDateDataSource;


/**
 * 足球人数 (有后缀)
 * @return 一维数组,例如:[@"5人场",nil]
 **/
+ (NSMutableArray *)soccerPersonHaveSuffixArray;


/**
 * 足球人数 (没后缀)
 * @return 一维数组,例如:[@"5",nil]
 **/
+ (NSMutableArray *)soccerPersonNoSuffixArray;


/**
 * 室内外数据
 * @return 一维数组,例如:[@"室内",@"室外",nil]
 **/
+ (NSMutableArray *)indoorOroutdoorArray;


/**
 * 室内外数据ID
 * @return 一维数组,例如:[@"3",@"4",nil]
 **/
+ (NSMutableArray *)indoorOroutdoorIdArray;

@end


@implementation PickerViewDataList

static BusinessPickerData *_globalBusinessPickerData = nil;

+ (BusinessPickerData *)data {
    NSDate *nowTime = [NSDate date];
    NSDate *lastTime = _globalBusinessPickerData.createTime;
    
    BOOL isSameTime = (nowTime.year == lastTime.year
                       && nowTime.month == lastTime.month
                       && nowTime.day == lastTime.day
                       && nowTime.hour == lastTime.hour);
    
    //如果是nil，或跟上次生成数据的时间不在同一个时钟小时内，则重新生成
    if (_globalBusinessPickerData == nil || !isSameTime) {
        
        NSArray *todaySource = [self todayHourDataSource];
        NSArray *dateSource = [self pickerViewDateDataSource];
        
        _globalBusinessPickerData = [[BusinessPickerData alloc] initWithCreateTime:nowTime
                                                            todayHourArrayNoSuffix:(todaySource.count > 0 ? todaySource[0] : nil)
                                                          todayHourArrayHaveSuffix:(todaySource.count > 1 ? todaySource[1] : nil)
                                                                 hourArrayNoSuffix:[self hourArrayNoSuffix]
                                                               hourArrayHaveSuffix:[self hourArrayHaveSuffix]
                                                         timeIntervalArrayNoSuffix:[self timeIntervalArrayNoSuffix]
                                                       timeIntervalArrayHaveSuffix:[self timeIntervalArrayHaveSuffix]
                                                                         dateArray:(dateSource.count > 3 ? dateSource[3] : nil)
                                                                     monthDayArray:(dateSource.count > 1 ? dateSource[1] : nil)
                                                                         weekArray:(dateSource.count > 2 ? dateSource[2] : nil)
                                                                 monthDayWeekArray:(dateSource.count > 0 ? dateSource[0] : nil)
                                                                      dayWeekArray:(dateSource.count > 4 ? dateSource[4] : nil)
                                                       soccerPersonHaveSuffixArray:[self soccerPersonHaveSuffixArray]
                                                         soccerPersonNoSuffixArray:[self soccerPersonNoSuffixArray]
                                                              indoorOroutdoorArray:[self indoorOroutdoorArray]
                                                            indoorOroutdoorIdArray:[self indoorOroutdoorIdArray]];
    }
    return _globalBusinessPickerData;
}

+ (NSInteger)currentHour{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[NSDate date]];
    return [components hour];
}

//注意当天的时候不显示星期几，而是今天
+ (NSMutableArray *)pickerViewDateDataSource{
    NSMutableArray *monthDayWeekArray = [NSMutableArray array];
    NSMutableArray *monthDayArray = [NSMutableArray array];
    NSMutableArray *weekArray = [NSMutableArray array];
    NSMutableArray *dayWeekArray = [NSMutableArray array];
    
    NSMutableArray *allDate = [NSMutableArray array];
    NSInteger hour = [PickerViewDataList currentHour];
    
    for (int i = 0; i < 7; i++) {
        NSDate *day = nil;
        if (hour >= 23) {
            day = [[NSDate date] dateByAddingTimeInterval: 24 * 60 * 60 * (i+1)];
        } else {
            day = [[NSDate date] dateByAddingTimeInterval: 24 * 60 * 60 * i];
        }
        [allDate addObject:day];
        
        NSString *monthDayWeekString = @"";
        NSString *monthDayString = @"";
        NSString *weekString = @"";
        NSString *dayWeekString = @"";
        
        monthDayString = [PickerViewDataList dateFormatTransformToNSString:day];
        weekString = [DateUtil todayAndOtherWeekString:day];
        monthDayWeekString = [NSString stringWithFormat:@"%@%@",monthDayString,weekString];
        dayWeekString = [NSString stringWithFormat:@"%@%@",[DateUtil stringFromDate:day DateFormat:@"dd日"],weekString];
        
        //日期显示的数据源
        [monthDayWeekArray addObject:monthDayWeekString];
        [monthDayArray addObject:monthDayString];
        [weekArray addObject:weekString];
        [dayWeekArray addObject:dayWeekString];
    }
    
    //全部数据源
    NSMutableArray *allArray = [NSMutableArray arrayWithObjects:monthDayWeekArray, monthDayArray, weekArray, allDate, dayWeekArray, nil];
    return allArray;
}

+ (NSString *)dateFormatTransformToNSString:(NSDate *)date {
    return [DateUtil stringFromDate:date DateFormat:@"MM月dd日"];
}

#define DEFAULT_START_TIME 6 //默认最早开始时间6点

+ (NSArray *)todayHourDataSource {
    NSMutableArray *noSuffix = [NSMutableArray array];
    NSMutableArray *haveSuffix = [NSMutableArray array];
    int hour = (int)[self currentHour] + 1;
    hour = MAX(DEFAULT_START_TIME, hour);
    for (; hour <= 23; hour++) {
        NSString *timeNoSuffix = [NSString stringWithFormat:@"%d",hour];
        NSString *timeHaveSuffix = [NSString stringWithFormat:@"%@:00",timeNoSuffix];
        [noSuffix addObject:timeNoSuffix];
        [haveSuffix addObject:timeHaveSuffix];
    }
    return @[noSuffix, haveSuffix];
}

#pragma mark - 没后缀
+ (NSMutableArray *)hourArrayNoSuffix {
    NSMutableArray *hourArrayNoSuffix = [NSMutableArray array];
    for (int hour = DEFAULT_START_TIME; hour <= 23; hour++) {
        NSString *timeNoSuffix = [NSString stringWithFormat:@"%d",hour];
        [hourArrayNoSuffix addObject:timeNoSuffix];
    }
    return hourArrayNoSuffix;
}

+ (NSMutableArray *)timeIntervalArrayNoSuffix {
    NSMutableArray *timeIntervalArrayNoSuffix = [NSMutableArray array];
    for (int i = 0; i < 4; i++) {
        NSString *timeIntervalNoSuffix = [NSString stringWithFormat:@"%d",i+1];
        [timeIntervalArrayNoSuffix addObject:timeIntervalNoSuffix];
    }
    return timeIntervalArrayNoSuffix;
}

#pragma mark - 有后缀
+ (NSMutableArray *)hourArrayHaveSuffix{
    NSMutableArray *hourArrayHaveSuffix = [NSMutableArray array];
    for (NSString *one in [PickerViewDataList hourArrayNoSuffix]){
        NSString *timeHaveSuffix = [NSString stringWithFormat:@"%@:00",one];
        [hourArrayHaveSuffix addObject:timeHaveSuffix];
    }
    return hourArrayHaveSuffix;
}

+ (NSMutableArray *)timeIntervalArrayHaveSuffix{
    NSMutableArray *timeIntervalArrayHaveSuffix = [NSMutableArray array];
    for (NSString *one in [PickerViewDataList timeIntervalArrayNoSuffix]){
        NSString *timeIntervalSuffix = [NSString stringWithFormat:@"%@小时",one];
        [timeIntervalArrayHaveSuffix addObject:timeIntervalSuffix];
    }
    return timeIntervalArrayHaveSuffix;
}

//足球人数数据源
+ (NSMutableArray *)soccerPersonHaveSuffixArray{
    NSMutableArray *soccerPersonArray = [NSMutableArray array];
    for (NSString *numberString in [self soccerPersonNoSuffixArray]) {
        if ([numberString isEqualToString:PEOPLE_NUMBER_ALL]) {
            [soccerPersonArray addObject:@"不限"];
        } else {
            [soccerPersonArray addObject:[NSString stringWithFormat:@"%@人场", numberString]];
        }
    }
    return soccerPersonArray;
}

//足球人数没有后缀数据源
+ (NSMutableArray *)soccerPersonNoSuffixArray{
    return [NSMutableArray arrayWithObjects:@"3",@"5",@"7",@"9",@"11",PEOPLE_NUMBER_ALL, nil];
}

//室内外显示数据源
+ (NSMutableArray *)indoorOroutdoorArray{
    NSDictionary *dic = @{FILTRATE_ID_INDOOR:@"室内",
                          FILTRATE_ID_OUTDOOR:@"室外",
                          FILTRATE_ID_ALL:@"不限"};
    NSMutableArray *indoorOroutdoorArray = [NSMutableArray array];
    for (NSString *idString in [self indoorOroutdoorIdArray]) {
        NSString *name = @"不限";
        name = [dic objectForKey:idString];
        [indoorOroutdoorArray addObject:name];
    }
    return indoorOroutdoorArray;
}

//室内外id数据源
+ (NSMutableArray *)indoorOroutdoorIdArray {
    return [NSMutableArray arrayWithObjects:FILTRATE_ID_INDOOR,FILTRATE_ID_OUTDOOR,FILTRATE_ID_ALL, nil];
}

@end
