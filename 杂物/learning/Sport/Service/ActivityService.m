//
//  ActivityService.m
//  Sport
//
//  Created by haodong  on 14-3-7.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "ActivityService.h"
#import "CircleProjectManager.h"
#import "Activity.h"
#import "User.h"
#import "GSNetwork.h"


@implementation ActivityService

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
          actCostTotal:(int)actCostTotal
{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_ADD_ACTIVITY forKey:PARA_ACTION];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        [inputDic setValue:proId forKey:PARA_PRO_ID];
        [inputDic setValue:[NSString stringWithFormat:@"%d", actName] forKey:PARA_ACT_NAME];
        [inputDic setValue:[NSString stringWithFormat:@"%d", actCost] forKey:PARA_ACT_COST];
        [inputDic setValue:startTime forKey:PARA_ACT_TIME];
        [inputDic setValue:endTime forKey:PARA_END_TIME];
        [inputDic setValue:address forKey:PARA_ACT_ADDRESS];
        [inputDic setValue:actDesc  forKey:PARA_ACT_DESC];
        [inputDic setValue:[NSString stringWithFormat:@"%d", peopleNumber] forKey:PARA_ACT_PEOPLE_NUMBER];
        
        [inputDic setValue:[NSString stringWithFormat:@"%d", integralType]  forKey:PARA_INTEGRAL_TYPE];
        if (integralType > 0) {
            [inputDic setValue:[NSString stringWithFormat:@"%d", giveIntegral]  forKey:PARA_GIVE_INTEGRAL];
        } else {
            [inputDic setValue:@"0" forKey:PARA_GIVE_INTEGRAL];
        }
        
        [inputDic setValue:gender forKey:PARA_GENDER];
        
        if (minAge > 0) {
            [inputDic setValue:[NSString stringWithFormat:@"%d", minAge] forKey:PARA_MIN_AGE];
        }
        if (maxAge > 0) {
            [inputDic setValue:[NSString stringWithFormat:@"%d", maxAge] forKey:PARA_MAX_AGE];
        }
        
        [inputDic setValue:[NSString stringWithFormat:@"%d", sportLevel] forKey:PARA_SPORT_LEVEL];
        
        if (latitude != 0 && longitude != 0) {
            [inputDic setValue:[NSString stringWithFormat:@"%f", latitude] forKey:PARA_LATITUDE];
            [inputDic setValue:[NSString stringWithFormat:@"%f", longitude] forKey:PARA_LONGITUDE];
        }
        [inputDic setValue:[NSString stringWithFormat:@"%d", actCostTotal] forKey:PARA_ACT_COST_TOTAL];

        
        [GSNetwork getWithBasicUrlString:GS_URL_INDEX parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
            NSDictionary *resultDictionary = response.jsonResult;
            
            NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
            NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([delegate respondsToSelector:@selector(didCreateActivity:msg:)]) {
                    [delegate didCreateActivity:status msg:msg];
                }
            });
        }];
}

+ (Activity *)parseFormDictionary:(NSDictionary *)dictionary
{
    Activity *activity = [[Activity alloc] init] ;
    activity.activityId = [dictionary validStringValueForKey:PARA_ACT_ID];
    activity.proName = [dictionary validStringValueForKey:PARA_PRO_NAME];
    activity.userId = [dictionary validStringValueForKey:PARA_USER_ID];
    activity.theme = [dictionary validIntValueForKey:PARA_ACT_NAME];
    activity.costType = [dictionary validIntValueForKey:PARA_ACT_COST];
    activity.totalCost = [dictionary validIntValueForKey:PARA_ACT_COST_TOTAL];
    activity.startTime = [NSDate dateWithTimeIntervalSince1970:[dictionary validIntValueForKey:PARA_ACT_TIME]];
    //activity.endTime = [NSDate dateWithTimeIntervalSince1970:[dictionary validIntValueForKey:PARA_END_TIME]];
    int promiseEndTimeInterval = [dictionary validIntValueForKey:PARA_END_TIME];
    if (promiseEndTimeInterval == 0) {
        activity.promiseEndTime = nil;
    } else {
        activity.promiseEndTime = [NSDate dateWithTimeIntervalSince1970:promiseEndTimeInterval];
    }
    activity.createTime = [NSDate dateWithTimeIntervalSince1970:[dictionary validIntValueForKey:PARA_ADD_TIME]];
    activity.address = [dictionary validStringValueForKey:PARA_ACT_ADDRESS];
    activity.latitude = [[dictionary validStringValueForKey:PARA_LATITUDE] doubleValue];
    activity.longitude = [[dictionary validStringValueForKey:PARA_LONGITUDE] doubleValue];
    activity.desc = [dictionary validStringValueForKey:PARA_ACT_DESC];
    activity.stauts = [dictionary validIntValueForKey:PARA_STATUS];
    activity.peopleNumber = [dictionary validIntValueForKey:PARA_ACT_PEOPLE_NUMBER];
    activity.integralType = [dictionary validIntValueForKey:PARA_INTEGRAL_TYPE];
    activity.integralCount = [dictionary validIntValueForKey:PARA_GIVE_INTEGRAL];
    activity.requireGender = [dictionary validStringValueForKey:PARA_GENDER];
    activity.requireMinAge = [dictionary validIntValueForKey:PARA_MIN_AGE];
    activity.requireMaxAge = [dictionary validIntValueForKey:PARA_MAX_AGE];
    activity.requireSportLevel = [dictionary validIntValueForKey:PARA_SPORT_LEVEL];
    
    activity.createUserAvatarUrl = [dictionary validStringValueForKey:PARA_AVATAR];
    activity.createUserNickName = [dictionary validStringValueForKey:PARA_NICK_NAME];
    activity.createUserGender = [dictionary validStringValueForKey:PARA_GENDER];
    activity.createUserAge = [dictionary validIntValueForKey:PARA_AGE];
    activity.createUserAppointmentRate = [dictionary validStringValueForKey:PARA_APPOINTMENT_RATE];
    activity.createUserActivityCount = [dictionary validIntValueForKey:PARA_APPOINTMENT_TOTAL];
    
    NSArray *promiseListSource = [dictionary validArrayValueForKey:PARA_PROMISE];
    NSMutableArray *promiseListTarget = [NSMutableArray array];
    for (id promiseSource in promiseListSource) {
        if ([promiseSource isKindOfClass:[NSDictionary class]] == NO) {
            continue;
        }
        ActivityPromise *promise = [[ActivityPromise alloc] init];
        promise.promiseId = [promiseSource validStringValueForKey:PARA_PROMISE_ID];
        promise.promiseUserId = [promiseSource validStringValueForKey:PARA_PROMISE_USER_ID];
        
        promise.promiseUserAvatar = [promiseSource validStringValueForKey:PARA_AVATAR];
        promise.promiseUserName = [promiseSource validStringValueForKey:PARA_NICK_NAME];
        promise.promiseUserGender = [promiseSource validStringValueForKey:PARA_GENDER];
        promise.promiseUserAge = [promiseSource validIntValueForKey:PARA_AGE];
        promise.promiseUserAppointmentRate = [promiseSource validStringValueForKey:PARA_APPOINTMENT_RATE];
        promise.promiseUserActivityCount = [promiseSource validIntValueForKey:PARA_APPOINTMENT_TOTAL];
        
        promise.status = [promiseSource validIntValueForKey:PARA_STATUS];
        
        [promiseListTarget addObject:promise];
    }
    activity.promiseList = promiseListTarget;
    
    return activity;
}

+ (void)queryActivityList:(id<ActivityServiceDelegate>)delegate
                     type:(ActivityListType)type
                   userId:(NSString *)userId
           activityStatus:(NSString *)activityStatus
                    proId:(NSString *)proId
                  actName:(NSString *)actName
                 latitude:(double)latitude
                longitude:(double)longitude
                     sort:(NSString *)sort
                     page:(int)page
                    count:(int)count
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_ACTIVITY_LIST forKey:PARA_ACTION];
    [inputDic setValue:[NSString stringWithFormat:@"%d", type] forKey:PARA_TYPE];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:activityStatus forKey:PARA_STATUS];
    [inputDic setValue:proId forKey:PARA_PRO_ID];
    [inputDic setValue:actName forKey:PARA_ACT_NAME];
    
    if (latitude == 0 && longitude == 0) {
        [inputDic setValue:[NSString stringWithFormat:@"%f", latitude] forKey:PARA_LATITUDE];
        [inputDic setValue:[NSString stringWithFormat:@"%f", longitude] forKey:PARA_LONGITUDE];
    }
    
    [inputDic setValue:sort forKey:PARA_SORT];
    [inputDic setValue:[NSString stringWithFormat:@"%d", page] forKey:PARA_PAGE];
    [inputDic setValue:[NSString stringWithFormat:@"%d", count] forKey:PARA_COUNT];
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    [GSNetwork getWithBasicUrlString:GS_URL_INDEX parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;

        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        NSArray *activityListSource = [data validArrayValueForKey:PARA_LIST];
        NSMutableArray *activityListTarget = [NSMutableArray array];
        for (id oneActivitySource in activityListSource) {
            if ([oneActivitySource isKindOfClass:[NSDictionary class]] == NO) {
                continue;
            }
            Activity *activity = [ActivityService parseFormDictionary:oneActivitySource];
            [activityListTarget addObject:activity];
        }
        

        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didQueryActivityList:status:type:page:)]) {
                [delegate didQueryActivityList:activityListTarget status:status type:type page:page];
            }
        });
    }];
}

+ (void)queryActivityDetail:(id<ActivityServiceDelegate>)delegate
                 activityId:(NSString *)activityId
{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_GET_ACTIVITY_INFO forKey:PARA_ACTION];
        [inputDic setValue:activityId forKey:PARA_ACT_ID];
        
        [GSNetwork getWithBasicUrlString:GS_URL_INDEX parameters:inputDic responseHandler:^(GSNetworkResponse *response){
            NSDictionary *resultDictionary = response.jsonResult;
            
            NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
            
            NSDictionary *acDic = [resultDictionary validDictionaryValueForKey:PARA_DATA];
            
            Activity *activity = nil;
            if ([status isEqualToString:STATUS_SUCCESS]) {
                activity = [ActivityService parseFormDictionary:acDic];
            }
            
            //创建者的信息
            id crDic = [acDic validDictionaryValueForKey:PARA_USER_INFO];
            if (crDic && [crDic isKindOfClass:[NSDictionary class]]){
                activity.createUserAppointmentRate = [(NSDictionary *)crDic validStringValueForKey:PARA_APPOINTMENT_RATE];
                activity.createUserActivityCount = [(NSDictionary *)crDic validIntValueForKey:PARA_APPOINTMENT_TOTAL];
                activity.createUserAvatarUrl = [(NSDictionary *)crDic validStringValueForKey:PARA_AVATAR];
                activity.createUserAge = [(NSDictionary *)crDic validIntValueForKey:PARA_AGE];
                activity.createUserGender = [(NSDictionary *)crDic validStringValueForKey:PARA_GENDER];
                activity.createUserNickName = [(NSDictionary *)crDic validStringValueForKey:PARA_NICK_NAME];
                activity.userId = [(NSDictionary *)crDic validStringValueForKey:PARA_USER_ID];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([delegate respondsToSelector:@selector(didQueryActivityDetail:status:)]) {
                    [delegate didQueryActivityDetail:activity status:status];
                }
            });
        }];
}

+ (void)addPromise:(id<ActivityServiceDelegate>)delegate
        activityId:(NSString *)activityId
            userId:(NSString *)userId
{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_ADD_PROMISE forKey:PARA_ACTION];
        [inputDic setValue:activityId forKey:PARA_ACT_ID];
        [inputDic setValue:userId forKey:PARA_PROMISE_USER_ID];
        [GSNetwork getWithBasicUrlString:GS_URL_INDEX parameters:inputDic responseHandler:^(GSNetworkResponse *response){
            NSDictionary *resultDictionary = response.jsonResult;
            NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
            NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([delegate respondsToSelector:@selector(didAddPromise:msg:)]) {
                    [delegate didAddPromise:status msg:msg];
                }
            });
        }];
}

+ (void)updatePromiseStatus:(id<ActivityServiceDelegate>)delegate
                  promiseId:(NSString *)promiseId
                     userId:(NSString *)userId
                     status:(ActivityPromiseStatus)status
{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_UPDATE_PROMISE_STATUS forKey:PARA_ACTION];
        [inputDic setValue:promiseId forKey:PARA_PROMISE_ID];
        [inputDic setValue:userId forKey:PARA_ACT_USER_ID];
        [inputDic setValue:[NSString stringWithFormat:@"%d", status] forKey:PARA_STATUS];
        [GSNetwork getWithBasicUrlString:GS_URL_INDEX parameters:inputDic responseHandler:^(GSNetworkResponse *response){
            NSDictionary *resultDictionary = response.jsonResult;
            NSString *resultStatus = [resultDictionary validStringValueForKey:PARA_STATUS];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([delegate respondsToSelector:@selector(didUpdatePromise:promiseId:promiseStatus:)]) {
                    [delegate didUpdatePromise:resultStatus promiseId:promiseId promiseStatus:status];
                }
            });
        }];
}

+ (void)queryUserList:(id<ActivityServiceDelegate>)delegate
             latitude:(double)latitude
            longitude:(double)longitude
               gender:(NSString *)gender
                proId:(NSString *)proId
                 sort:(NSString *)sort
                 page:(int)page
                count:(int)count
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_USER_LIST forKey:PARA_ACTION];
    [inputDic setValue:[NSString stringWithFormat:@"%f", latitude] forKey:PARA_LATITUDE];
    [inputDic setValue:[NSString stringWithFormat:@"%f", longitude] forKey:PARA_LONGITUDE];
    [inputDic setValue:gender forKey:PARA_GENDER];
    //        [inputDic setValue:proId forKey:PARA_PRO_ID];
    //        [inputDic setValue:sort forKey:PARA_SORT];
    [inputDic setValue:[NSString stringWithFormat:@"%d", page] forKey:PARA_PAGE];
    [inputDic setValue:[NSString stringWithFormat:@"%d", count] forKey:PARA_COUNT];
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    NSString *likeSportName = nil;
    for (CircleProject *pro in [[CircleProjectManager defaultManager] circleProjectList]) {
        if ([pro.proId isEqualToString:proId]) {
            likeSportName = pro.proName;
        }
    }
    [inputDic setValue:likeSportName forKey:PARA_INTERESTED_SPORT];
    
    
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary  = response.jsonResult;
        NSString *resultStatus = [resultDictionary validStringValueForKey:PARA_STATUS];
        
        NSMutableArray *userList = [NSMutableArray array];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        NSArray *sourceList = [data validArrayValueForKey:PARA_LIST];
        for (id one in sourceList) {
            if ([one isKindOfClass:[NSDictionary class]] == NO) {
                continue;
            }
            User *user = [[User alloc] init] ;
            user.userId = [one validStringValueForKey:PARA_USER_ID];
            user.nickname = [one validStringValueForKey:PARA_NICK_NAME];
            user.avatarUrl = [one validStringValueForKey:PARA_AVATAR];
            user.gender = [one validStringValueForKey:PARA_GENDER];
            user.age = [one validIntValueForKey:PARA_AGE];
            user.likeSport = [one validStringValueForKey:PARA_INTERESTED_SPORT];
            user.likeSportLevel = [one validIntValueForKey:PARA_INTERESTED_SPORT_LEVEL];
            user.latitude = [[one validStringValueForKey:PARA_LATITUDE] doubleValue];
            user.longitude = [[one validStringValueForKey:PARA_LONGITUDE] doubleValue];
            user.sportPlan = [one validStringValueForKey:PARA_SPORT_PLAN];
            [userList addObject:user];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didQueryUserList:status:page:)]) {
                [delegate didQueryUserList:userList status:resultStatus page:page];
            }
        });
    }];
}

+ (void)updateActivityStatus:(id<ActivityServiceDelegate>)delegate
                  activityId:(NSString *)activityId
                      userId:(NSString *)userId
                      status:(int)status
{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_UPDATE_ACTIVITY_STATUS forKey:PARA_ACTION];
        [inputDic setValue:activityId forKey:PARA_ACT_ID];
        [inputDic setValue:userId forKey:PARA_V_USER_ID];
        [inputDic setValue:[NSString stringWithFormat:@"%d", status] forKey:PARA_STATUS];
        
        [GSNetwork getWithBasicUrlString:GS_URL_INDEX parameters:inputDic responseHandler:^(GSNetworkResponse *response){
            NSDictionary *resultDictionary = response.jsonResult;
            NSString *resultStatus = [resultDictionary validStringValueForKey:PARA_STATUS];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([delegate respondsToSelector:@selector(didUpdateActivityStatus:activityId:activityStatus:)]) {
                    [delegate didUpdateActivityStatus:resultStatus activityId:activityId activityStatus:status];
                }
            });
        }];
}

//应约者取消应约
+ (void)cancelPromise:(id<ActivityServiceDelegate>)delegate
        promiseUserId:(NSString *)promiseUserId
            promiseId:(NSString *)promiseId
{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_CANCEL_PROMISE forKey:PARA_ACTION];
        [inputDic setValue:promiseUserId forKey:PARA_PROMISE_USER_ID];
        [inputDic setValue:promiseId forKey:PARA_PROMISE_ID];
        
        [GSNetwork getWithBasicUrlString:GS_URL_INDEX parameters:inputDic responseHandler:^(GSNetworkResponse *response){
            NSDictionary *resultDictionary = response.jsonResult;
            NSString *resultStatus = [resultDictionary validStringValueForKey:PARA_STATUS];
            NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([delegate respondsToSelector:@selector(didCancelPromise:msg:)]) {
                    [delegate didCancelPromise:resultStatus msg:msg];
                }
            });
        }];
}

@end

