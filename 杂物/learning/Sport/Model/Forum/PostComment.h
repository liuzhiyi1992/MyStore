//
//  PostComment.h
//  Sport
//
//  Created by 江彦聪 on 15/5/13.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostComment : NSObject
@property (copy, nonatomic) NSString *commentId;
@property (copy, nonatomic) NSString *postId;
@property (copy, nonatomic) NSString *content;
@property (strong, nonatomic) NSDate *createDate;
@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *avatar;
@property (copy, nonatomic) NSString *userName;

@end
