//
//  Review.h
//  Sport
//
//  Created by haodong  on 14/11/4.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Review : NSObject

@property (copy, nonatomic) NSString *reviewId;
@property (assign, nonatomic) float rating;         //评级
@property (copy, nonatomic) NSString *content;
@property (strong, nonatomic) NSDate *createDate;
@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *avatar;
@property (copy, nonatomic) NSString *nickName;
@property (copy, nonatomic) NSString *businessId;
@property (strong, nonatomic) NSArray *photoList;
@property (assign, nonatomic) BOOL useful;
@property (assign, nonatomic) int usefulCount;
@property (copy, nonatomic) NSString *commentReply;

@end

