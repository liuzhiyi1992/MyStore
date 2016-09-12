//
//  Comment.h
//  Coach
//
//  Created by quyundong on 15/7/22.
//  Copyright (c) 2015年 ningmi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PostPhoto.h"

@interface Comment : NSObject

@property (copy, nonatomic) NSString *userName;
@property (copy, nonatomic) NSString *userId;
@property (strong, nonatomic) NSDate *addTime;
@property (copy, nonatomic) NSString *orderId;
@property (copy, nonatomic) NSString *commentId;
@property (copy, nonatomic) NSString *content;
@property (copy, nonatomic) NSString *commentRank;
@property (strong,nonatomic) NSArray *photoList;

@end
