//
//  ChatMessage.h
//  Sport
//
//  Created by haodong  on 14-5-8.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    ChatTypeSingle = 0,
    ChatTypeGroup = 1,
} ChatType;

typedef enum{
    MessageTypeText = 0,
    MessageTypeInvite = 1,
} MessageType;

@interface ChatMessage : NSObject

@property (copy, nonatomic) NSString *groupId;
@property (copy, nonatomic) NSString *messageId;
@property (copy, nonatomic) NSString *message;
@property (strong, nonatomic) NSDate *addTime;
@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *userAvatar;
@property (copy, nonatomic) NSString *userNickName;

@property (assign, nonatomic) int type;

@property (copy, nonatomic) NSString *activityId;
@property (assign, nonatomic) int       activityThemeId;
@property (copy, nonatomic) NSString *activityCategory;
@property (copy, nonatomic) NSString *activityTime;

@end
