//
//  CoachService.m
//  Sport
//
//  Created by 江彦聪 on 15/7/14.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CoachService.h"
#import "OrderService.h"
#import "Coach.h"
#import "BusinessCategory.h"
#import "CoachBookingInfo.h"
#import "CoachCancelReason.h"
#import "CoachPhoto.h"
#import <RongIMLib/RCUserInfo.h>
#import "CoachServiceArea.h"
#import "Comment.h"
#import "BusinessCategory.h"
#import "CoachSportExperience.h"
#import "CoachProjects.h"
#import "CoachOftenArea.h"
#import "GSNetwork.h"

#define PHP_VER     @"2.0"

@implementation CoachService

//获取陪练项目列表
+ (void)getCoachCategory:(id<CoachServiceDelegate>)delegate
{
    
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_COACH_CATEGORY forKey:PARA_ACTION];
    [inputDic setValue:PHP_VER forKey:PARA_VER];
    [GSNetwork getWithBasicUrlString:GS_URL_COACH parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSMutableArray *categoryList = [NSMutableArray array];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        for (NSDictionary *one in [data validArrayValueForKey:PARA_LIST]) {
            if (![one isKindOfClass:[NSDictionary class]]){
                continue;
            }
            
            BusinessCategory *category = [[BusinessCategory alloc] init] ;
            category.businessCategoryId = [one validStringValueForKey:PARA_CAT_ID];
            category.name = [one validStringValueForKey:PARA_CAT_NAME];
            category.imageUrl = [one validStringValueForKey:PARA_GRAY_IMG];
            category.activeImageUrl = [one validStringValueForKey:PARA_ACTIVE_IMG];
            [categoryList addObject:category];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didgetCoachCategory:status:msg:)]) {
                [delegate didgetCoachCategory:categoryList status:status msg:msg];
            }
        });
    }];
}

//教练订单列表
+ (void)getCoachOrderList:(id<CoachServiceDelegate>)delegate
                   userId:(NSString *)userId
                    count:(int)count
                     page:(int)page
{
    
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_COACH_ORDER_LIST forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    
    [inputDic setValue:[NSString stringWithFormat:@"%d", count] forKey:PARA_COUNT];
    [inputDic setValue:[NSString stringWithFormat:@"%d", page] forKey:PARA_PAGE];

    [inputDic setValue:PHP_VER forKey:PARA_VER];
    [GSNetwork getWithBasicUrlString:GS_URL_COACH parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        NSArray *orderListSource = [data validArrayValueForKey:PARA_LIST];
        NSMutableArray *orderListTarget = [NSMutableArray array];
        
        for (id oneOrderSource in orderListSource) {
            if ([oneOrderSource isKindOfClass:[NSDictionary class]] == NO) {
                continue;
            }
            Order *orderTarget = [OrderService orderByOneOrderDictionary:oneOrderSource];
            [orderListTarget addObject:orderTarget];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didGetCoachOrderList:page:status:msg:)]) {
                [delegate didGetCoachOrderList:orderListTarget page:page status:status msg:msg];
            }
        });
    }];
}

//教练订单详情
+ (void)getCoachOrderInfo:(id<CoachServiceDelegate>)delegate
                  orderId:(NSString *)orderId
{
     NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_COACH_ORDER_INFO forKey:PARA_ACTION];
    [inputDic setValue:orderId forKey:PARA_ORDER_ID];
        
    [GSNetwork getWithBasicUrlString:GS_URL_COACH parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        Order *order = nil;
        if ([status isEqualToString:STATUS_SUCCESS]) {
            NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
            order = [OrderService orderByOneOrderDictionary:data];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didGetCoachOrderInfo:status:msg:)]) {
                [delegate didGetCoachOrderInfo:order status:status msg:msg];
            }
        });
    }];
}

+ (void)sendCoachComment:(id<CoachServiceDelegate>)delegate
         coachId:(NSString *)coachId
               text:(NSString *)text
             userId:(NSString *)userId
        commentRank:(int)commentRank
            orderId:(NSString *)orderId
         galleryIds:(NSString *)galleryIds
{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_ADD_COACH_COMMENT forKey:PARA_ACTION];
        [inputDic setValue:coachId forKey:PARA_COACH_ID];
        [inputDic setValue:text forKey:PARA_CONTENT];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        [inputDic setValue:[NSString stringWithFormat:@"%d", commentRank] forKey:PARA_RANK];
        [inputDic setValue:orderId forKey:PARA_ORDER_ID];
        [inputDic setValue:galleryIds forKey:PARA_IMAGES];
        
        [GSNetwork getWithBasicUrlString:GS_URL_COACH parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
            NSDictionary *resultDictionary = response.jsonResult;
            
        //parse
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        if ([status isEqualToString:STATUS_SUCCESS]) {
            NSDictionary *dic = @{@"order_id":orderId};
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_FINISH_WRITE_REVIEW object:nil userInfo:dic];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didSendCoachComment:msg:)]) {
                [delegate didSendCoachComment:status msg:msg];
            }
        });
    }];
}

+ (void)getCoachList:(id<CoachServiceDelegate>)delegate
              cityId:(NSString *)cityId
          categoryId:(NSString *)categoryId
              gender:(NSString *)gender
                sort:(NSString *)sort
                page:(NSUInteger)page
               count:(NSUInteger)count
            latitude:(double)latitude
           longitude:(double)longitude
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_COACH_LIST forKey:PARA_ACTION];
    [inputDic setValue:cityId forKey:PARA_CITY_ID];
    [inputDic setValue:categoryId forKey:PARA_CATEGORY_ID];
    [inputDic setValue:gender forKey:PARA_GENDER];
    [inputDic setValue:sort forKey:PARA_SORT];
    [inputDic setValue:[@(page) stringValue] forKey:PARA_PAGE];
    [inputDic setValue:[@(count) stringValue] forKey:PARA_COUNT];
    [inputDic setValue:[@(latitude) stringValue] forKey:PARA_LATITUDE];
    [inputDic setValue:[@(longitude) stringValue] forKey:PARA_LONGITUDE];
    [inputDic setValue:PHP_VER forKey:PARA_VER];
    
    [GSNetwork getWithBasicUrlString:GS_URL_COACH parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSMutableArray *coachList = nil;
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        if ([status isEqualToString:STATUS_SUCCESS]) {
            coachList = [NSMutableArray array];
            for (NSDictionary *one in [data validArrayValueForKey:PARA_LIST]) {
                if (![one isKindOfClass:[NSDictionary class]]){
                    continue;
                }
                Coach *coach = [CoachService coachByOneCoachDictionary:one];
                [coachList addObject:coach];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didGetCoachList:status:msg:page:)]) {
                [delegate didGetCoachList:coachList status:status msg:msg page:page];
            }
        });
    }];
}

//教练信息详情
+ (void)getCoachInfo:(id<CoachServiceDelegate>)delegate
              userId:(NSString *)userId
             coachId:(NSString *)coachId
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_COACH_INFO forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:coachId forKey:PARA_COACH_ID];
    [inputDic setValue:PHP_VER forKey:PARA_VER];     //接口返回加多一个是否被屏蔽字段
    [GSNetwork getWithBasicUrlString:GS_URL_COACH parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
            
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        Coach *coach = nil;
        if ([status isEqualToString:STATUS_SUCCESS]) {
            NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
            coach = [CoachService coachByOneCoachDictionary:data];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didGetCoachInfo:status:msg:)]) {
                [delegate didGetCoachInfo:coach status:status msg:msg];
            }
        });
    }];
}

//教练预约时间查询
+ (void)getCoachBespeakTime:(id<CoachServiceDelegate>)delegate
             coachId:(NSString *)coachId
{
     NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_BESPEAK_TIME forKey:PARA_ACTION];
    [inputDic setValue:coachId forKey:PARA_COACH_ID];
    [inputDic setValue:PHP_VER forKey:PARA_VER];
    
    [GSNetwork getWithBasicUrlString:GS_URL_COACH parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSArray *bookingListSource = [resultDictionary validArrayValueForKey:PARA_DATA];
        NSMutableArray *bookingListTarget = [NSMutableArray array];
        
        for (id oneInfoSource in bookingListSource) {
            if ([oneInfoSource isKindOfClass:[NSDictionary class]] == NO) {
                continue;
            }
            CoachBookingInfo *infoTarget = [CoachService infoByOneBookingInfoDictionary:oneInfoSource];
            [bookingListTarget addObject:infoTarget];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didGetCoachBookingInfo:status:msg:)]) {
                [delegate didGetCoachBookingInfo:bookingListTarget status:status msg:msg];
            }
        });
    }];
}

//1.9 新确认订单
+ (void)coachConfirmOrderBespeak:(id<CoachServiceDelegate>)delegate
                   userId:(NSString *)userId
                    goodsId:(NSString *)goodsId
                 startTime:(NSDate *)startTime
                       orderType:(int)orderType
{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_ORDER_CONFIRM_ORDER_BESPEAK forKey:PARA_ACTION];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        [inputDic setValue:goodsId forKey:PARA_GOODS_IDS];
        [inputDic setValue:[NSString stringWithFormat:@"%d", (int)[startTime timeIntervalSince1970]] forKey:PARA_START_TIME];
        [inputDic setValue:[@(orderType) stringValue] forKey:PARA_ORDER_TYPE];
        [GSNetwork getWithBasicUrlString:GS_URL_ORDER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
            NSDictionary *resultDictionary = response.jsonResult;
            NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
            NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
            NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
            float totalAmount = [data validFloatValueForKey:PARA_TOTAL_AMOUNT];
            float orderAmount = [data validFloatValueForKey:PARA_ORDER_AMOUNT];
            float orderPromote = [data validFloatValueForKey:PARA_ORDER_PROMOTE];
            NSArray *activityList = [OrderService activityListByDictionaryList:[data validArrayValueForKey:PARA_ACTIVITY_LIST]];
            NSString *activityMessage = [data validStringValueForKey:PARA_ACTIVITY_MESSAGE];
            NSString *selectedActivityId = [data validStringValueForKey:PARA_ACT_ID];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([delegate respondsToSelector:@selector(didCoachConfirmOrder:msg:totalAmount:orderAmount:orderPromote:activityList:activityMessage:selectedActivityId:)]) {
                    [delegate didCoachConfirmOrder:status
                                               msg:msg
                                       totalAmount:totalAmount
                                       orderAmount:orderAmount
                                      orderPromote:orderPromote
                                      activityList:activityList
                                   activityMessage:activityMessage
                                selectedActivityId:selectedActivityId];
                }
            });
        }];
}

//1.9 新增订单
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
                 voucherType:(int)voucherType
{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_ORDER_INSERT_ORDER_BESPEAK forKey:PARA_ACTION];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        [inputDic setValue:phone forKey:PARA_PHONE_ENCODE];
        [inputDic setValue:coachId forKey:PARA_COACH_ID];
        [inputDic setValue:goodsId forKey:PARA_GOODS_IDS];
        [inputDic setValue:address forKey:PARA_ADDRESS];
        [inputDic setValue:[NSString stringWithFormat:@"%d", (int)[startTime timeIntervalSince1970]] forKey:PARA_START_TIME];

        [inputDic setValue:[@(orderType) stringValue]forKey:PARA_ORDER_TYPE];
        [inputDic setValue:activityId forKey:PARA_ACT_ID];
        [inputDic setValue:couponId forKey:PARA_COUPON_ID];
        [inputDic setValue:cityId forKey:PARA_CITY_ID];
        [inputDic setValue:[@(voucherType) stringValue] forKey:PARA_TICKET_TYPE];
    
        [inputDic setValue:@"2.0" forKey:PARA_VER];
    
        [GSNetwork getWithBasicUrlString:GS_URL_ORDER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
            NSDictionary *resultDictionary = response.jsonResult;

            NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
            NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
            Order *order = nil;
            NSString *cancelOrderMsg = nil;
            if ([status isEqualToString:STATUS_SUCCESS]) {
                NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
                order = [OrderService orderByOneOrderDictionary:data];
                cancelOrderMsg = [data validStringValueForKey:PARA_CANCEL_ORDER_MSG];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([delegate respondsToSelector:@selector(didAddCoachOrder:msg:order:cancelOrderMsg:)]) {
                    [delegate didAddCoachOrder:status msg:msg order:order cancelOrderMsg:cancelOrderMsg];
                }
            });
        }];
}
//取消教练预约
+ (void)cancelCoachBespeak:(id<CoachServiceDelegate>)delegate
                    userId:(NSString *)userId
                   orderId:(NSString *)orderId
                  reasonId:(NSString *)reasonId
{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_CANCEL_BESPEAK forKey:PARA_ACTION];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        [inputDic setValue:orderId forKey:PARA_ORDER_ID];
        [inputDic setValue:reasonId forKey:PARA_REASON_ID];
        [inputDic setValue:@"2.0" forKey:PARA_VER];
    [GSNetwork getWithBasicUrlString:GS_URL_COACH parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
     
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        if ([status isEqualToString:STATUS_SUCCESS]) {
            NSDictionary *dic = @{@"order_id":orderId};
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_CANCEL_COACH_ORDER object:nil userInfo:dic];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didCancelCoachBooking:msg:)]) {
                [delegate didCancelCoachBooking:status msg:msg];
            }
        });
    }];

}

// 取消预约原因
+ (void)getCoachCancelReason:(id<CoachServiceDelegate>)delegate
                    userId:(NSString *)userId
{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_CANCEL_CAUSE forKey:PARA_ACTION];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        
    [GSNetwork getWithBasicUrlString:GS_URL_COACH parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
       
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSArray *causeListSource = [resultDictionary validArrayValueForKey:PARA_DATA];
        NSMutableArray *causeListTarget = [NSMutableArray array];
        
        for (id oneCauseSource in causeListSource) {
            if ([oneCauseSource isKindOfClass:[NSDictionary class]] == NO) {
                continue;
            }
            
            CoachCancelReason *cancelTarget = [[CoachCancelReason alloc]init];
            cancelTarget.reasonId = [oneCauseSource validStringValueForKey:PARA_REASON_ID];
            cancelTarget.reasonDesc = [oneCauseSource validStringValueForKey:PARA_REASON_DESC];

            [causeListTarget addObject:cancelTarget];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didGetCoachCancelReason:status:msg:)]) {
                [delegate didGetCoachCancelReason:causeListTarget status:status msg:msg];
            }
        });
    }];
}

//确认预约
+ (void)confirmService:(id<CoachServiceDelegate>)delegate
                    userId:(NSString *)userId
                   orderId:(NSString *)orderId
{
    
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_CONFIRM_SERVICE forKey:PARA_ACTION];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        [inputDic setValue:orderId forKey:PARA_ORDER_ID];
    [GSNetwork getWithBasicUrlString:GS_URL_COACH parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;

        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        if ([status isEqualToString:STATUS_SUCCESS]) {
            NSDictionary *dic = @{@"order_id":orderId};
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_FINISH_COACH_ORDER object:nil userInfo:dic];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didConfirmService:msg:)]) {
                [delegate didConfirmService:status msg:msg];
            }
        });
    }];
}

+ (void)getCoachCommentList:(id<CoachServiceDelegate>)delegate
                    coachId:(NSString *)coachId
                       page:(NSUInteger)page
                      count:(NSUInteger)count
{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_GET_COACH_COMMENT_LIST forKey:PARA_ACTION];
        [inputDic setValue:coachId forKey:PARA_COACH_ID];
        [inputDic setValue:[@(page) stringValue] forKey:PARA_PAGE];
        [inputDic setValue:[@(count) stringValue] forKey:PARA_COUNT];
        [inputDic setValue:@"2.0" forKey:PARA_VER];
    [GSNetwork getWithBasicUrlString:GS_URL_COACH parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
     
        //parse
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSMutableArray *commentList = nil;
        if ([status isEqualToString:STATUS_SUCCESS]) {
            commentList = [NSMutableArray array];
            NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
            for (NSDictionary *one in [data validArrayValueForKey:PARA_LIST]) {
                if (![one isKindOfClass:[NSDictionary class]]){
                    continue;
                }
                Comment *comment = [CoachService commentWithDictionary:one];
                [commentList addObject:comment];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didGetCoachCommentList:page:status:msg:)]) {
                [delegate didGetCoachCommentList:commentList page:page status:status msg:msg];
            }
        });
    }];
    
}

+ (void)sendCoachComplain:(id<CoachServiceDelegate>)delegate
                  coachId:(NSString *)coachId
                  content:(NSString *)content
                   userId:(NSString *)userId
                  orderId:(NSString *)orderId
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_ADD_COACH_COMPLAIN forKey:PARA_ACTION];
    [inputDic setValue:coachId forKey:PARA_COACH_ID];
    [inputDic setValue:content forKey:PARA_CONTENT];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:orderId forKey:PARA_ORDER_ID];
    
    [GSNetwork getWithBasicUrlString:GS_URL_COACH parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        
        //parse
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didSendCoachComplain:msg:)]) {
                [delegate didSendCoachComplain:status msg:msg];
            }
        });
    }];

    
}


+ (void)queryFavoriteCoachList:(id<CoachServiceDelegate>)delegate userId:(NSString *)userId {
    
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_MY_COLLECTING_COACH forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [GSNetwork getWithBasicUrlString:GS_URL_COACH parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
     
        //parse
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        NSMutableArray *tempArray = [NSMutableArray array];
        for (NSDictionary *dict in [resultDictionary validArrayValueForKey:PARA_DATA]) {
            Coach *coach = [CoachService coachByOneCoachDictionary:dict];
            [tempArray addObject:coach];
        }
        NSArray *coachList = tempArray;

        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didQueryFavoriteCoachList:msg:coachList:)]) {
                [delegate didQueryFavoriteCoachList:status msg:msg coachList:coachList];
            }
        });
    }];
    
}

+ (Coach *)coachByOneCoachDictionary:(NSDictionary *)coachDictionary
{
    Coach *coach = [[Coach alloc] init] ;
    coach.coachId = [coachDictionary validStringValueForKey:PARA_COACH_ID];
    coach.name = [coachDictionary validStringValueForKey:PARA_COACH_NAME];
    coach.imageUrl = [coachDictionary validStringValueForKey:PARA_COACH_IMG];
    coach.avatarUrl = [coachDictionary validStringValueForKey:PARA_AVATAR];
    coach.avatarOriginalUrl = [coachDictionary validStringValueForKey:PARA_AVATAR_ORIGINAL];
    coach.gender = [coachDictionary validStringValueForKey:PARA_GENDER];
    coach.price = [coachDictionary validStringValueForKey:PARA_CATEGORY_PRICE];
    coach.latitude = [coachDictionary validDoubleValueForKey:PARA_LATITUDE];
    coach.longitude = [coachDictionary validDoubleValueForKey:PARA_LONGITUDE];
    coach.age = [coachDictionary validIntValueForKey:PARA_AGE];
    coach.height = [coachDictionary validIntValueForKey:PARA_HEIGHT];
    coach.weight = [coachDictionary validIntValueForKey:PARA_WEIGHT];
    coach.rongId = [coachDictionary validStringValueForKey:PARA_COACH_RONG_ID];
    coach.oftenArea = [coachDictionary validStringValueForKey:PARA_OFTEN_AREA];
    coach.introduction = [coachDictionary validStringValueForKey:PARA_INTRODUCE];
    coach.studentCount = [coachDictionary validIntValueForKey:PARA_STUDENT_COUNT];
    coach.totalTime = [coachDictionary validIntValueForKey:PARA_TOTOAL_TIME];
    coach.rate = [coachDictionary validFloatValueForKey:PARA_COMMENT_AVG];
    coach.commentCount = [coachDictionary validIntValueForKey:PARA_COMMENT_COUNT];
    coach.collectNumber = [coachDictionary validIntValueForKey:PARA_COLLECT_NUMBER];
    coach.coachShareUrl = [coachDictionary validStringValueForKey:PARA_GAM_URL];
    int intIsCollect = [coachDictionary validIntValueForKey:PARA_IS_COLLECT];
    coach.isCollect = (intIsCollect != 0);
    coach.isShow = [coachDictionary validStringValueForKey:PARA_IS_SHOW];
    coach.levelStatus = [coachDictionary validIntValueForKey:PARA_LEVEL];
    coach.levelDesc = [coachDictionary validStringValueForKey:PARA_LEVEL_DESC];
    
    NSMutableArray *serviceAreaList = nil;
    NSArray *sourceServiceAreaList = [coachDictionary validArrayValueForKey:PARA_SERVICE_AREA_LIST];
    if ([sourceServiceAreaList count] > 0) {
        serviceAreaList = [NSMutableArray array];
        for (NSDictionary *one in sourceServiceAreaList) {
            CoachServiceArea *area = [[CoachServiceArea alloc] init] ;
            area.regionId = [one validStringValueForKey:PARA_REGION_ID];
            area.regionName = [one validStringValueForKey:PARA_REGION_NAME];
            [serviceAreaList addObject:area];
        }
    }
    coach.serviceAreaList = serviceAreaList;
    
    NSMutableArray *categoryList = nil;
    NSArray *sourceCategoryList = [coachDictionary validArrayValueForKey:PARA_CATEGORY_LIST];
    if ([sourceCategoryList count] > 0) {
        categoryList = [NSMutableArray array];
        for (NSDictionary *categorySource in sourceCategoryList) {
            BusinessCategory *category = [[BusinessCategory alloc] init] ;
            category.businessCategoryId = [categorySource validStringValueForKey:PARA_CAT_ID];
            category.name = [categorySource validStringValueForKey:PARA_CAT_NAME];
            category.imageUrl = [categorySource validStringValueForKey:PARA_IMG_URL];
            [categoryList addObject:category];
        }
    }
    coach.categoryList = categoryList;
    
    NSMutableArray *photoList = nil;
    NSArray *sourcePhotoList = [coachDictionary validArrayValueForKey:PARA_GALLERY];
    if ([sourcePhotoList count] > 0) {
        photoList = [NSMutableArray array];
        for (NSDictionary *one in sourcePhotoList) {
            CoachPhoto *photo = [[CoachPhoto alloc] init] ;
            photo.photoUrl = [one validStringValueForKey:PARA_IMAGE_URL];
            photo.thumbUrl = [one validStringValueForKey:PARA_THUMB_URL];
            [photoList addObject:photo];
        }
    }
    coach.photoList = photoList;
    
    NSMutableArray *commentList = nil;
    NSArray *sourceCommentList = [coachDictionary validArrayValueForKey:PARA_COMMENT_LIST];
    if ([sourceCommentList count] > 0) {
        commentList = [NSMutableArray array];
        for (NSDictionary *one in sourceCommentList) {
            Comment *comment = [CoachService commentWithDictionary:one];
            [commentList addObject:comment];
        }
    }
    coach.commentList = commentList;
    
    NSMutableArray *sportExperienceList = nil;
    NSArray *sourceSportExperienceList = [coachDictionary validArrayValueForKey:PARA_SPORT_EXPERIENCE];
    if ([sourceSportExperienceList count] > 0) {
        sportExperienceList = [NSMutableArray array];
        for (NSDictionary *one in sourceSportExperienceList) {
            CoachSportExperience *experience = [[CoachSportExperience alloc]init];
            experience.experienceId = [one validStringValueForKey:PARA_ID];
            experience.coachId = [one validStringValueForKey:PARA_COACH_ID];
            experience.experienceContent = [one validStringValueForKey:PARA_EXPERIENCE_CONTENT];
            experience.startTime = [one validDateValueForKey:PARA_START_TIME];
            experience.endTime = [one validDateValueForKey:PARA_END_TIME];
            [sportExperienceList addObject:experience];
        }
    }
    coach.sportExperienceList = sportExperienceList;
    
    NSMutableArray *coachProjectsList = nil;
    NSArray *sourceCoachProjectsList = [coachDictionary validArrayValueForKey:PARA_COACH_PROJECTS];
    if ([sourceCoachProjectsList count] > 0) {
        coachProjectsList = [NSMutableArray array];
        for (NSDictionary *one in sourceCoachProjectsList) {
            CoachProjects *project = [[CoachProjects alloc]init];
            project.goodsId = [one validStringValueForKey:PARA_GOODS_ID];
            project.coachId = [one validStringValueForKey:PARA_COACH_ID];
            project.categoryId = [one validStringValueForKey:PARA_CAT_ID];
            project.projectName = [one validStringValueForKey:PARA_PROJECT_NAME];
            project.roleId = [one validStringValueForKey:PARA_ROLE_ID];
            project.minutes = [one validIntValueForKey:PARA_MINUTES];
            project.addTime = [one validDateValueForKey:PARA_ADD_TIME];
            project.price = [one validIntValueForKey:PARA_PRICE];
            [coachProjectsList addObject:project];
        }
    }
    coach.coachProjectsList = coachProjectsList;
    
    NSMutableArray *oftenAreaList = nil;
    NSArray *sourceOftenAreaList = [coachDictionary validArrayValueForKey:PARA_OFTEN_AREA_LIST];
    if ([sourceOftenAreaList count] > 0) {
        oftenAreaList = [NSMutableArray array];
        for (NSDictionary *one in sourceOftenAreaList) {
            CoachOftenArea *area = [[CoachOftenArea alloc]init];
            area.businessId = [one validStringValueForKey:PARA_BUSINESS_ID];
            area.businessName = [one validStringValueForKey:PARA_NAME];
            area.addressName = [one validStringValueForKey:PARA_ADDRESS];
            
            [oftenAreaList addObject:area];
        }
    }
    
    coach.oftenAreaList = oftenAreaList;
    
    return coach;
}

+ (Comment *)commentWithDictionary:(NSDictionary *)dictionary
{
    Comment *comment = [[Comment alloc] init] ;
    comment.userName = [dictionary validStringValueForKey:PARA_USER_NAME];
    comment.userId = [dictionary validStringValueForKey:PARA_USER_ID];
    comment.addTime = [NSDate dateWithTimeIntervalSince1970:[dictionary validIntValueForKey:PARA_ADD_TIME]];
    comment.orderId = [dictionary validStringValueForKey:PARA_ORDER_ID];
    //comment.commentId = [dictionary validStringValueForKey:PARA_COM_ID];
    comment.content = [dictionary validStringValueForKey:PARA_CONTENT];
    comment.commentRank = [dictionary validStringValueForKey:PARA_RANK];
    NSArray *commentImageList = [dictionary validArrayValueForKey:PARA_IMAGE_LIST];
    NSMutableArray *mutablePhoto = [NSMutableArray array];
    for (NSDictionary *imgDic in commentImageList) {
        PostPhoto *photo = [[PostPhoto alloc]init];
        photo.photoThumbUrl= [imgDic valueForKey:PARA_THUMB_URL];
        photo.photoImageUrl = [imgDic valueForKey:PARA_IMAGE_URL];
        [mutablePhoto addObject:photo];
    }
    comment.photoList = mutablePhoto;
    return comment;
}

+ (CoachBookingInfo *)infoByOneBookingInfoDictionary:(NSDictionary *)infoDictionary
{
    CoachBookingInfo *info = [[CoachBookingInfo alloc] init];
    info.weekDate = [infoDictionary validDateValueForKey:PARA_DATE];
    info.morningState = [infoDictionary validBoolValueForKey:PARA_MORNING];
    info.afternoonState = [infoDictionary validBoolValueForKey:PARA_AFTERNOON];
    info.nightState = [infoDictionary validBoolValueForKey:PARA_NIGHT];
    
    return info;
}

+ (void)userCollectionCoach:(id<CoachServiceDelegate>)delegate
                     userId:(NSString *)userId
                    coachId:(NSString *)coachId
                       type:(int)type
{
    
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_USER_COLLECTION_COACH forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:coachId forKey:PARA_COACH_ID];
    [inputDic setValue:[NSString stringWithFormat:@"%d",type] forKey:PARA_TYPE];
        
    [GSNetwork getWithBasicUrlString:GS_URL_COACH parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
       
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didUserCollectionCoach:msg:)]) {
                [delegate didUserCollectionCoach:status msg:msg];
            }
        });
    }];
}

@end
