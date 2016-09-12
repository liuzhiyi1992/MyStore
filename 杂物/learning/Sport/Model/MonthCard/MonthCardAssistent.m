
//
//  MonthCardAssistent.m
//  Sport
//
//  Created by 江彦聪 on 15/6/11.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "MonthCardAssistent.h"
#import "MonthCardCourse.h"
@implementation MonthCardAssistent


-(id)init
{
    self = [super init];
    if(self){
        self.course = [[MonthCardCourse alloc]init];
    }
    
    return self;
}
@end
