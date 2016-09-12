//
//  ActivityService.h
//  Sport
//
//  Created by haodong  on 14-3-7.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SportNetworkContent.h"
#import "ActivityPromise.h"

typedef enum{
    ActivityListTypeDefault = 0,
    ActivityListTypeMyCreate = 1,
    ActivityListTypeMyPromise = 2,
    ActivityListTypeHistory = 3,
} ActivityListType;

@class Activity;
@protocol ActivityServiceDelegate <NSObject>
@optional
- (void)didCreateActivity:(NSString *)status msg:(NSString *)msg;
- (void)didQueryActivityList:(NSArray *)list status:(NSString *)status type:(ActivityListType)type page:(int)page;
- (void)didQueryActivityDetail:(Activity *)activity status:(NSString *)status;
- (void)didAddPromise:(NSString *)status msg:(NSString *)msg;
- (void)didUpdatePromise:(NSString *)status promiseId:(NSString *)promiseId promiseStatus:(ActivityPromiseStatus)promiseStatus;
- (void)didQueryUserList:(NSArray *)userList status:(NSString *)status page:(int)page;
- (void)didUpdateActivityStatus:(NSString *)status activityId:(NSString *)activityId activityStatus:(int)activityStatus;
- (void)didCancelPromise:(NSString *)status msg:(NSString *)msg;
@end

@interface ActivityService : NSObject

//创建活动
+ (void)createActivity:(id<ActivityServiceDelegate>)delegate
                 proId:(NSString *)proId
               actName:(int)actName
               actCost:(int)actCost
                userId:(NSString *)userId
          peopleNumber:(int)peopleNumber
               address:(NSString *)address
             startTime:(NSString *)startTime   //"2013-03-07 14:30"
               endTime:(NSString *)endTime     //"2013-03-07 16:30"
          giveIntegral:(int)giveIntegral        //积分多少
          integralType:(int)integralType       //积分类型1:赠送，2:索取
               actDesc:(NSString *)actDesc
                minAge:(int)minAge
                maxAge:(int)maxAge
            sportLevel:(int)sportLevel
                gender:(NSString *)gender
              latitude:(double)latitude
             longitude:(double)longitude
          actCostTotal:(int)actCostTotal;

//活动详情
+ (void)queryActivityDetail:(id<ActivityServiceDelegate>)delegate
                 activityId:(NSString *)activityId;

//活动列表，type:0首页，1我的发布(要传userId)，2我的应约(要传userId)
+ (void)queryActivityList:(id<ActivityServiceDelegate>)delegate
                     type:(ActivityListType)type
                   userId:(NSString *)userId
           activityStatus:(NSString *)activityStatus
                    proId:(NSString *)proId
                  actName:(NSString *)actName
                 latitude:(double)latitde
                longitude:(double)longitude
                     sort:(NSString *)sort
                     page:(int)page
                    count:(int)count;

//应约
+ (void)addPromise:(id<ActivityServiceDelegate>)delegate
        activityId:(NSString *)activityId
            userId:(NSString *)userId;

//同意或拒绝应约, status=1是同意, status=2是拒绝
+ (void)updatePromiseStatus:(id<ActivityServiceDelegate>)delegate
                  promiseId:(NSString *)promiseId
                     userId:(NSString *)userId   //发布者的id
                     status:(ActivityPromiseStatus)status;

+ (void)queryUserList:(id<ActivityServiceDelegate>)delegate
             latitude:(double)latitde
            longitude:(double)longitude
               gender:(NSString *)gender
                proId:(NSString *)proId
                 sort:(NSString *)sort
                 page:(int)page
                count:(int)count;

+ (void)updateActivityStatus:(id<ActivityServiceDelegate>)delegate
                  activityId:(NSString *)activityId
                      userId:(NSString *)userId
                      status:(int)status;

//应约者取消应约
+ (void)cancelPromise:(id<ActivityServiceDelegate>)delegate
        promiseUserId:(NSString *)promiseUserId
            promiseId:(NSString *)promiseId;

@end
