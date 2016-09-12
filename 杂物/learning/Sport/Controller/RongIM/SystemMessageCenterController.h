//
//  SystemMessageCenterController.h
//  Sport
//
//  Created by 江彦聪 on 15/10/8.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "SportController.h"
#import <RongIMKit/RongIMKit.h>

#define RC_IMAGE_TEXT_MSG @"RC:ImgTextMsg"
#define RC_TEXT_MSG @"RC:TxtMsg"
#define RC_IMAGE_MSG @"RC:ImgMsg"

@interface SystemMessageCenterController : SportController<UITableViewDataSource,UITableViewDelegate>
/**
 *  targetId
 */
@property(nonatomic, strong) NSString *targetId;
/**
 *  targetName
 */
@property(nonatomic, strong) NSString *userName;
/**
 *  conversationType
 */
@property(nonatomic) RCConversationType conversationType;
/**
 * model
 */
@property (strong,nonatomic) RCConversationModel *conversation;

/*!
 当前会话最近一条消息Id
 */
@property(nonatomic, assign) long lastestMessageId;

-(instancetype) initWithType:(int)type;

@end
