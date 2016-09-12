//
//  CourtJoinService.h
//  Sport
//
//  Created by 江彦聪 on 16/6/6.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SportNetworkContent.h"
#import "CourtJoin.h"
#import "Product.h"
#import "Order.h"

@class ShareContent;
@protocol CourtJoinServiceDelegate<NSObject>
@optional
- (void)didGetCourtJoinList:(NSArray *)courtJoinList
          courtJoinDateList:(NSArray *)courtJoinDateList
    courtJoinCategoriesList:(NSArray *)courtJoinCategoriesList
  currentSelectedCategoryName:(NSString *)currentSelectedCategoryName
                currentDate:(NSDate *)currentTime
                     status:(NSString *)status
                        msg:(NSString *)msg;
    
@end

@interface CourtJoinService : NSObject

+ (void)getCourtJoinInfo:(NSString *)courtJoinId  userId:(NSString *)userId completion:(void(^)(NSString *status,NSString *msg,CourtJoin *courtJoin))completion;

+ (void)sponsorCourtJoinWithUserId:(NSString *)userId
                           orderId:(NSString *)orderId
                             phone:(NSString *)phone
                        playersNum:(int)playersNum
                       description:(NSString *)description
                        completion:(void(^)(NSString *status, NSString *msg, NSString *shareUrl, BOOL isFirst, ShareContent *shareContent))completion;


+ (void)updateCourtJoinDescWithOrderId:(NSString *)orderId userId:(NSString *)userId desc:(NSString *)desc completion:(void(^)(NSString *status, NSString *msg, NSString *resultStatus))completion;

+ (void)getCourtJoinOrderDetailWithOrderId:(NSString *)orderId completion:(void(^)(NSString *status, NSString *msg, Order *order))completion;

+ (CourtJoin *)courtJoinByOneCourtJoinDictionary:(NSDictionary *)CourtJoinDictionary;

+ (void)getCourtJoinList:(id<CourtJoinServiceDelegate>)delegate
                latitude:(double)latitude
               longitude:(double)longitude
                   count:(int)count
                    page:(int)page
              categoryId:(NSString *)categoryId
                  userId:(NSString *)userId
                bookDate:(NSDate *)bookDate;

+ (void) confirmOrderCourtJoinWithId:(NSString *)courtJoinId userId:(NSString *)userId completion:(void (^)(NSString *status, NSString *msg,CourtJoin *courtJoin))completion;


@end
