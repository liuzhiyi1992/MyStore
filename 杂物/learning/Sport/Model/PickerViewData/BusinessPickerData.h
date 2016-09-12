//
//  BusinessPickerData.h
//  Sport
//
//  Created by xiaoyang on 16/5/28.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BusinessPickerData : NSObject

//今天的开始小时
@property (readonly, strong, nonatomic) NSArray *todayHourArrayNoSuffix;       //例如:@[@"18",nil]
@property (readonly, strong, nonatomic) NSArray *todayHourArrayHaveSuffix;     //例如:@[@"18:00",nil]

//开始小时
@property (readonly, strong, nonatomic) NSArray *hourArrayNoSuffix;           //例如:@[@"9",nil]
@property (readonly, strong, nonatomic) NSArray *hourArrayHaveSuffix;         //例如:@[@"9:00",nil]

//时间段(时长)
@property (readonly, strong, nonatomic) NSArray *timeIntervalArrayNoSuffix;   //例如:@[@"3",nil]
@property (readonly, strong, nonatomic) NSArray *timeIntervalArrayHaveSuffix; //例如:@[@"3小时",nil]

//日期
@property (readonly, strong, nonatomic) NSArray *dateArray;                   //例如:@[[NSDate date],nil],
@property (readonly, strong, nonatomic) NSArray *monthDayArray;               //例如:@[@"10月11日",nil],
@property (readonly, strong, nonatomic) NSArray *weekArray;                   //例如:@[@"(周二)",nil],
@property (readonly, strong, nonatomic) NSArray *monthDayWeekArray;           //例如:@[@"10月11日(周二)",nil],
@property (readonly, strong, nonatomic) NSArray *dayWeekArray;                //例如:@[@"11日(周二)",nil],

//足球场加入人数
@property (readonly, strong, nonatomic) NSArray *soccerPersonHaveSuffixArray; //例如:@[@"5人场",nil]
@property (readonly, strong, nonatomic) NSArray *soccerPersonNoSuffixArray;   //例如:@[@"5",nil]

//室内外
@property (readonly, strong, nonatomic) NSArray *indoorOroutdoorArray;        //例如:@[@"室内",@"室外",nil]
@property (readonly, strong, nonatomic) NSArray *indoorOroutdoorIdArray;      //例如:@[@"3",@"4",nil]

//此数据的创建时间
@property (readonly, strong, nonatomic) NSDate *createTime;


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
            indoorOroutdoorIdArray:(NSArray *)indoorOroutdoorIdArray;

@end
