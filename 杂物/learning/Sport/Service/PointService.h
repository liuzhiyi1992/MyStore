//
//  PointService.h
//  Sport
//
//  Created by haodong  on 14/11/12.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SportNetworkContent.h"

@protocol PointServiceDelegate <NSObject>
@optional
- (void)didQueryPointGoodsList:(NSArray *)list
                        status:(NSString *)status
                           msg:(NSString *)msg
                       myPoint:(int)myPoint
                  onceUsePoint:(int)onceUsePoint
                  pointRuleUrl:(NSString *)pointRuleUrl
                   drawRuleUrl:(NSString *)drawRuleUrl;

- (void)didConvertGoods:(NSString *)status
                    msg:(NSString *)msg;

- (void)didQueryPointRecordList:(NSArray *)list
                         status:(NSString *)status
                            msg:(NSString *)msg;

- (void)didLuckyDraw:(NSString *)status
                 msg:(NSString *)msg
              drawId:(NSString *)drawId
             goodsId:(NSString *)goodsId
               point:(int)point;

- (void)didQueryDrawNewsList:(NSArray *)newsList status:(NSString *)status;

- (void)didQueryDrawRecordList:(NSArray *)list status:(NSString *)status msg:(NSString *)msg;

@end

@interface PointService : NSObject

+ (void)queryPointGoodsList:(id<PointServiceDelegate>)delegate
                     userId:(NSString *)userId
                       type:(NSString *)type;

+ (void)convertGoods:(id<PointServiceDelegate>)delegate
              userId:(NSString *)userId
             goodsId:(NSString *)goodsId
              drawId:(NSString *)drawId
                type:(NSString *)type       //0积分兑换(要传goodsId)、1抽奖兑换(要传goodsId和drawId)
               phone:(NSString *)phone;     //实物要传手机号

+ (void)queryPointRecordList:(id<PointServiceDelegate>)delegate
                      userId:(NSString *)userId
                        page:(int)page
                       count:(int)count;

+ (void)luckyDraw:(id<PointServiceDelegate>)delegate
           userId:(NSString *)userId;

+ (void)queryDrawNewsList:(id<PointServiceDelegate>)delegate;

+ (void)queryDrawRecordList:(id<PointServiceDelegate>)delegate
                     userId:(NSString *)userId
                       page:(int)page
                      count:(int)count;

@end
