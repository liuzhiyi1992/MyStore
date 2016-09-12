//
//  DateUtil.h
//  Sport
//
//  Created by haodong  on 14/11/27.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateUtil : NSObject

#define ONE_HOUR_INTERVAL 60*60

+ (NSString *)ChineseWeek1:(NSDate *)date;

+ (NSString *)ChineseWeek2:(NSDate *)date;

+ (NSDate *)dateFromString:(NSString *)date
                DateFormat:(NSString *)formatString;

+ (NSString *)stringFromDate:(NSDate *)date
                  DateFormat:(NSString *)formatString;

+ (NSString *)lastUpdateTimeString:(NSDate *)date
                         formatter:(NSDateFormatter *)formatter;

+ (NSString *)stringFromTimeIntervalSince1970:(NSUInteger)interval
                                   DateFormat:(NSString *)formatString;
+ (NSArray *)parseOneWeekDateList;

+(int)expiredaysFromNow:(NSDate *)endDate;

+(NSArray *)generateOneWeekData;

+(NSString *)dateStringWithWeekday:(NSDate *)date;

+(NSString *)dateStringWithWeekdayDetail:(NSDate *)date;

+(NSString *)dayStringWithWeekday:(NSDate *)date;

+ (NSString *)messageDetailTimeString:(NSDate *)date
                            formatter:(NSDateFormatter *)formatter;

+ (NSString *)messageBriefTimeString:(NSDate *)date
                           formatter:(NSDateFormatter *)formatter;
+ (NSString *)dateStringWithTodayAndOtherWeekday:(NSDate *)date;
+ (NSString *)todayAndOtherWeekString:(NSDate *)date;
+ (NSString *)todayAndOtherWeekStringNoBracket:(NSDate *)date;

@end
