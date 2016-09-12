//
//  SystemNoticeMessage.h
//  Sport
//
//  Created by haodong  on 14-5-16.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SystemNoticeMessageTypeText = 0,
    SystemNoticeMessageTypeActivity = 1,
    SystemNoticeMessageTypeLemon = 2
} SystemNoticeMessageType;

@interface SystemNoticeMessage : NSObject

@property (copy, nonatomic) NSString *messageId;
@property (assign, nonatomic) SystemNoticeMessageType type;
@property (copy, nonatomic) NSString *message;
@property (strong, nonatomic) NSDate *addTime;

//活动消息类型
@property (copy, nonatomic) NSString *activityId;
@property (assign, nonatomic) int       activityThemeId;
@property (copy, nonatomic) NSString *activityCategory;
@property (copy, nonatomic) NSString *activityTime;
@property (copy, nonatomic) NSString *activityCreateUserId;
@property (assign, nonatomic) int       activityStatus;

//柠檬消息类型
@property (copy, nonatomic) NSString *lemonUserId;
@property (copy, nonatomic) NSString *lemonAvatarUrl;
@property (copy, nonatomic) NSString *lemonUserNickname;
@property (assign, nonatomic) int lemonCount;

@end
