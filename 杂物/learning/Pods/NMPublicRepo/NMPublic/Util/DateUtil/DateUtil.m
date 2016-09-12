//
//  DateUtil.m
//  Sport
//
//  Created by haodong  on 14/11/27.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "DateUtil.h"
#import "NSDate+Utils.h"

@implementation DateUtil

+ (NSString *)ChineseWeek1:(NSDate *)date
{
    if (date == nil){
        return @"";
    }
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSChineseCalendar] ;
    NSInteger unitFlags = NSYearCalendarUnit |
    NSMonthCalendarUnit |
    NSDayCalendarUnit |
    NSWeekdayCalendarUnit |
    NSHourCalendarUnit |
    NSMinuteCalendarUnit |
    NSSecondCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    NSInteger week = [comps weekday];
    NSString *weekString = nil;
    switch (week)
    {
        case 1:
            weekString = @"星期日";
            break;
        case 2:
            weekString = @"星期一";
            break;
        case 3:
            weekString = @"星期二";
            break;
        case 4:
            weekString = @"星期三";
            break;
        case 5:
            weekString = @"星期四";
            break;
        case 6:
            weekString = @"星期五";
            break;
        case 7:
            weekString = @"星期六";
            break;
    }
    return weekString;
}

+ (NSString *)ChineseWeek2:(NSDate *)date
{
    if (date == nil){
        return @"";
    }
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSChineseCalendar] ;
    NSInteger unitFlags = NSYearCalendarUnit |
    NSMonthCalendarUnit |
    NSDayCalendarUnit |
    NSWeekdayCalendarUnit |
    NSHourCalendarUnit |
    NSMinuteCalendarUnit |
    NSSecondCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    NSInteger week = [comps weekday];
    NSString *weekString = nil;
    switch (week)
    {
        case 1:
            weekString = @"周日";
            break;
        case 2:
            weekString = @"周一";
            break;
        case 3:
            weekString = @"周二";
            break;
        case 4:
            weekString = @"周三";
            break;
        case 5:
            weekString = @"周四";
            break;
        case 6:
            weekString = @"周五";
            break;
        case 7:
            weekString = @"周六";
            break;
    }
    return weekString;
}

+ (NSDate *)dateFromString:(NSString *)date
                DateFormat:(NSString *)formatString
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:formatString];
    
    NSDate *date_ = [dateFormat dateFromString:date];
    
    return date_;
}

+ (NSString *)stringFromTimeIntervalSince1970:(NSUInteger)interval
                                   DateFormat:(NSString *)formatString
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:formatString];
    
    NSString *dateString = [dateFormat stringFromDate:[NSDate dateWithTimeIntervalSince1970:interval]];
    
    return dateString;
}


+ (NSString *)stringFromDate:(NSDate *)date
                  DateFormat:(NSString *)formatString
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:formatString];
    
    NSString *dateString = [dateFormat stringFromDate:date];
    
    return dateString;
}

+ (NSString *)lastUpdateTimeString:(NSDate *)date
                         formatter:(NSDateFormatter *)formatter
{
    if (date == nil) {
        return nil;
    }
    
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
    }
    
    NSString *displayTime = nil;
    
    double backTimeInterval = date.timeIntervalSinceNow * (-1);
    
    if ([date isToday]) {
        if (backTimeInterval < 60) {
            displayTime = @"刚刚";
        }else if (backTimeInterval < 60*60) {
            displayTime = [NSString stringWithFormat:@"%.f分钟前",backTimeInterval/60] ;
        } else if (backTimeInterval < 60*60*24) {
            displayTime = [NSString stringWithFormat:@"%.f小时前",backTimeInterval/3600] ;
        }
    } else if ([date isYesterday]) {
        [formatter setDateFormat:@"昨天 HH:mm"];
        displayTime = [formatter stringFromDate:date];
    }else if ([date isThisYear]) {
        [formatter setDateFormat:@"MM月dd日 HH:mm"];
        displayTime = [formatter stringFromDate:date];
    }
    
    if (displayTime == nil) {
        [formatter setDateFormat:@"yyyy年MM月dd日"];
        displayTime= [formatter stringFromDate:date];
    }
    
    return displayTime;
}

+ (NSString *)messageDetailTimeString:(NSDate *)date
                            formatter:(NSDateFormatter *)formatter
{
    if (date == nil) {
        return nil;
    }
    
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
    }
    
    NSString *displayTime = nil;
    
    if ([date isToday]) {
        [formatter setDateFormat:@"HH:mm"];
        displayTime = [formatter stringFromDate:date];
    } else if ([date isYesterday]) {
        [formatter setDateFormat:@"昨天 HH:mm"];
        displayTime = [formatter stringFromDate:date];
    }else if ([date isThisYear]) {
        [formatter setDateFormat:@"MM月dd日 HH:mm"];
        displayTime = [formatter stringFromDate:date];
    }
    
     if (displayTime == nil) {
        [formatter setDateFormat:@"yyyy年MM月dd日"];
        displayTime= [formatter stringFromDate:date];
    }
    
    return displayTime;
}

+ (NSString *)messageBriefTimeString:(NSDate *)date
                           formatter:(NSDateFormatter *)formatter
{
    if (date == nil) {
        return nil;
    }
    
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
    }
    
    NSString *displayTime = nil;
    
    if ([date isToday]) {
        [formatter setDateFormat:@"HH:mm"];
        displayTime = [formatter stringFromDate:date];
    } else if ([date isYesterday]) {
        [formatter setDateFormat:@"昨天"];
        displayTime = [formatter stringFromDate:date];
    }else if ([date isThisYear]) {
        [formatter setDateFormat:@"MM月dd日"];
        displayTime = [formatter stringFromDate:date];
    }
    
    if (displayTime == nil) {
        [formatter setDateFormat:@"yyyy年MM月dd日"];
        displayTime= [formatter stringFromDate:date];
    }
    
    return displayTime;
}

+ (NSArray *)parseOneWeekDateList
{
    NSMutableArray *dateList = [NSMutableArray array];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = kCFCalendarUnitDay|kCFCalendarUnitMonth|kCFCalendarUnitYear;
    
    //获取当前的年月日
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    
    for (int i = 0; i < 7; i++) {
        //[dateList addObject:[DateUtil stringFromDate:[calendar dateFromComponents:nowCmps] DateFormat:@"M月d日"]];
        [dateList addObject:[calendar dateFromComponents:nowCmps]];
        
        nowCmps.day++;
    }
    
    return dateList;
}

+(NSArray *)generateOneWeekData
{
    NSArray *oneWeekDateList = [DateUtil parseOneWeekDateList];
    NSMutableArray *mutableArray = [NSMutableArray array];
    
    for (NSDate *date in oneWeekDateList) {
        NSString *dateString = [DateUtil stringFromDate:date DateFormat:[NSString stringWithFormat:@"MM月dd日（%@）",[DateUtil ChineseWeek2:date]]];
        
        [mutableArray addObject:dateString];
    }
    
    return mutableArray;
}

+(NSString *)dateStringWithWeekday:(NSDate *)date
{
    if (date == nil) {
        return nil;
    }
    
    return [DateUtil stringFromDate:date DateFormat:[NSString stringWithFormat:@"MM月dd日（%@)",[DateUtil ChineseWeek2:date]]];
}

+(NSString *)dateStringWithWeekdayDetail:(NSDate *)date
{
    if (date == nil) {
        return nil;
    }
    
    return [DateUtil stringFromDate:date DateFormat:[NSString stringWithFormat:@"MM月dd日（%@）HH:mm",[DateUtil ChineseWeek2:date]]];
}

+ (NSString *)dayStringWithWeekday:(NSDate *)date{
    if (date == nil) {
        return nil;
    }
    
    NSString *weekString = ([date isToday] ? @"今天" : [DateUtil ChineseWeek2:date]);
    return [DateUtil stringFromDate:date DateFormat:[NSString stringWithFormat:@"dd日(%@)",weekString]];
}

//虽然是日期加星期几，不同在于今天时显示“今天”而不是周几
+ (NSString *)dateStringWithTodayAndOtherWeekday:(NSDate *)date{
    if (date == nil) {
        return nil;
    }
    
    NSString *weekString = ([date isToday] ? @"今天" : [DateUtil ChineseWeek2:date]);
    return [DateUtil stringFromDate:date DateFormat:[NSString stringWithFormat:@"yyyy年MM月dd日(%@)",weekString]];
}

+ (NSString *)todayAndOtherWeekString:(NSDate *)date{
    return [NSString stringWithFormat:@"(%@)",[self todayAndOtherWeekStringNoBracket:date]];
}

+ (NSString *)todayAndOtherWeekStringNoBracket:(NSDate *)date{
    if (date == nil) {
        return nil;
    }
    NSString *WeekString = ([date isToday] ? @"今天" : [DateUtil ChineseWeek2:date]);
    return [NSString stringWithFormat:@"%@",WeekString];
}

#define SEC_PER_DAY (3600*24)
+(int)expiredaysFromNow:(NSDate *)endDate
{
    int diff = [endDate timeIntervalSinceDate:[NSDate date]];
    
    int day = diff/SEC_PER_DAY;
    
    //如果为2.5日，显示为3日
    if (day > 0) {
        day = (diff%SEC_PER_DAY == 0)?day:(day+1);
    }
    
    return day;
    
}


+ (BOOL)isThisYear:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitYear;
    
    //获取当前的年月日
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    
    //获得self的年月日
    NSDateComponents *selfCmps = [calendar components:unit fromDate:date];
    
    return nowCmps.year == selfCmps.year;
    
}

+ (BOOL)isToday:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = kCFCalendarUnitDay;
    
    //获取当前的年月日
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    
    //获得self的年月日
    NSDateComponents *selfCmps = [calendar components:unit fromDate:date];
    
    return nowCmps.day == selfCmps.day;
    
}

+ (BOOL)isYesterday:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = kCFCalendarUnitDay;
    
    //获取当前的年月日
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    
    //获得self的年月日
    NSDateComponents *selfCmps = [calendar components:unit fromDate:date];
    
    return nowCmps.day == selfCmps.day + 1;
    
}



@end
