//
//  MonthCardCourse.h
//  Sport
//
//  Created by 江彦聪 on 15/6/6.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MonthCardCourse : NSObject
@property (strong, nonatomic) NSString* courseId;
@property (strong, nonatomic) NSString *courseName;
@property (strong, nonatomic) NSString *venuesName;
@property (strong, nonatomic) NSString *imageUrl;
@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) NSDate *endTime;
@property (strong, nonatomic) NSString *courseUrl;
@property (assign, nonatomic) BOOL isRecommend;
@end
