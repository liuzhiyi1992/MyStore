//
//  MonthCardAssistent.h
//  Sport
//
//  Created by 江彦聪 on 15/6/11.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MonthCardCourse.h"

@interface MonthCardAssistent : NSObject
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *venuesName;
@property (strong, nonatomic) NSString *venuesId;
@property (strong, nonatomic) NSString *categoryId;
@property (strong, nonatomic) NSString *categoryImageURL;
@property (strong, nonatomic) MonthCardCourse *course;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *phone;
@property (assign, nonatomic) double latitude;          //纬度
@property (assign, nonatomic) double longitude;         //经度
@property (strong, nonatomic) NSString *notice;
@property (strong, nonatomic) NSString *courseURL;
-(id)init;

@end
