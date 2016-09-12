//
//  FavourableActivity.h
//  Sport
//
//  Created by haodong  on 14/11/7.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    FavourableActivityStatusNotAvailable = 0,
    FavourableActivityStatusAvailable = 1
};

enum {
    FavourableActivityTypeDefault = 0,
    FavourableActivityTypeInviteCode = 1
};

@interface FavourableActivity : NSObject

@property (copy, nonatomic) NSString *activityId;
@property (copy, nonatomic) NSString *activityName;
//@property (copy, nonatomic) NSString *activityDesc;
@property (assign, nonatomic) int activityStatus;
@property (assign, nonatomic) float activityPrice;
@property (assign, nonatomic) int activityType;

@property (copy, nonatomic) NSString *activityInviteCode;

@end
