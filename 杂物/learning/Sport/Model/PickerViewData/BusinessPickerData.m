//
//  BusinessPickerData.m
//  Sport
//
//  Created by xiaoyang on 16/5/28.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "BusinessPickerData.h"

@interface BusinessPickerData()

@property (readwrite, strong, nonatomic) NSArray *todayHourArrayNoSuffix;
@property (readwrite, strong, nonatomic) NSArray *todayHourArrayHaveSuffix;
@property (readwrite, strong, nonatomic) NSArray *hourArrayNoSuffix;
@property (readwrite, strong, nonatomic) NSArray *hourArrayHaveSuffix;
@property (readwrite, strong, nonatomic) NSArray *timeIntervalArrayNoSuffix;
@property (readwrite, strong, nonatomic) NSArray *timeIntervalArrayHaveSuffix;
@property (readwrite, strong, nonatomic) NSArray *dateArray;
@property (readwrite, strong, nonatomic) NSArray *monthDayArray;
@property (readwrite, strong, nonatomic) NSArray *weekArray;
@property (readwrite, strong, nonatomic) NSArray *monthDayWeekArray;
@property (readwrite, strong, nonatomic) NSArray *dayWeekArray;
@property (readwrite, strong, nonatomic) NSArray *soccerPersonHaveSuffixArray;
@property (readwrite, strong, nonatomic) NSArray *soccerPersonNoSuffixArray;
@property (readwrite, strong, nonatomic) NSArray *indoorOroutdoorArray;
@property (readwrite, strong, nonatomic) NSArray *indoorOroutdoorIdArray;
@property (readwrite, strong, nonatomic) NSDate *createTime;
@end


@implementation BusinessPickerData

- (instancetype)initWithCreateTime:(NSDate *)createTime
            todayHourArrayNoSuffix:(NSArray *)todayHourArrayNoSuffix
          todayHourArrayHaveSuffix:(NSArray *)todayHourArrayHaveSuffix
                 hourArrayNoSuffix:(NSArray *)hourArrayNoSuffix
               hourArrayHaveSuffix:(NSArray *)hourArrayHaveSuffix
         timeIntervalArrayNoSuffix:(NSArray *)timeIntervalArrayNoSuffix
       timeIntervalArrayHaveSuffix:(NSArray *)timeIntervalArrayHaveSuffix
                         dateArray:(NSArray *)dateArray
                     monthDayArray:(NSArray *)monthDayArray
                         weekArray:(NSArray *)weekArray
                 monthDayWeekArray:(NSArray *)monthDayWeekArray
                      dayWeekArray:(NSArray *)dayWeekArray
       soccerPersonHaveSuffixArray:(NSArray *)soccerPersonHaveSuffixArray
         soccerPersonNoSuffixArray:(NSArray *)soccerPersonNoSuffixArray
              indoorOroutdoorArray:(NSArray *)indoorOroutdoorArray
            indoorOroutdoorIdArray:(NSArray *)indoorOroutdoorIdArray
{
    self = [super init];
    if (self) {
        self.createTime = createTime;
        self.todayHourArrayNoSuffix = todayHourArrayNoSuffix;
        self.todayHourArrayHaveSuffix = todayHourArrayHaveSuffix;
        self.hourArrayNoSuffix = hourArrayNoSuffix;
        self.hourArrayHaveSuffix = hourArrayHaveSuffix;
        self.timeIntervalArrayNoSuffix = timeIntervalArrayNoSuffix;
        self.timeIntervalArrayHaveSuffix = timeIntervalArrayHaveSuffix;
        self.dateArray = dateArray;
        self.monthDayArray = monthDayArray;
        self.weekArray = weekArray;
        self.monthDayWeekArray = monthDayWeekArray;
        self.dayWeekArray = dayWeekArray;
        self.soccerPersonHaveSuffixArray = soccerPersonHaveSuffixArray;
        self.soccerPersonNoSuffixArray = soccerPersonNoSuffixArray;
        self.indoorOroutdoorArray = indoorOroutdoorArray;
        self.indoorOroutdoorIdArray = indoorOroutdoorIdArray;
    }
    return self;
}

@end
