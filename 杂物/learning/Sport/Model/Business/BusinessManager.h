//
//  BusinessManager.h
//  Sport
//
//  Created by haodong  on 13-6-26.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@class Business;
@class Goods;
@class Court;

@interface BusinessManager : NSObject

+ (BusinessManager *)defaultManager;

@property (strong, nonatomic) NSArray *mayLikeList;

+ (NSArray *)businessListByDictionary:(NSDictionary *)dictionary;

+ (NSArray *)favoriteBusinessListByDictionary:(NSDictionary *)dictionary;

+ (NSArray *)mapBusinessListByDictionary:(NSDictionary *)dictionary;

+ (Business *)businessByOneBusinessJson:(NSDictionary *)dic;

+ (Court *)courtByDictionary:(NSDictionary *)oneCourseSource;

+ (Goods *)goodsByDictionary:(NSDictionary *)dictionary;

+ (NSArray *)venuesListByDictionary:(NSDictionary *)dictionary;

@end
