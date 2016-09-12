//
//  MonthCardCourseManager.h
//  Sport
//
//  Created by haodong  on 13-6-26.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@class MonthCardCourse;
@class Goods;
@class Court;

@interface MonthCardCourseManager : NSObject

+ (MonthCardCourseManager *)defaultManager;

+ (NSArray *)courseListByDictionary:(NSDictionary *)dictionary;

+ (MonthCardCourse *)courseByOneMonthCardCourseJson:(NSDictionary *)dic;

@end
