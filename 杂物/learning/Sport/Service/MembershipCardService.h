//
//  MembershipCardService.h
//  Sport
//
//  Created by haodong  on 15/4/16.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SportNetworkContent.h"

@class MembershipCard;
@class Order;

@protocol MembershipCardServiceDelegate <NSObject>
@optional

- (void)didScanCard:(MembershipCard *)card
             status:(NSString *)status
                msg:(NSString *)msg
              title:(NSString *)title
            content:(NSString *)content;

- (void)didScanCardLogined:(MembershipCard *)card
                    status:(NSString *)status
                       msg:(NSString *)msg
                     title:(NSString *)title
                   content:(NSString *)content;

- (void)didCardLogin:(NSString *)status
                 msg:(NSString *)msg;

- (void)didGetCardList:(NSArray *)cardList
                status:(NSString *)status
                   msg:(NSString *)msg;

- (void)didGetCardDetail:(MembershipCard *)card
                  status:(NSString *)status
                     msg:(NSString *)msg;

- (void)didBindCard:(NSString *)status
                msg:(NSString *)msg;

- (void)didUnbindCard:(NSString *)status
                  msg:(NSString *)msg;

- (void)didGetCardUseRecordList:(NSArray *)recordList
                         status:(NSString *)status
                            msg:(NSString *)msg;

- (void)didGetUserCardGoodsList:(NSArray *)goodsList
                         status:(NSString *)status
                            msg:(NSString *)msg;

- (void)didAddUserCardOrder:(Order *)order
                     status:(NSString *)status
                        msg:(NSString *)msg;

- (void)didApplyUserCardRefund:(NSString *)status
                           msg:(NSString *)msg;

@end


@interface MembershipCardService : NSObject

//扫描二维码(未登录)
+ (void)scanCard:(id<MembershipCardServiceDelegate>)delegate
      cardNumber:(NSString *)cardNumber;

//扫描二维码(已登录)
+ (void)scanCardLogined:(id<MembershipCardServiceDelegate>)delegate
             cardNumber:(NSString *)cardNumber
                 userId:(NSString *)userId
                  phone:(NSString *)phone;

//会员卡登录, 非趣运动会自动注册并登录，绑定会员卡
+ (void)cardLogin:(id<MembershipCardServiceDelegate>)delegate
       cardNumber:(NSString *)cardNumber
            phone:(NSString *)phone
          smsCode:(NSString *)smsCode;

//会员卡列表
+ (void)getCardList:(id<MembershipCardServiceDelegate>)delegate;

//会员卡详情
+ (void)getCardDetail:(id<MembershipCardServiceDelegate>)delegate
           cardNumber:(NSString *)cardNumber
               userId:(NSString *)userId
                phone:(NSString *)phone
           businessId:(NSString *)businessId;

//绑定会员卡
+ (void)bindCard:(id<MembershipCardServiceDelegate>)delegate
      cardNumber:(NSString *)cardNumber
          userId:(NSString *)userId
           phone:(NSString *)phone;

//解绑会员卡
+ (void)unbindCard:(id<MembershipCardServiceDelegate>)delegate
        cardNumber:(NSString *)cardNumber
            userId:(NSString *)userId
       payPassword:(NSString *)payPassword
  isSetPayPassword:(int) isSetPayPassword;

//会员卡使用记录
+ (void)getCardUseRecordList:(id<MembershipCardServiceDelegate>)delegate
                  cardNumber:(NSString *)cardNumber
                      userId:(NSString *)userId
                        page:(NSUInteger)page
                       count:(NSUInteger)count
                     venueId:(NSString *)venueId
                mobileNumber:(NSString *)mobileNumber;

//获取充值面额列表
+ (void)getUserCardGoodsList:(id<MembershipCardServiceDelegate>)delegate
                  cardNumber:(NSString *)cardNumber
                      userId:(NSString *)userId;

//下充值订单
+ (void)addUserCardOrder:(id<MembershipCardServiceDelegate>)delegate
                  userId:(NSString *)userId
              cardNumber:(NSString *)cardNumber
                 goodsId:(NSString *)goodsId
                  cityId:(NSString *)cityId
                venuesId:(NSString *)venuesId;

//会员卡退场
+ (void)applyUserCardRefund:(id<MembershipCardServiceDelegate>)delegate
                     userId:(NSString *)userId
                    orderId:(NSString *)orderId;

//重新验证绑定会员卡
+ (void)confirmUserCardWithUserId:(NSString *)userId
                           cardNo:(NSString *)cardNo
                       businessId:(NSString *)businessId
                      phoneEncode:(NSString *)phoneEncode
                          smsCode:(NSString *)smsCode
                       completion:(void(^)(NSString *status,NSString *msg))completion;

//转移新的会员卡
+ (void)setUserCardBindWithUserId:(NSString *)userId
                           cardNo:(NSString *)cardNo
                       businessId:(NSString *)businessId
                      phoneEncode:(NSString *)phoneEncode
                          smsCode:(NSString *)smsCode
                       completion:(void(^)(NSString *status,NSString *msg))completion;

+ (MembershipCard *)parseMembershipCardFromDictionary:(NSDictionary *)dic;

@end
