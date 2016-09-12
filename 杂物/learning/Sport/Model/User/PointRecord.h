//
//  PointRecord.h
//  Sport
//
//  Created by haodong  on 14/11/22.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PointRecord : NSObject

@property (assign, nonatomic) int point;
@property (assign, nonatomic) int type;
@property (copy, nonatomic) NSString *desc;
@property (strong, nonatomic) NSDate *createDate;

@end
