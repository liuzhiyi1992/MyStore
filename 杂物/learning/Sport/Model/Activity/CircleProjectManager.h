//
//  CircleProjectManager.h
//  Sport
//
//  Created by haodong  on 14-3-11.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface  CircleProject:NSObject
@property (copy, nonatomic) NSString *proId;
@property (copy, nonatomic) NSString *proName;
@end

@interface CircleProjectManager : NSObject
@property (strong, nonatomic) NSArray *circleProjectList;

+ (id)defaultManager;

@end
