//
//  Activity.h
//  Sport
//
//  Created by haodong  on 14-2-24.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActivityPromise.h"

typedef enum {          //主题
    ActivityTheme0 = 0,
    ActivityTheme1 = 1,
    ActivityTheme2 = 2,
    ActivityTheme3 = 3,
} ActivityTheme;

typedef enum {
    CostTypeAA = 0,         //AA
    CostTypeInitiator = 1,  //发起人付费
    CostTypeInvitees = 2,   //受邀者付费
} CostType;

typedef enum {          //水平
    SportLevelUnknow = 0,
    SportLevel1= 1,
    SportLevel2 = 2,
    SportLevel3 = 3,
    SportLevel4 = 4,
} SportLevel;

typedef enum {
    ActivityStatusDefault = 0,                      //接受报名
    ActivityStatusCancel = 1,                       //未接受任何用户前取消
    ActivityStatusCancelAfterAgreeUser = 2,         //在接受用户后取消
    ActivityStatusExpired = 3,                      //活动过期
} ActivityStatus;

@interface Activity : NSObject

@property (nonatomic, retain) NSString *activityId;
@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSString *proId;
@property (nonatomic, retain) NSString *proName;
@property (nonatomic, assign) ActivityTheme theme;     //主题
@property (nonatomic, assign) CostType costType; //费用方式
@property (assign, nonatomic) int totalCost;
@property (nonatomic, retain) NSDate *startTime;
@property (nonatomic, retain) NSDate *endTime;
@property (nonatomic, retain) NSString *address;
@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) double longitude;
@property (nonatomic, retain) NSString *desc;
@property (nonatomic, assign) NSUInteger peopleNumber;
@property (assign, nonatomic) int stauts;
@property (nonatomic, retain) NSDate *createTime;
@property (nonatomic, retain) NSDate *promiseEndTime;
@property (assign, nonatomic) int integralType;  //奖励(柠檬)的方式0：无，1：赠送，2：索取
@property (assign, nonatomic) int integralCount; //奖励(柠檬)的数量

//应约者要求
@property (nonatomic, retain) NSString  *requireGender;
@property (nonatomic, assign) NSUInteger requireMinAge;
@property (nonatomic, assign) NSUInteger requireMaxAge;
@property (nonatomic, assign) SportLevel requireSportLevel;

//发起者的信息
@property (nonatomic, retain) NSString *createUserAvatarUrl;
@property (nonatomic, retain) NSString *createUserNickName;
@property (nonatomic, retain) NSString *createUserGender;
@property (nonatomic, retain) NSDate   *createUserBirthday; //可不用
@property (nonatomic, assign) int       createUserAge;
@property (nonatomic, retain) NSString *createUserAppointmentRate;
@property (nonatomic, assign) int       createUserActivityCount;

//应约列表
@property (nonatomic, retain) NSArray *promiseList;

+ (NSString *)themeName:(NSInteger)theme;
+ (NSString *)costName:(CostType)costType;
+ (NSString *)sportLevelName:(NSInteger)sportLevel;

- (NSString *)statusString;

- (int)agreePromiseCount;

@end
