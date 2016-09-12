//
//  CoachFeedbackController.h
//  Sport
//
//  Created by 江彦聪 on 15/7/27.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportController.h"

@interface CoachFeedbackController : SportController
-(id)initWithOrderId:(NSString *)orderId
             coachId:(NSString *)coachId
           coachName:(NSString *)coachName;
@end
