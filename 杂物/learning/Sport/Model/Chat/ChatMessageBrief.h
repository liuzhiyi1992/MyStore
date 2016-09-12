//
//  ChatMessageBrief.h
//  Sport
//
//  Created by haodong  on 14-5-8.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatMessageBrief : NSObject

@property (copy, nonatomic) NSString *groupId;
@property (assign, nonatomic) int groupType; //0是私聊，1是群聊
@property (copy, nonatomic) NSString *groupName;
@property (copy, nonatomic) NSString *messageId;
@property (assign, nonatomic) int messageType;
@property (copy, nonatomic) NSString *message;
@property (strong, nonatomic) NSDate *addTime;
@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *userAvatar;
@property (copy, nonatomic) NSString *userNickName;

@property (assign, nonatomic) int messageCount;

@end
