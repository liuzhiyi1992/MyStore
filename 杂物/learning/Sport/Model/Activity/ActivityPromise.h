//
//  ActivityPromise.h
//  Sport
//
//  Created by haodong  on 14-4-11.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

//状态,0未确认1已确认2已拒绝
typedef enum{
    ActivityPromiseStatusNotDecide = 0,
    ActivityPromiseStatusAgreed = 1,
    //ActivityPromiseStatusRejected = 2, //被发布者取消
    ActivityPromiseStatusCancel = 2,                //应约者在被确认之前取消
    ActivityPromiseStatusCancelAfterAgreed = 3,     //应约者在被确认之后取消
} ActivityPromiseStatus;

@interface ActivityPromise : NSObject

@property (copy, nonatomic) NSString *promiseId;
@property (copy, nonatomic) NSString *promiseUserId;
@property (copy, nonatomic) NSString *promiseUserAvatar;
@property (copy, nonatomic) NSString *promiseUserName;
@property (copy, nonatomic) NSString *promiseUserGender;
@property (assign, nonatomic) int       promiseUserAge;
@property (copy, nonatomic) NSString *promiseUserAppointmentRate;
@property (assign, nonatomic) int       promiseUserActivityCount;

@property (assign, nonatomic) int lemonType; //0无,1奖励,2索取 
@property (assign, nonatomic) int lemonCount;

@property (assign, nonatomic) ActivityPromiseStatus status;

@end
