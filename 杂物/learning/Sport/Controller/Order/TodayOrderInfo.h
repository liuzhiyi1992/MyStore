//
//  todayOrder.h
//  Sport
//
//  Created by 赵梦东 on 15/9/8.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TodayOrderInfo : NSObject
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *icon;
@property (copy, nonatomic) NSString *verificationCode;
@property (copy, nonatomic) NSString *startTime;
@property (copy, nonatomic) NSString *orderId;
@property (assign, nonatomic) int type;
@property (assign, nonatomic) int status;
@property (assign, nonatomic) BOOL isCourtJoinParent;

@end
