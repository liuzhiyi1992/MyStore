//
//  Post.h
//  Sport
//
//  Created by 江彦聪 on 15/5/9.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Forum.h"

@interface Post : NSObject
@property (copy, nonatomic) NSString *postId;
@property (copy, nonatomic) NSString *avatarImageURL;
@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *userName;
@property (strong, nonatomic) NSDate *lastUpdateTime;
@property (copy, nonatomic) NSString *content;
@property (strong, nonatomic) NSArray *photoList;
@property (strong, nonatomic) Forum *forum;
@property (assign, nonatomic) NSUInteger commentAmount;
@property (strong, nonatomic) NSDate *createTime;

//场馆详情等入口
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *coverImageUrl;

@end
