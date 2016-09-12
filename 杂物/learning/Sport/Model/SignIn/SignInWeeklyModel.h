//
//  SignInWeeklyModel.h
//  Sport
//
//  Created by lzy on 16/6/15.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SignInWeeklyModel : NSObject
@property (copy, nonatomic) NSString *status;
@property (copy, nonatomic) NSString *integral;
@property (copy, nonatomic) NSString *coupon;
@property (copy, nonatomic) NSString *weekName;
@property (assign, nonatomic) int weekSignInTimes;
@end
