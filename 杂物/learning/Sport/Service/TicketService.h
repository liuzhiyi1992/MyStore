//
//  TicketService.h
//  Sport
//
//  Created by qiuhaodong on 15/6/29.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SportNetworkContent.h"

@class Voucher;

@protocol TicketServiceDelegate <NSObject>
@optional
- (void)didRechargeDebitCard:(double)balance
                      status:(NSString *)status
                         msg:(NSString *)msg;

- (void)didExpireTicketList:(NSArray *)list
                     status:(NSString *)status
                        msg:(NSString *)msg
                       page:(NSUInteger)page;

- (void)didExpireCouponList:(NSArray *)list
                     status:(NSString *)status
                        msg:(NSString *)msg
                       page:(NSUInteger)page;
//- (void)didGetTicketList:(NSArray *)list
//                  status:(NSString *)status
//                     msg:(NSString *)msg
//                   point:(int)point
//                   money:(float)money
//             usableDays:(NSString *)usableDays
//        userClubStatus:(int)userClubStatus;

- (void)didGetTicketList:(NSArray *)list
                  status:(NSString *)status
                     msg:(NSString *)msg

              usableDays:(NSString *)usableDays
          userClubStatus:(int)userClubStatus;



- (void)didAddVoucher:(NSString *)staus
                  msg:(NSString *)msg
              voucher:(Voucher *)voucher;



@end

@interface TicketService : NSObject

//储值卡余额充值
+ (void)rechargeDebitCard:(id<TicketServiceDelegate>)delegate
                   userId:(NSString *)userId
                 password:(NSString *)password;

//过期运动券列表
+ (void)expireTicketList:(id<TicketServiceDelegate>)delegate
                  userId:(NSString *)userId
                    page:(NSUInteger)page
                   count:(NSUInteger)count;

//卡券列表（包括代金券和运动券）
//+ (void)getTicketList:(id<TicketServiceDelegate>)delegate
//               userId:(NSString *)userId
//             goodsIds:(NSString *)goodsIds
//            orderType:(NSString *)orderType;

//1.8使用
+ (void)getNewTicketList:(id<TicketServiceDelegate>)delegate
               userId:(NSString *)userId
             goodsIds:(NSString *)goodsIds
            orderType:(NSString *)orderType
entry:(NSString * )entry
categoryId:(NSString *)categoryId
cityId:(NSString *)cityId
;


//添加卡券
+ (void)addVoucher:(id<TicketServiceDelegate>)delegate
            userId:(NSString *)userId
     voucherNumber:(NSString *)voucherNumber
          goodsIds:(NSString *)goodsIds
         orderType:(NSString *)orderType;

//获取失效代金券
+ (void)expireCouponList:(id<TicketServiceDelegate>)delegate
                  userId:(NSString *)userId
                    page:(NSUInteger)page
                   count:(NSUInteger)count;

@end
