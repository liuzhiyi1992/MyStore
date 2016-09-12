//
//  ActivityManager.h
//  Sport
//
//  Created by haodong  on 14-4-29.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActivityManager : NSObject

+ (id)defaultManager;

- (NSDictionary *)themeDictionary;

- (NSDictionary *)activitySortDictionary;

- (NSDictionary *)peopleSortDictionary;

@end
