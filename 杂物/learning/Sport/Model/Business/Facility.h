//
//  Facility.h
//  Sport
//
//  Created by qiuhaodong on 15/6/5.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

//设施
@interface Facility : NSObject

@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray *valueList;
@property (assign, nonatomic) NSUInteger imageCount;
@property (copy, nonatomic) NSString *thumbImageUrl;
@property (copy, nonatomic) NSString *iconImageUrl;
@property (copy, nonatomic) NSString *detailUrl;

@end
