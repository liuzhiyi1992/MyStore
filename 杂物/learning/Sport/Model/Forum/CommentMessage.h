//
//  CommentMessage.h
//  Sport
//
//  Created by 江彦聪 on 15/5/19.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentMessage : NSObject

@property (retain,nonatomic) NSString *commentId;
@property (retain,nonatomic) NSString *commentContent;
@property (retain,nonatomic) NSString *postId;
@property (retain,nonatomic) NSString *postContent;
@property (retain,nonatomic) NSString *fromUserId;
@property (retain,nonatomic) NSString *toUserId;
@property (assign,nonatomic) BOOL hasAttach;
@property (retain,nonatomic) NSString *imageUrl;
@property (retain,nonatomic) NSString *thumbUrl;
@property (retain,nonatomic) NSDate *createTime;
@property (retain,nonatomic) NSString *fromUserName;
@property (retain,nonatomic) NSString *fromUserAvatarUrl;


@end
