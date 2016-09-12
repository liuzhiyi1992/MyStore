//
//  HomeService.h
//  Sport
//
//  Created by haodong  on 14-5-4.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SportNetworkContent.h"

@class FastOrderEntrance;

@protocol HomeServiceDelegate <NSObject>
@optional
- (void)didQueryHomePage:(NSString *)status
                     msg:(NSString *)msg
                  adList:(NSArray *)adList
            businessList:(NSArray *)businessList
            categoryList:(NSArray *)categoryList
              courseList:(NSArray *)courseList
           hasMoreCourse:(NSString *)hasMoreCourse;

- (void)didQueryUserIndex:(NSString *)status
                 userList:(NSArray *)userList;

- (void)didQueryHomeVenueList:(NSString *)status
                          msg:(NSString *)msg
                         page:(int)page
                 businessList:(NSArray *)businessList;

- (void)didQueryQuickBookInfo:(NSString *)status
                     entrance:(FastOrderEntrance *)entrance;
@end

@interface HomeService : NSObject

+ (void)queryHomePage:(id<HomeServiceDelegate>)delegate
               userId:(NSString *)userId
               cityId:(NSString *)cityId
            longitude:(NSString *)longitude
             latitude:(NSString *)latitude;

+ (void)queryUserIndex:(id<HomeServiceDelegate>)delegate
                  page:(int)page
                 count:(int)count;

+ (void)queryHomeVenueList:(id<HomeServiceDelegate>)delegate
                    userID:(NSString *)userID
                    cityID:(NSString *)cityID
                       ver:(NSString *)ver
                 longitude:(NSString *)longitude
                  latitude:(NSString *)latitude
                      page:(int)page
                     count:(NSString *)count;

+ (void)queryQuickBookInfo:(id<HomeServiceDelegate>)delegate
                    userId:(NSString *)userId;

@end
