//
//  Forum.h
//  Sport
//
//  Created by 江彦聪 on 15/5/11.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Forum : NSObject
@property (copy, nonatomic) NSString *forumId;
@property (copy, nonatomic) NSString *forumName;
@property (copy, nonatomic) NSString *imageUrl;
@property (assign, nonatomic) NSUInteger currentPostCount;
@property (assign, nonatomic) NSUInteger totalPostCount;
@property (assign, nonatomic) BOOL isOftenGoTo;

@end
