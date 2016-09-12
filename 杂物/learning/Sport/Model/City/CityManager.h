//
//  CityManager.h
//  Sport
//
//  Created by haodong  on 13-8-8.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CityManagerDelegate <NSObject>
@optional
- (void)didQueryLocationCityName:(NSString *)cityName
                        latitude:(double)latitude
                       longitude:(double)longitude;
@end

#define REGION_ID_ALL     @"0"
#define REGION_NAME_ALL   DDTF(@"kAllRegion")
#define MONTHCARD_REGION_ID_ALL     @"1"
#define MONTHCARD_REGION_NAME_ALL   @"全城"

@class City;

@interface CityManager : NSObject
@property (strong, nonatomic) NSArray *cityList; //用于场馆的城市选择
@property (strong, nonatomic) NSArray *provinceList; //用于用户的城市选择

@property (strong, nonatomic) City *suggestCity; //建议城市

+ (CityManager *)defaultManager;

- (NSString *)regionName:(NSString *)regionId cityId:(NSString *)cityId;

+ (City *)readCurrentCity;
+ (void)saveCurrentCity:(City *)city;

+ (NSString *)readCurrentCityId;
+ (NSString *)readRealCurrentCityId;
+ (NSString *)readCurrentCityName;

- (void)queryLocationCityName:(id<CityManagerDelegate>)delegate
                     latitude:(double)latitude
                    longitude:(double)longitude;

@end
