//
//  MonthCardCourseManager.m
//  Sport
//
//  Created by haodong  on 13-6-26.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "MonthCardCourseManager.h"
#import "MonthCardCourse.h"
#import "SportNetworkContent.h"
#import "NSDictionary+JsonValidValue.h"
#import "DateUtil.h"

static MonthCardCourseManager *_globalCourseManager = nil;

@implementation MonthCardCourseManager

+ (MonthCardCourseManager *)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_globalCourseManager == nil) {
            _globalCourseManager = [[MonthCardCourseManager alloc] init];
        }
    });
    return _globalCourseManager;
}

+ (NSArray *)courseListByDictionary:(NSDictionary *)dictionary
{
    id dicList = [dictionary objectForKey:PARA_DATA];
    if ([dicList isKindOfClass:[NSArray class]] == NO) {
        return nil;
    }
    NSMutableArray *courses = [NSMutableArray array];
    for (id dic in (NSArray *)dicList) {
        if ([dic isKindOfClass:[NSDictionary class]]) {
            MonthCardCourse *course = [self courseByOneMonthCardCourseJson:dic];
            [courses addObject:course];
        }
    }
    return courses;
}


+ (MonthCardCourse *)courseByOneMonthCardCourseJson:(NSDictionary *)dic
{
    if (dic == nil) {
        return nil;
    }
    
    MonthCardCourse *course = [[MonthCardCourse alloc] init];
    course.courseId = [dic validStringValueForKey:PARA_COURSE_ID];
    
    course.courseName = [dic validStringValueForKey:PARA_COURSE_NAME];
    course.venuesName = [dic validStringValueForKey:PARA_VENUES_NAME];
    course.imageUrl = [dic validStringValueForKey:PARA_IMAGE_URL];
    
    course.startTime = [dic validDateValueForKey:PARA_START_TIME];
    course.endTime = [dic validDateValueForKey:PARA_END_TIME];
    
    course.isRecommend = [dic validBoolValueForKey:PARA_IS_RECOMMEND];
    course.courseUrl = [dic validStringValueForKey:PARA_COURSE_URL];
    
    return course;
}

@end
