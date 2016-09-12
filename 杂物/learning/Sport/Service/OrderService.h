//
//  OrderService.h
//  Sport
//
//  Created by haodong  on 13-7-22.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SportNetworkContent.h"
#import "GSNetwork.h"
#import "ConfirmOrder.h"

@class Order;

typedef NS_ENUM(NSInteger, ClubStatus) {
    CLUB_STATUS_UNPAID = 0,
    CLUB_STATUS_PAID_VALID,
    CLUB_STATUS_PAID_INVALID,
    CLUB_STATUS_EXPIRE,
    CLUB_STATUS_FORBID,
};

@protocol OrderServiceDelegate <NSObject>
@optional
- (void)didSubmitOrder:(NSString *)status
           resultOrder:(Order *)resultOrder
                   msg:(NSString *)msg;

- (void)didSubmitOrder:(NSString *)status
           resultOrder:(Order *)resultOrder
                   msg:(NSString *)msg
        cancelOrderMsg:(NSString *)cancelMsg;
- (void)didQueryOrderDetail:(NSString *)status
                        msg:(NSString *)msg
                resultOrder:(Order *)resultOrder;

- (void)didQueryOrderList:(NSString *)status
                      msg:(NSString *)msg
                orderList:(NSArray *)orderList
                     page:(int)page
              orderStatus:(int)orderStatus;

- (void)didCancelOrder:(NSString *)status
               orderId:(NSString *)orderId;

- (void)didGetOrderAmount:(NSString *)status
                      msg:(NSString *)msg
                   amount:(double)amount;

- (void)didQueryNeedPayOrderCount:(NSString *)status
                            count:(NSUInteger)count
                            order:(Order *)order;

- (void)didCheckActivityInviteCode:(NSString *)inviteCode
                            status:(NSString *)status
                               msg:(NSString *)msg;

//场次
- (void)didConfirmOrder:(NSString *)status
                    msg:(NSString *)msg
            totalAmount:(float)totalAmount
          promoteAmount:(float)promoteAmount
              payAmount:(float)payAmount
     selectedActivityId:(NSString *)selectedActivityId
           activityList:(NSArray *)activityList
               onePrice:(float)onePirce
              userMoney:(float)userMoney
              canRefund:(BOOL)canRefund
        activityMessage:(NSString *)activityMessage
             isCardUser:(BOOL)isCardUser
          refundMessage:(NSString *)refundMessage
isSupportMembershipCard:(BOOL)isSupportCard
               cardList:(NSArray *)cardList
          insuranceList:(NSArray *)insuranceList
      isIncludeInsurance:(BOOL)isIncludeInsurance
          insuranceTips:(NSString *)insuranceTips
           insuranceUrl:(NSString *)insuranceUrl
     insuranceOrderTime:(int)insuranceOrderTime
     insuranceLimitTips:(NSString *)insuranceLimitTips;

//人次
- (void)didConfirmOrder:(NSString *)status
                    msg:(NSString *)msg
            totalAmount:(float)totalAmount
          promoteAmount:(float)promoteAmount
              payAmount:(float)payAmount
     selectedActivityId:(NSString *)selectedActivityId
           activityList:(NSArray *)activityList
               onePrice:(float)onePirce
              userMoney:(float)userMoney
              canRefund:(BOOL)canRefund
        activityMessage:(NSString *)activityMessage
             isCardUser:(BOOL)isCardUser
          refundMessage:(NSString *)refundMessage
          isSupportClub:(BOOL)isSupportClub
         userClubStatus:(int)userClubStatus
         clubDisableMsg:(NSString *)clubDisableMsg
           noBuyClubMsg:(NSString *)noBuyClubMsg
     noUsedClubOrderMsg:(NSString *)noUsedClubOrderMsg;


- (void) didConfirmOrder:(NSString *) status
                     msg:(NSString *) msg
            confirmOrder:(ConfirmOrder *) confirmOrder;

- (void)didCheckOrderRefund:(NSString *)status
                        msg:(NSString *)msg
               refundAmount:(float)refundAmount
              refundWayList:(NSArray *)refundWayList
            refundCauseList:(NSArray *)refundCauseList
               canRefundNum:(int)canRefundNum
                  priceList:(NSArray *)priceList;

- (void)didGetRefundStatus:(NSString *)status
                       msg:(NSString *)msg
              refundStatus:(int)refundStatus
              refundAmount:(float)refundAmount
                 refundWay:(NSString *)refundWay;

- (void)didApplyRefund:(NSString *)status
                   msg:(NSString *)msg
          refundStatus:(int)refundStatus
          refundAmount:(float)refundAmount
             refundWay:(NSString *)refundWay
;

- (void)didCancelClubOrder:(NSString *)status
                       msg:(NSString *)msg
               orderId:(NSString *)orderId;

@end

@interface OrderService : NSObject

+ (Order *)orderByOneOrderDictionary:(NSDictionary *)orderDictionary;

+ (void)submitOrder:(id<OrderServiceDelegate>)delegate
             userId:(NSString *)userId
        goodsIdList:(NSString *)goodsIdList
              count:(NSInteger)count
               type:(int)type
         activityId:(NSString *)activityId
         inviteCode:(NSString *)inviteCode
          voucherId:(NSString *)voucherId
        voucherType:(int)voucherType
              phone:(NSString *)phone
          isClubPay:(BOOL)isClubPay
             cityId:(NSString *)cityId
         cardNumber:(NSString *)cardNumber
        insuranceId:(NSString *)insuranceId
  insuranceQuantity:(int)insuranceQuantity
           saleList:(NSString *)saleList;

+ (void)queryOrderDetail:(id<OrderServiceDelegate>)delegate
                 orderId:(NSString *)orderId
                  userId:(NSString *)userId
                 isShare:(NSString *)isShare
                entrance:(int)entrance;

//- (void)queryOrderList:(id<OrderServiceDelegate>)delegate
//                userId:(NSString *)userId
//           orderStatus:(int)orderStatus
//                  page:(int)page
//                 count:(int)count;

+ (void)queryNewUIOrderList:(id<OrderServiceDelegate>)delegate
                     userId:(NSString *)userId
                orderStatus:(int)orderStatus
                       page:(int)page
                      count:(int)count;

+ (void)cancelOrder:(id<OrderServiceDelegate>)delegate
              order:(Order *)order
             userId:(NSString *)userId;

+ (NSArray *)activityListByDictionaryList:(NSArray *)dictionaryList;

+ (void)queryNeedPayOrderCount:(id<OrderServiceDelegate>)delegate
                        userId:(NSString *)userId;

+ (void)checkActivityInviteCode:(id<OrderServiceDelegate>)delegate
                         userId:(NSString *)userId
                     activityId:(NSString *)activityId
                     inviteCode:(NSString *)inviteCode;

+ (void)confirmOrder:(id<OrderServiceDelegate>)delegate
              userId:(NSString *)userId
         goodsIdList:(NSString *)goodsIdList
           orderType:(int)orderType
               count:(int)count;

+ (void)checkOrderRefund:(id<OrderServiceDelegate>)delegate
                  userId:(NSString *)userId
                 orderId:(NSString *)orderId;

+ (void)getRefundStatus:(id<OrderServiceDelegate>)delegate
                 userId:(NSString *)userId
                orderId:(NSString *)orderId;

+ (void)applyRefund:(id<OrderServiceDelegate>)delegate
             userId:(NSString *)userId
            orderId:(NSString *)orderId
        refundWayId:(NSString *)refundWayId
        refundCause:(NSString *)refundCause
        description:(NSString *)description
        refundNumer:(int)refundNumber;

+ (void)cancelClubOrder:(id<OrderServiceDelegate>)delegate
              order:(Order *)order
             userId:(NSString *)userId;

//新增拼场订单
+ (void)submitOrderByCourtPool:(id<OrderServiceDelegate>)delegate
                        userId:(NSString *)userId
                   courtPoolId:(NSString *)poolId
                          type:(int)type
                         phone:(NSString *)phone
                         level:(NSString *)levelId;

+ (void)submitOrderByCourtJoinWithUserId:(NSString *)userId
                             courtJoinId:(NSString *)courtJoinId
                                   phone:(NSString *)phone
                              completion:(void (^)(NSString *status,NSString *msg, Order * order))completion;

@end
