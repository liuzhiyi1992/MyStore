//
//  TipNumberManager.h
//  Sport
//
//  Created by haodong  on 13-11-7.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger,MessageCountType) {
    MessageCountTypeUser = 0,
    MessageCountTypeChat = 1,
    MessageCountTypeNeedPayOrder = 2,
    MessageCountTypeVoucher = 3,
    MessageCountTypeBroadcast = 4,
    MessageCountTypeCanComment = 5,
    MessageCountTypeForum = 7,       //注意这里是7 运动圈
    MessageCountTypeIM = 8,
    MessageCountTypeReadyBegin = 9,  //待开始
    MessageCountTypeNewCard = 10,  //会员卡
    MessageCountTypeCustomService = 12,  //客服
    MessageCountTypeSales = 13,         //优惠
    MessageCountTypeSystem = 14,        //系统消息
    MessageCountTypeCardChange = 15,    //会员卡变更
};

const NSArray *messageCountTypeArray;

// 创建初始化函数。等于用宏创建一个getter函数
#define MessageCountTypeGet (messageCountTypeArray == nil ? messageCountTypeArray = [[NSArray alloc] initWithObjects:\
@"MessageCountTypeUser",\
@"MessageCountTypeChat",\
@"MessageCountTypeNeedPayOrder",\
@"MessageCountTypeVoucher",\
@"MessageCountTypeBroadcast",\
@"MessageCountTypeCanComment",\
@"",\
@"MessageCountTypeForum",\
@"MessageCountTypeIM",\
@"MessageCountTypeReadyBegin",\
@"MessageCountTypeNewCard",\
@"",\
@"MessageCountTypeCustomService",\
@"MessageCountTypeSales",\
@"MessageCountTypeSystem",\
nil] : messageCountTypeArray)
// 枚举 to 字串
#define MessageCountTypeString(type) ([MessageCountTypeGet objectAtIndex:type])
// 字串 to 枚举
#define MessageCountTypeEnum(string) ([MessageCountTypeGet indexOfObject:string])

@interface TipNumberManager : NSObject
@property (assign, nonatomic) NSUInteger myCommentTipCount; //弃用

@property (assign, nonatomic) NSUInteger userMessageCount;   //用户新消息数 //原命名systemNoticeCount
@property (assign, nonatomic) NSUInteger chatMessageCount;    //聊天新消息数
@property (assign, nonatomic) NSUInteger needPayOrderCount;   //未支付订单数
@property (assign, nonatomic) NSUInteger voucherCount;        //新代金券数
@property (assign, nonatomic) NSUInteger broadcastCount;      //新广播数
@property (assign, nonatomic) NSUInteger canCommentCount;     //可评论订单的数目
@property (assign, nonatomic) NSUInteger forumMessageCount;   //圈子消息数
@property (assign, nonatomic) NSUInteger imReceiveMessageCount;   //融云收到的消息数
@property (assign, nonatomic) NSUInteger readyBeginCount;      //准备开始订单数
@property (assign, nonatomic) NSUInteger newCardCount;      //准备开始订单数
@property (assign, nonatomic) NSUInteger customerServiceMessageCount; //客服消息数
@property (assign, nonatomic) NSUInteger salesMessageCount;     //优惠消息数
@property (assign, nonatomic) NSUInteger systemMessageCount;   //系统消息数
@property (assign, nonatomic) NSUInteger isShowSurveyTips;   //是否显示点击调查问券红点 0不显示 1显示 (当更新UserManager isClickSurvey时需要更新这个值)
@property (assign, nonatomic) NSUInteger cardChangeCount;


+ (TipNumberManager *)defaultManager;

- (void)clearAllCount;
- (void)setMessageCount:(MessageCountType)type
                 count:(NSUInteger)count;
-(NSUInteger)getMessageCount:(MessageCountType)type;

- (void)addObserverForAllProperties;
- (void)removeObserverForAllProperties;

@end
