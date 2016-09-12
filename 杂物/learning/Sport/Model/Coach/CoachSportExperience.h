//
//  CoachSportExperience.h
//  Sport
//
//  Created by 江彦聪 on 15/10/12.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoachSportExperience : NSObject

@property (copy, nonatomic) NSString *experienceId;
@property (copy, nonatomic) NSString *coachId;
@property (copy, nonatomic) NSString *experienceContent;
@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) NSDate *endTime;

@end
