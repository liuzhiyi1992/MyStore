//
//  CoachBookingInfo.h
//  Sport
//
//  Created by 江彦聪 on 15/7/20.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoachBookingInfo : NSObject
@property (strong, nonatomic) NSDate *weekDate;
@property (assign, nonatomic) BOOL morningState;
@property (assign, nonatomic) BOOL afternoonState;
@property (assign, nonatomic) BOOL nightState;

@end
