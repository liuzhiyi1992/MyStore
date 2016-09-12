//
//  CoachService.h
//  Sport
//
//  Created by 江彦聪 on 15/7/14.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SportNetworkContent.h"

@class Order;
@class Coach;
@class CoachBookingInfo;
@class CoachCancelReason;
@class RCUserInfo;

@protocol CoachServiceDelegate <NSObject>

@optional

- (void)didgetCoachCategory:(NSArray *)categoryList
                     status:(NSString *)status
                        msg:(NSString *)msg;

- (void)didGetCoachOrderList:(NSArray *)orderList
                        page:(NSUInteger)page
                      status:(NSString *)status
                         msg:(NSString *)msg;

- (void)didGetCoachOrderInfo:(Order *)order
                      status:(NSString *)status
                         msg:(NSString *)msg;

- (void)didGetCoachList:(NSArray *)coachList
                 status:(NSString *)status
                    msg:(NSString *)msg
                   page:(NSUInteger)page;

- (void)didSendCoachComment:(NSString *)status
                        msg:(NSString *)msg;

- (void)didGetCoachInfo:(Coach *)coach
                      status:(NSString *)status
                         msg:(NSString *)msg;

- (void)didGetCoachBookingInfo:(NSArray *)infoList
                 status:(NSString *)status
                    msg:(NSString *)msg;

- (void)didCoachConfirmOrder:(NSString *)status
                         msg:(NSString *)msg
                 totalAmount:(float)totalAmount
                 orderAmount:(float)orderAmount
                orderPromote:(float)orderPromote
                activityList:(NSArray *)activityList
             activityMessage:(NSString *)activityMessage
          selectedActivityId:(NSString *)selectedActivityId;

- (void)didAddCoachOrder:(NSString *)status
                     msg:(NSString *)msg
                   order:(Order *)order
          cancelOrderMsg:(NSString *)cancelOrderMsg;

- (void)didCancelCoachBooking:(NSString *)status
                           msg:(NSString *)msg;

- (void)didGetCoachCancelReason:(NSArray *)causeList
                        status:(NSString *)status
                           msg:(NSString *)msg;

- (void)didConfirmService:(NSString *)status
                          msg:(NSString *)msg;

- (void)didSendCoachComplain:(NSString *)status
                        msg:(NSString *)msg;

- (void)didGetCoachCommentList:(NSArray *)commentList
                          page:(NSUInteger)page
                        status:(NSString *)status
                           msg:(NSString *)msg;

- (void)didQueryFavoriteCoachList:(NSString *)status
                              msg:(NSString *)msg
                        coachList:(NSArray *)coachList;

- (void)didUserCollectionCoach:(NSString *)status
                           msg:(NSString *)msg;

@end

@interface CoachService : NSObject

//获取陪练项目列表
+ (void)getCoachCategory:(id<CoachServiceDelegate>)delegate;

//教练订单列表
+ (void)getCoachOrderList:(id<CoachServiceDelegate>)delegate
           userId:(NSString *)userId
                count:(int)count
                 page:(int)page;

//教练订单详情
+ (void)getCoachOrderInfo:(id<CoachServiceDelegate>)delegate
        orderId:(NSString *)orderId;

//获取教练列表
+ (void)getCoachList:(id<CoachServiceDelegate>)delegate
              cityId:(NSString *)cityId
          categoryId:(NSString *)categoryId
              gender:(NSString *)gender
                sort:(NSString *)sort
                page:(NSUInteger)page
               count:(NSUInteger)count
            latitude:(double)latitude
           longitude:(double)longitude;

//发表评论
+ (void)sendCoachComment:(id<CoachServiceDelegate>)delegate
                 coachId:(NSString *)coachId
                    text:(NSString *)text
                  userId:(NSString *)userId
             commentRank:(int)commentRank
                 orderId:(NSString *)orderId
              galleryIds:(NSString *)galleryIds;

//教练详情
+ (void)getCoachInfo:(id<CoachServiceDelegate>)delegate
              userId:(NSString *)userId
             coachId:(NSString *)coachId;

//获取预约时间
+ (void)getCoachBespeakTime:(id<CoachServiceDelegate>)delegate
                    coachId:(NSString *)coachId;

// 1.9 新确认订单
+ (void)coachConfirmOrderBespeak:(id<CoachServiceDelegate>)delegate
                          userId:(NSString *)userId
                         goodsId:(NSString *)goodsId
                       startTime:(NSDate *)startTime
                       orderType:(int)orderType;

// 1.9 新新增订单
+ (void)addCoachOrderBespeak:(id<CoachServiceDelegate>)delegate
                      userId:(NSString *)userId
                       phone:(NSString *)phone
                     coachId:(NSString *)coachId
                     address:(NSString *)address
                     goodsId:(NSString *)goodsId
                   startTime:(NSDate *)startTime
                   orderType:(int)orderType
                  activityId:(NSString *)activityId
                    couponId:(NSString *)couponId
                      cityId:(NSString *)cityId
                 voucherType:(int)voucherType;

//取消预约
+ (void)cancelCoachBespeak:(id<CoachServiceDelegate>)delegate
                    userId:(NSString *)userId
                   orderId:(NSString *)orderId
                  reasonId:(NSString *)reasonId;

//确认预约
+ (void)confirmService:(id<CoachServiceDelegate>)delegate
                userId:(NSString *)userId
               orderId:(NSString *)orderId;

//取消预约原因
+ (void)getCoachCancelReason:(id<CoachServiceDelegate>)delegate
                      userId:(NSString *)userId;

//获取评论列表
+ (void)getCoachCommentList:(id<CoachServiceDelegate>)delegate
                    coachId:(NSString *)coachId
                       page:(NSUInteger)page
                      count:(NSUInteger)count;

//投诉教练
+ (void)sendCoachComplain:(id<CoachServiceDelegate>)delegate
                  coachId:(NSString *)coachId
                  content:(NSString *)content
                   userId:(NSString *)userId
                  orderId:(NSString *)orderId;

//获取收藏教练
+ (void)queryFavoriteCoachList:(id<CoachServiceDelegate>)delegate
                        userId:(NSString *)userId;

+ (void)userCollectionCoach:(id<CoachServiceDelegate>)delegate
                     userId:(NSString *)userId
                    coachId:(NSString *)coachId
                       type:(int)type;


+ (Coach *)coachByOneCoachDictionary:(NSDictionary *)coachDictionary;
+ (CoachBookingInfo *)infoByOneBookingInfoDictionary:(NSDictionary *)infoDictionary;
@end
