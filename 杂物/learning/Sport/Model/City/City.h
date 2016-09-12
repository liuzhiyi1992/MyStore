//
//  City.h
//  Sport
//
//  Created by haodong  on 13-8-5.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface City : NSObject

@property (copy, nonatomic) NSString *cityId;
@property (copy, nonatomic) NSString *cityName;
@property (strong, nonatomic) NSArray *regionList;
@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) double longitude;

@end
