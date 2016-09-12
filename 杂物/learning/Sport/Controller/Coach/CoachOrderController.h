//
//  CoachOrderController.h
//  Sport
//
//  Created by 江彦聪 on 15/7/17.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportController.h"
#import "SportTimePickerView.h"
#import "SportPickerView.h"
#import "CoachService.h"
#import "CoachSelectPlaceController.h"

@class Coach;
@class CoachProjects;

@interface CoachOrderController : SportController<SportPickerViewDelegate,SportTimePickerViewDelegate,CoachServiceDelegate,UIAlertViewDelegate,CoachSelectPlaceControllerDelegate>

typedef NS_ENUM(NSInteger, TIME_STATE)
{
    TIME_STATE_MORNING = 0,
    TIME_STATE_AFTERNOON,
    TIME_STATE_NIGHT,
};

- (id)initWithCoach:(Coach *)coach project:(CoachProjects *)project;
@end
