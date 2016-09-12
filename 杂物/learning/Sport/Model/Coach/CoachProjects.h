//
//  CoachProjects.h
//  Sport
//
//  Created by 江彦聪 on 15/10/12.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoachProjects : NSObject
@property (copy, nonatomic) NSString *goodsId;
@property (copy, nonatomic) NSString *coachId;
@property (copy, nonatomic) NSString *categoryId;
@property (copy, nonatomic) NSString *projectName;
@property (copy, nonatomic) NSString *roleId;
@property (assign, nonatomic) int minutes;
@property (assign, nonatomic) int price;
@property (strong, nonatomic) NSDate *addTime;
@end
