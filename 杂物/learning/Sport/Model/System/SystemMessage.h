//
//  SystemMessage.h
//  Sport
//
//  Created by 江彦聪 on 15/10/14.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TipNumberManager.h"

typedef NS_ENUM(NSUInteger,MessageFormat) {
    MessageFormatText = 0,
    MessageFormatImageText = 1,
};

typedef NS_ENUM(NSUInteger,MessageType) {
    MessageTypeUser = 0,
    MessageTypeBroadcast = 1,
    MessageTypeRecommendVenues = 2, //推荐场馆
    MessageTypeVoucher = 3,
    MessageTypeOrder = 5,           //订单信息
    MessageTypeShare = 6,           //用户分享或邀请
    MessageTypeMembership = 14,       //会员体系升级、降级通知
    MessageTypeFancyForum = 15,       //精彩运动圈
};


@interface SystemMessage : NSObject
@property (assign, nonatomic) int flag; //消息格式(0:文字,1:图文)
@property (assign, nonatomic) int type; //消息分类 （12:小趣客服，13:优惠促销，14:系统消息，7:运动圈消息）
@property (assign, nonatomic) int messageType; // 消息类型： 0用户消息 1广播 2推荐场馆消息 3代金券消息 5订单消息 6用户分享或邀请 14会员体系升级、降级通知 15运动圈精彩主题

@property (copy, nonatomic) NSString *iconUrl;
@property (copy, nonatomic) NSString *typeName;  //分类名称
@property (copy, nonatomic) NSString *message;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *imageUrl;
@property (strong, nonatomic) NSDate *addTime;
@property (copy, nonatomic) NSString *fromUser;
@property (copy, nonatomic) NSString *content;
@property (copy, nonatomic) NSString *webUrl;
@property (copy, nonatomic) NSString *businessId;
@property (copy, nonatomic) NSString *categroyId;
@property (copy, nonatomic) NSString *postId;
@property (copy, nonatomic) NSString *activityTimeString;

//@property (strong, nonatomic) NSArray* extra;
@property (assign, nonatomic) int number;

@end
