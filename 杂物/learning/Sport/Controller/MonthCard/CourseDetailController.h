//
//  CourseDetailController.h
//  Sport
//
//  Created by haodong  on 15/6/9.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SportController.h"
#import "GoSportUrlAnalysis.h"
#import "SportHistoryController.h"
#import "MonthCardCourse.h"
#import "MonthCardService.h"
#import "RechargeController.h"
#import "MonthCardRechargeController.h"

@interface CourseDetailController : SportController<UIAlertViewDelegate>
@property (strong, nonatomic)MonthCardCourse *course;
-(id)initWithCourse:(MonthCardCourse *)course;
@end
