//
//  OrderService.m
//  Sport
//
//  Created by haodong  on 13-7-22.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "OrderService.h"
#import "Order.h"
#import "Product.h"
#import "OrderManager.h"
#import "DesUtil.h"
#import "TipNumberManager.h"
#import "FavourableActivity.h"
#import "RefundWay.h"
#import "RefundCause.h"
#import "BaseConfigManager.h"
#import "PayMethod.h"
#import "MembershipCard.h"
#import "Insurance.h"
#import "GSNetwork.h"
#import "CourtJoinService.h"
#import "BusinessGoods.h"
#import "QrCode.h"
#import "MembershipCardService.h"

@implementation OrderService

+ (Order *)orderInOrderListrDictionary:(NSDictionary *)orderDictionary
{
    Order *order = [[Order alloc] init] ;
    order.orderId = [orderDictionary validStringValueForKey:PARA_ORDER_ID];
    order.title = [orderDictionary validStringValueForKey:PARA_ORDER_TITLE];
    order.amount = [orderDictionary validDoubleValueForKey:PARA_ORDER_AMOUNT];
    order.iconURL = [orderDictionary validStringValueForKey:PARA_ORDER_ICON];
    order.type = [orderDictionary validIntValueForKey:PARA_ORDER_TYPE];
    order.consumeCode = [orderDictionary validStringValueForKey:PARA_VERIFICATION_CODE];
    order.status = [orderDictionary validIntValueForKey:PARA_ORDER_STATUS];
    order.createDate = [orderDictionary validDateValueForKey:PARA_ADD_TIME];
    order.useDate = [orderDictionary validDateValueForKey:PARA_BOOK_DATE];
    order.fieldNo = [orderDictionary validStringValueForKey:PARA_COURT_NUMBER];
    order.timeRange = [orderDictionary validIntValueForKey:PARA_TIME_RANGE];
    order.detailUrl = [orderDictionary validStringValueForKey:PARA_DETAIL_URL];
    order.startTime = [orderDictionary validDateValueForKey:PARA_START_TIME];
    order.isCoachCanCancel = [orderDictionary validBoolValueForKey:PARA_IS_CAN_CANCEL];
    order.coachStatus = [orderDictionary validIntValueForKey:PARA_SHOW_STATUS];
    order.isClubPay = [orderDictionary validBoolValueForKey:PARA_USE_CLUB_PAY];
    order.commentStatus = [orderDictionary validIntValueForKey:PARA_COMMENT_STATUS];
    order.coachStartTime = [orderDictionary validDateValueForKey:PARA_START_TIME];
    order.courseStartTime = [orderDictionary validDateValueForKey:PARA_START_TIME];
    order.businessId = [orderDictionary validStringValueForKey:PARA_VENUES_ID];
    order.categoryId = [orderDictionary validStringValueForKey:PARA_CAT_ID];
    
    order.shareUrl = [orderDictionary validStringValueForKey:PARA_SHARE_URL];
    order.logoUrl = [orderDictionary validStringValueForKey:PARA_LOGO_URL];
    
    
    order.coachId = [orderDictionary validStringValueForKey:PARA_COACH_ID];
    order.canRefund = [orderDictionary validIntValueForKey:PARA_IS_REFUND];
    order.refundStatus = [orderDictionary validIntValueForKey:PARA_REFUND_STATUS];
    
    order.isCourtJoinParent = [orderDictionary validBoolValueForKey:PARA_IS_COURT_JOIN_PARENT];
    order.cardAmount = [orderDictionary validFloatValueForKey:PARA_CARD_AMOUNT];
    return order;
}

+ (Order *)orderByOneOrderDictionary:(NSDictionary *)orderDictionary
{
    Order *order = [[Order alloc] init];
    
    order.startTime = [orderDictionary validDateValueForKey:PARA_START_TIME];
    order.shareInfo = [orderDictionary validDictionaryValueForKey:PARA_SHARE_INFO];
    order.surveySwitchFlag = [orderDictionary validIntValueForKey:PARA_ADD_SURVEY_SWITCH];
    order.orderId = [orderDictionary validStringValueForKey:PARA_ORDER_ID];
    order.amount = [orderDictionary validDoubleValueForKey:PARA_ORDER_AMOUNT];
    order.totalAmount = [orderDictionary validDoubleValueForKey:PARA_TOTAL_AMOUNT];
    order.cardAmount = [orderDictionary validDoubleValueForKey:PARA_CARD_AMOUNT];
    order.promoteAmount = [orderDictionary validDoubleValueForKey:PARA_ORDER_PROMOTE];
    order.promotionAmount = [orderDictionary validDoubleValueForKey:PARA_ORDER_PROMOTION];
    order.orderNumber = [orderDictionary validStringValueForKey:PARA_ORDER_SN];
    order.consumeCode = [orderDictionary validStringValueForKey:PARA_VERIFICATION_CODE];
    order.status = [orderDictionary validIntValueForKey:PARA_ORDER_STATUS];
    order.createDate = [NSDate dateWithTimeIntervalSince1970:[orderDictionary validIntValueForKey:PARA_ADD_TIME]];
    order.businessName =  [orderDictionary validStringValueForKey:PARA_NAME];
    order.businessAddress =  [orderDictionary validStringValueForKey:PARA_ADDRESS];
    order.businessPhone = [orderDictionary validStringValueForKey:PARA_VENUES_TELEPHONE];
    order.categoryName =  [orderDictionary validStringValueForKey:PARA_CATEGORY_NAME];
    NSDate *useDate = nil;
    id goodsListSource = [orderDictionary validArrayValueForKey:PARA_GOODS_LIST];
    NSMutableArray *goodsListTarget = [NSMutableArray array];
    if ([goodsListSource isKindOfClass:[NSArray class]]) {
        for (id goodsSource in goodsListSource) {
            if ([goodsSource isKindOfClass:[NSDictionary class]] == NO) {
                continue;
            }
            
            Product *goodsTartet = [[Product alloc] init];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"H:mm"];
            NSDate *startTime = [goodsSource validDateValueForKey:PARA_START_TIME];
            
            goodsTartet.startTime = [formatter stringFromDate:startTime];
            goodsTartet.price = [goodsSource validFloatValueForKey:PARA_SHOP_PRICE];
            goodsTartet.courtJoinPrice = [goodsSource validFloatValueForKey:PARA_COURT_JOIN_PRICE];
            goodsTartet.courtName = [goodsSource validStringValueForKey:PARA_COURT_NAME];
            [goodsListTarget addObject:goodsTartet];
            
            if (useDate == nil) {
                NSString *useDateString = [goodsSource validStringValueForKey:PARA_BOOK_DATE];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                useDate = [dateFormatter dateFromString:useDateString];
            }
        }
    }
    order.useDate = useDate;
    order.productList = goodsListTarget;
    order.alipayNotifyUrlString = [orderDictionary validStringValueForKey:PARA_ALIPAY_NOTIFY_URL];
    order.weixinNotifyUrlString = [orderDictionary validStringValueForKey:PARA_WEIXIN_NOTIFY_URL];
    order.shareUrl = [orderDictionary validStringValueForKey:PARA_SHARE_URL];
    order.voucherId = [orderDictionary validStringValueForKey:PARA_COUPON_ID];
    order.voucherAmount = [orderDictionary validDoubleValueForKey:PARA_COUPON_AMOUNT];
    
    order.businessId = [orderDictionary validStringValueForKey:PARA_VENUES_ID];
    order.categoryId = [orderDictionary validStringValueForKey:PARA_CAT_ID];
    
    int isShare = [orderDictionary validIntValueForKey:PARA_IS_SHARE];
    order.isShareGiveVoucher = (isShare != 0);
    
    order.shareMessage = [orderDictionary validStringValueForKey:PARA_SHARE_MSG];
    order.givePoint = [orderDictionary validIntValueForKey:PARA_CREDIT];
    
    order.type = [orderDictionary validIntValueForKey:PARA_ORDER_TYPE];
    if (order.type == OrderTypeSingle
        || order.type == OrderTypePackage
        || order.type == OrderTypeMonthCardRecharge
        || order.type == OrderTypeCourse) { //人次，特惠，月卡、课程订单
        order.useDescription = [orderDictionary validStringValueForKey:PARA_DESCRIPTION];
        if ([goodsListSource isKindOfClass:[NSArray class]]) {
            NSArray *list = (NSArray *)goodsListSource;
            if ([list count] > 0) {
                NSDictionary *oneGoods = [list objectAtIndex:0];
                order.count = [oneGoods validIntValueForKey:PARA_GOODS_NUMBER];
                order.goodsName = [oneGoods validStringValueForKey:PARA_GOODS_NAME];
                order.singlePrice = [oneGoods validDoubleValueForKey:PARA_SHOP_PRICE];
                order.courseStartTime = [oneGoods validDateValueForKey:PARA_START_TIME];
                order.courseEndTime = [oneGoods validDateValueForKey:PARA_END_TIME];
            }
        }
    }
    
    order.canWriteReview = ([orderDictionary validIntValueForKey:PARA_IS_COMMENT] != 0);
    
    order.selectedFavourableActivityId = [orderDictionary validStringValueForKey:PARA_ACT_ID];
    
    NSMutableArray *activityListTarget = [NSMutableArray array];
    id activityListSource = [orderDictionary validArrayValueForKey:PARA_ACTIVITY_LIST];
    if ([activityListSource isKindOfClass:[NSArray class]]) {
        for (id oneActivitySource in (NSArray *)activityListSource) {
            if ([oneActivitySource isKindOfClass:[NSDictionary class]] == NO) {
                continue;
            }
            
            FavourableActivity *activity = [[FavourableActivity alloc] init] ;
            activity.activityId = [oneActivitySource validStringValueForKey:PARA_ACT_ID];
            activity.activityName = [oneActivitySource validStringValueForKey:PARA_ACT_NAME];
            activity.activityStatus = [oneActivitySource validIntValueForKey:PARA_STATUS];
            activity.activityPrice = [oneActivitySource validFloatValueForKey:PARA_ACT_AMOUNT];
            activity.activityType= [oneActivitySource validIntValueForKey:PARA_TYPE];
            
            if ([order.selectedFavourableActivityId isEqualToString:activity.activityId]) {
                activity.activityInviteCode = [orderDictionary validStringValueForKey:PARA_INVITE_CODE];
            }
            
            [activityListTarget addObject:activity];
        }
    }
    
    order.favourableActivityList = activityListTarget;
    
    order.detailUrl = [orderDictionary validStringValueForKey:PARA_DETAIL_URL];
    
    order.canRefund = [orderDictionary validIntValueForKey:PARA_IS_REFUND];
    order.refundStatus = [orderDictionary validIntValueForKey:PARA_REFUND_STATUS];
    
    order.money = [orderDictionary validFloatValueForKey:PARA_USER_MONEY];
    
    order.latitude = [orderDictionary validDoubleValueForKey:PARA_LATITUDE];
    order.longitude = [orderDictionary validDoubleValueForKey:PARA_LONGITUDE];
    
    order.userBalance = [orderDictionary validDoubleValueForKey:PARA_USER_BALANCE];
    
    NSDictionary *cardInfo = [orderDictionary validDictionaryValueForKey:PARA_USER_CARD_INFO];
    
    order.cardNumber = [cardInfo validStringValueForKey:PARA_CARD_NO];
    order.cardBalance = [cardInfo validStringValueForKey:PARA_BALANCE];
    order.cardPhone = [cardInfo validStringValueForKey:PARA_CARD_MOBILE_PHONE];
    order.cardHolder = [cardInfo validStringValueForKey:PARA_CARDHOLDER];
    
    order.lastRefundTime = [NSDate dateWithTimeIntervalSince1970:[orderDictionary validIntValueForKey:PARA_LAST_REFUND_TIME]];;
    
    order.coachId = [orderDictionary validStringValueForKey:PARA_COACH_ID];
    order.coachName = [orderDictionary validStringValueForKey:PARA_COACH_NAME];
    order.coachAvatarUrl = [orderDictionary validStringValueForKey:PARA_COACH_AVATAR];
    order.isCoachAudit = [orderDictionary validBoolValueForKey:PARA_COACH_IS_AUDIT];
    order.coachGender = [orderDictionary validStringValueForKey:PARA_COACH_GENDER];
    order.coachStartTime = [orderDictionary validDateValueForKey:PARA_START_TIME];
    order.isCoachCanCancel = [orderDictionary validBoolValueForKey:PARA_IS_CAN_CANCEL];
    order.coachStatus = [orderDictionary validIntValueForKey:PARA_SHOW_STATUS];
    order.coachPhone = [orderDictionary validStringValueForKey:PARA_COACH_PHONE];
    order.coachAge = [orderDictionary validIntValueForKey:PARA_COACH_AGE];
    order.coachHeight = [orderDictionary validIntValueForKey:PARA_COACH_HEIGHT];
    order.coachWeight = [orderDictionary validIntValueForKey:PARA_COACH_WEIGHT];
    order.coachDuration = [orderDictionary validIntValueForKey:PARA_DURATION];
    order.coachEndTime = [orderDictionary validDateValueForKey:PARA_END_TIME];
    order.coachCategory = [orderDictionary validStringValueForKey:PARA_CATEGORY_NAME];
    order.coachAddress = [orderDictionary validStringValueForKey:PARA_ADDRESS];
    order.complainedStatus = [orderDictionary validIntValueForKey:PARA_COMPLAIN_STATUS];
    order.commentStatus = [orderDictionary validIntValueForKey:PARA_COMMENT_STATUS];
    order.isClubPay = [orderDictionary validBoolValueForKey:PARA_USE_CLUB_PAY];
    order.orderName = [orderDictionary validStringValueForKey:PARA_ORDER_NAME];
    order.payMethodName = [orderDictionary validStringValueForKey:PARA_FORMAT_PAY_NAME];
    
    order.shareBtnMsg=[orderDictionary validStringValueForKey:PARA_SHARE_BTN_MSG];
    order.clubEndTime=[orderDictionary validStringValueForKey:PARA_CLUB_END_TIME];
    order.refundUrl = [orderDictionary validStringValueForKey:PARA_COACH_REFUND];

    NSArray *payMethodDicListSource = [orderDictionary validArrayValueForKey:PARA_PAYMENT_METHOD_PAYID_V2];
    NSMutableArray * payMethodList = [NSMutableArray array];
    for (NSDictionary *one in payMethodDicListSource) {
        NSString *payId = [one validStringValueForKey:PARA_PAY_ID];
        NSString *payKey = [one validStringValueForKey:PARA_NAME];
        BOOL isRecommend = [one validBoolValueForKey:PARA_IS_RECOMMEND];
        if ([@[PAY_METHOD_WEIXIN,PAY_METHOD_ALIPAY_CLIENT,PAY_METHOD_ALIPAY_WAP,PAY_METHOD_UNION_CLIENT,PAY_METHOD_APPLE_PAY] containsObject:payKey]) {
            PayMethod *method = [[PayMethod alloc] init] ;
            method.payId = payId;
            method.payKey = payKey;
            method.isRecommend = isRecommend;
            [payMethodList addObject:method];
        }
    }
    
    order.payMethodList = payMethodList;
    
    order.monthRefundTimes = [orderDictionary validIntValueForKey:PARA_MONTH_REFUND_TIMES];
    
    order.courtJoin = [CourtJoinService courtJoinByOneCourtJoinDictionary:orderDictionary];
    order.isCourtJoinParent = [orderDictionary validBoolValueForKey:PARA_IS_COURT_JOIN_PARENT];
    
    //保险
    order.insuranceContent = [orderDictionary validStringValueForKey:PARA_INSURANCE_CONTENT];
    order.insuranceUrl = [orderDictionary validStringValueForKey:PARA_INSURANCE_URL];
    order.insurancePayTips = [orderDictionary validStringValueForKey:PARA_INSURANCE_PAY_TIPS];
    
    order.payExpireLeftTime = [orderDictionary validIntValueForKey:PARA_PAY_EXPIRE_LEFT];
    
    order.payToken = [orderDictionary validStringValueForKey:PARA_PAY_TOKEN];
    
    NSArray *goodsSourceList = [orderDictionary validArrayValueForKey:PARA_SALE_LIST];
    NSMutableArray *goodsList = [NSMutableArray array];
    for (NSDictionary *one in goodsSourceList) {
        if (![one isKindOfClass:[NSDictionary class]]){
            continue;
        }
        
        BusinessGoods *goods = [[BusinessGoods alloc]init];
        goods.name = [one validStringValueForKey:PARA_NAME];
        goods.totalCount = [one validIntValueForKey:PARA_NUM];
        goods.price = [one validDoubleValueForKey:PARA_PRICE];
        
        [goodsList addObject:goods];
    }
    
    order.goodsList = goodsList;
    
    NSArray *codeSourceList = [orderDictionary validArrayValueForKey:PARA_QR_CODE_LIST];
    NSMutableArray *codeList = [NSMutableArray array];
    for (NSDictionary *one in codeSourceList) {
        if (![one isKindOfClass:[NSDictionary class]]){
            continue;
        }
        
        QrCode *code = [[QrCode alloc]init];
        code.code = [one validStringValueForKey:PARA_QR_CODE];
        code.status = [one validIntValueForKey:PARA_QR_STATUS];
        code.usedTime = [one validDateValueForKey:PARA_QR_TIME];
        [codeList addObject:code];
    }
    
    order.qrCodeList = codeList;
    if([codeList count] > 0) {
        order.consumeCode = [(QrCode *)codeList[0] code];
    }
    
    return order;
}

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
           saleList:(NSString *)saleList
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_INSERT_ORDER forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:goodsIdList forKey:PARA_GOODS_IDS];
    [inputDic setValue:@"2" forKey:PARA_FROM];
    
    //2014-06-23版本号1.1，由于更改支付宝账户
    //2014-12-22版本号1.2，由于添加了优惠活动id
    //2015-01-28版本号1.3，由于添加了代金券id
    //2015-11-05版本号1.4，增加会员卡卡号
    //2016-06-15版本号2.0,
    //2016-08-11版本号2.1,人次商品支持多验证码
    [inputDic setValue:@"2.1" forKey:PARA_VER];
    
    [inputDic setValue:[NSString stringWithFormat:@"%d", type] forKey:PARA_ORDER_TYPE];
    [inputDic setValue:activityId forKey:PARA_ACT_ID];
    [inputDic setValue:inviteCode forKey:PARA_INVITE_CODE];
    [inputDic setValue:voucherId forKey:PARA_COUPON_ID];
    [inputDic setValue:[@(voucherType) stringValue] forKey:PARA_TICKET_TYPE];
    [inputDic setValue:phone forKey:PARA_PHONE_ENCODE];
    
    if (count > 0) {
        [inputDic setValue:[@(count) stringValue] forKey:PARA_GOODS_NUMBER];
    }
    
    [inputDic setValue:[@(isClubPay) stringValue] forKey:PARA_USE_CLUB_PAY];
    [inputDic setValue:cityId forKey:PARA_CITY_ID];
    [inputDic setValue:cardNumber forKey:PARA_CARD_NO];
    [inputDic setValue:insuranceId forKey:PARA_INSURANCE_ID];
    if (insuranceQuantity > 0) {
        [inputDic setValue:[@(insuranceQuantity) stringValue] forKey:PARA_INSURANCE_QUANTITY];
    }
    
    if ([saleList length] > 0) {
        [inputDic setValue:saleList forKey:PARA_SALE_LIST];
    }
    [GSNetwork getWithBasicUrlString:GS_URL_ORDER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];

        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        Order *order = [OrderService orderByOneOrderDictionary:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didSubmitOrder:resultOrder:msg:)]) {
                [delegate didSubmitOrder:status resultOrder:order msg:msg];
            }
        });
    }];
}

+ (void)submitOrderByCourtPool:(id<OrderServiceDelegate>)delegate
             userId:(NSString *)userId
        courtPoolId:(NSString *)poolId
               type:(int)type
              phone:(NSString *)phone
            level:(NSString *)levelId
{
    //send
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_INSERT_ORDER forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:@"2" forKey:PARA_FROM];
    
    //2014-06-23版本号1.1，由于更改支付宝账户
    //2014-12-22版本号1.2，由于添加了优惠活动id
    //2015-01-28版本号1.3，由于添加了代金券id
    //2015-11-05版本号1.4，增加会员卡卡号
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    
    [inputDic setValue:[NSString stringWithFormat:@"%d", type] forKey:PARA_ORDER_TYPE];

    [inputDic setValue:phone forKey:PARA_PHONE_ENCODE];
    [inputDic setValue:poolId forKey:PARA_COURT_POOL_ID];
    [inputDic setValue:levelId forKey:PARA_CP_LEVEL];
    [GSNetwork getWithBasicUrlString:GS_URL_ORDER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        Order *order = nil;
        NSString *cancelOrderMsg = nil;
        if ([status isEqualToString:STATUS_SUCCESS]) {
            order = [OrderService orderByOneOrderDictionary:resultDictionary];
            cancelOrderMsg = [resultDictionary validStringValueForKey:PARA_CANCEL_ORDER_MSG];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didSubmitOrder:resultOrder:msg:cancelOrderMsg:)]) {
                [delegate didSubmitOrder:status resultOrder:order msg:msg cancelOrderMsg:cancelOrderMsg];
            }
        });
    }];
}

+ (void)queryOrderDetail:(id<OrderServiceDelegate>)delegate
                 orderId:(NSString *)orderId
                  userId:(NSString *)userId
                 isShare:(NSString *)isShare
                 entrance:(int)entrance
{
        //send
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_ORDER_INFO forKey:PARA_ACTION];
    [inputDic setValue:orderId forKey:PARA_ORDER_ID];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    
    //2014-06-23版本号1.1，由于更改支付宝账户
    //2014-12-22版本号1.2，由于添加了优惠活动id
    //2015-10-20版本号1.4，refundStatus增加10 (30天内已经退款N次)
    //                                   11 (已经过了最后退款时间)
    //[inputDic setValue:@"1.1" forKey:PARA_VER];
    //[inputDic setValue:@"1.2" forKey:PARA_VER];
    [inputDic setValue:@"1.4" forKey:PARA_VER];
    [inputDic setValue:[@(1) stringValue] forKey:PARA_GET_PAY_ID];
    [inputDic setValue:isShare forKey:PARA_SHARE_TO];
    [inputDic setValue:[@(entrance) stringValue] forKey:PARA_ENTRANCE]; // 0 详情 1 支付成功
    
    [GSNetwork getWithBasicUrlString:GS_URL_ORDER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        //parse
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        Order *order = nil;
        if ([status isEqualToString:STATUS_SUCCESS]) {
            order = [OrderService orderByOneOrderDictionary:data];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didQueryOrderDetail:msg:resultOrder:)]) {
                [delegate didQueryOrderDetail:status msg:msg resultOrder:order];
            }
        });
    }];

}

//1.80版本开始使用
+ (void)queryNewUIOrderList:(id<OrderServiceDelegate>)delegate
                userId:(NSString *)userId
           orderStatus:(int)orderStatus
                  page:(int)page
                 count:(int)count
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_ORDER_GET_ORDER_LIST forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:[@(orderStatus) stringValue] forKey:PARA_TYPE];
    [inputDic setValue:[NSString stringWithFormat:@"%d", page] forKey:PARA_PAGE];
    [inputDic setValue:[NSString stringWithFormat:@"%d", count] forKey:PARA_COUNT];
    [inputDic setValue:@"2.0" forKey:PARA_VER];   //1.94版本必传

    [GSNetwork getWithBasicUrlString:GS_URL_ORDER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        
        //parse
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        NSArray *orderListSource = [data validArrayValueForKey:PARA_LIST];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSMutableArray *orderListTarget = [NSMutableArray array];
        
        for (id oneOrderSource in orderListSource) {
            if ([oneOrderSource isKindOfClass:[NSDictionary class]] == NO) {
                continue;
            }
            
            Order *orderTarget = [OrderService orderInOrderListrDictionary:oneOrderSource];
            [orderListTarget addObject:orderTarget];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didQueryOrderList:msg:orderList:page:orderStatus:)]) {
                [delegate didQueryOrderList:status msg:msg orderList:orderListTarget page:page orderStatus:orderStatus];
            }
        });
    }];
}

//- (void)queryOrderList:(id<OrderServiceDelegate>)delegate
//                userId:(NSString *)userId
//           orderStatus:(int)orderStatus
//                  page:(int)page
//                 count:(int)count
//{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        //send
//        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
//        [inputDic setValue:VALUE_ACTION_GET_ORDER_LIST forKey:PARA_ACTION];
//        [inputDic setValue:userId forKey:PARA_USER_ID];
//        [inputDic setValue:[@(orderStatus) stringValue] forKey:PARA_ORDER_STATUS];
//        [inputDic setValue:[NSString stringWithFormat:@"%d", page] forKey:PARA_PAGE];
//        [inputDic setValue:[NSString stringWithFormat:@"%d", count] forKey:PARA_COUNT];
//        
//        //2014-06-23版本号1.1，由于更改支付宝账户
//        //2014-12-22版本号1.2，由于添加了优惠活动id
//        //[inputDic setValue:@"1.1" forKey:PARA_VER];
//        //[inputDic setValue:@"1.2" forKey:PARA_VER];
//        [inputDic setValue:@"1.3" forKey:PARA_VER];
//        
//        NSDictionary *resultDictionary  = [SportNetwrok getJsonWithPrameterDictionary:inputDic];
//        //HDLog(@"<queryOrderList> %@", resultDictionary);
//        
//        //parse
//        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
//        NSArray *orderListSource = [resultDictionary validArrayValueForKey:PARA_ORDER_LIST];
//        NSMutableArray *orderListTarget = [NSMutableArray array];
//
//        for (id oneOrderSource in orderListSource) {
//            if ([oneOrderSource isKindOfClass:[NSDictionary class]] == NO) {
//                continue;
//            }
//            Order *orderTarget = [OrderService orderByOneOrderDictionary:oneOrderSource];
//            [orderListTarget addObject:orderTarget];
//        }
//        
//        /*
//        if ([status isEqualToString:STATUS_SUCCESS]) {
//            [[OrderManager defaultManager] saveOrderList:orderListTarget];
//        }*/
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (delegate && [delegate respondsToSelector:@selector(didQueryOrderList:orderList:page:orderStatus:)]) {
//                [delegate didQueryOrderList:status orderList:orderListTarget page:page orderStatus:orderStatus];
//            }
//        });
//    });
//}

+ (void)cancelOrder:(id<OrderServiceDelegate>)delegate
              order:(Order *)order
             userId:(NSString *)userId
{
         //send
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_CANCEL_ORDER forKey:PARA_ACTION];
    [inputDic setValue:order.orderId forKey:PARA_ORDER_ID];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [GSNetwork getWithBasicUrlString:GS_URL_ORDER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        
        NSDictionary *resultDictionary = response.jsonResult;
        
        //parse
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        if ([status isEqualToString:STATUS_SUCCESS]) {
            order.status = OrderStatusCancelled;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didCancelOrder:orderId:)]) {
                [delegate didCancelOrder:status orderId:order.orderId];
            }
        });
    }];
}

+ (NSArray *)activityListByDictionaryList:(NSArray *)dictionaryList
{
    NSMutableArray *activityList = [NSMutableArray array];
    
    for (id oneSource in dictionaryList) {
        if ([oneSource isKindOfClass:[NSDictionary class]] == NO) {
            continue;
        }
        FavourableActivity *activity = [[FavourableActivity alloc] init] ;
        activity.activityId = [oneSource validStringValueForKey:PARA_ACT_ID];
        activity.activityName = [oneSource validStringValueForKey:PARA_ACT_NAME];
        activity.activityStatus = [oneSource validIntValueForKey:PARA_STATUS];
        activity.activityPrice = [oneSource validFloatValueForKey:PARA_ACT_AMOUNT];
        activity.activityType= [oneSource validIntValueForKey:PARA_TYPE];
        
        [activityList addObject:activity];
    }
    
    return activityList;
}

+ (void)queryNeedPayOrderCount:(id<OrderServiceDelegate>)delegate
                        userId:(NSString *)userId
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_ORDER_DUE_COUNT forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:@"2.0" forKey:PARA_VER]; //2014-11-11添加，返回了订单信息
        
    [GSNetwork getWithBasicUrlString:GS_URL_ORDER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            Order *order = nil;
            
            //只要有订单，固定是一个
            NSUInteger count = 0;
            if ([status isEqualToString:STATUS_SUCCESS]) {
                id data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
                
                if ([data isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *orderDic = [data validDictionaryValueForKey:PARA_ORDER];
                    if ([[orderDic allKeys] count] > 0) {
                        order = [OrderService orderByOneOrderDictionary:orderDic];
                    }
                }
            }
            
            if (delegate && [delegate respondsToSelector:@selector(didQueryNeedPayOrderCount:count:order:)]) {
                [delegate didQueryNeedPayOrderCount:status count:count order:order];
            }
        });
    }];
}

+ (void)checkActivityInviteCode:(id<OrderServiceDelegate>)delegate
                         userId:(NSString *)userId
                     activityId:(NSString *)activityId
                     inviteCode:(NSString *)inviteCode
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_CHECK_ACTIVITY_INVITE_CODE forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:activityId forKey:PARA_ACT_ID];
    [inputDic setValue:inviteCode forKey:PARA_INVITE_CODE];
        
    [GSNetwork getWithBasicUrlString:GS_URL_TICKET parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didCheckActivityInviteCode:status:msg:)]) {
                [delegate didCheckActivityInviteCode:inviteCode status:status msg:msg];
            }
        });
    }];
}

+ (void)confirmOrder:(id<OrderServiceDelegate>)delegate
              userId:(NSString *)userId
         goodsIdList:(NSString *)goodsIdList
           orderType:(int)orderType
               count:(int)count
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_CONFIRM_ORDER forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:goodsIdList forKey:PARA_GOODS_IDS];
    [inputDic setValue:[NSString stringWithFormat:@"%d", orderType] forKey:PARA_ORDER_TYPE];
    [inputDic setValue:[NSString stringWithFormat:@"%d", count] forKey:PARA_GOODS_NUMBER];
        
    [GSNetwork getWithBasicUrlString:GS_URL_ORDER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        
        ConfirmOrder *confirmOrder = [[ConfirmOrder alloc]init];
        confirmOrder.totalAmount = [data validFloatValueForKey:PARA_TOTAL_AMOUNT];
        confirmOrder.payAmount = [data validFloatValueForKey:PARA_ORDER_AMOUNT];
        confirmOrder.promoteAmount = [data validFloatValueForKey:PARA_ORDER_PROMOTE];
        NSString *selectedActivityId = [data validStringValueForKey:PARA_ACT_ID];
        
        if ([selectedActivityId isEqualToString:@"0"]) {
            selectedActivityId = nil;
        }
        confirmOrder.selectedActivityId = selectedActivityId;
        
        NSArray *activitySource = [data validArrayValueForKey:PARA_ACTIVITY_LIST];
        confirmOrder.activityList = [OrderService activityListByDictionaryList:activitySource];
        
        confirmOrder.onePrice = [data validFloatValueForKey:PARA_PRICE];
        
        confirmOrder.userMoney = [data validFloatValueForKey:PARA_USER_MONEY];
        confirmOrder.canRefund = ([data validIntValueForKey:PARA_IS_REFUND] != 0);
        
        confirmOrder.activityMessage = [data validStringValueForKey:PARA_ACTIVITY_MESSAGE];
        
        confirmOrder.isCardUser = ([data validIntValueForKey:PARA_IS_CARD_USER] != 0);
        confirmOrder.refundMessage = [data validStringValueForKey:PARA_REFUND_MESSAGE];
        
        confirmOrder.isSupportClub = [data validBoolValueForKey:PARA_IS_SUPPORT_CLUB];
        confirmOrder.userClubStatus = [data validIntValueForKey:PARA_USER_CLUB_STATUS];
        
        //不能使用动Club的提示
        confirmOrder.clubDisableMsg = [data validStringValueForKey:PARA_CLUB_DISABLE_MSG];
       
        //没有购买动Club的提示
        confirmOrder.noBuyClubMsg = [data validStringValueForKey:PARA_NO_BUY_CLUB_MSG];
        confirmOrder.noUsedClubOrderMsg = [data validStringValueForKey:PARA_HAS_NOUSED_CLUB_MSG];
        
        confirmOrder.isSupportMembershipCard = [data validBoolValueForKey:PARA_CARD_SUPPORT];

        NSMutableArray *cardTargetList = [NSMutableArray array];
        NSArray *cardSourceList = [data validArrayValueForKey:PARA_USER_CARD_LIST];
        for (NSDictionary *one in cardSourceList) {
            MembershipCard *card = [MembershipCardService parseMembershipCardFromDictionary:one];

            [cardTargetList addObject:card];
        }
        
        confirmOrder.cardList = cardTargetList;
        
        confirmOrder.isIncludeInsurance = [data validBoolValueForKey:PARA_INSURANCE_SWITCH];
        
        NSMutableArray *insuranceTargetList = [NSMutableArray array];
        NSArray *insuranceSourceList = [data validArrayValueForKey:PARA_INSURANCE];
        for (NSDictionary *one in insuranceSourceList) {
            Insurance *info = [[Insurance alloc] init] ;
            info.insuranceId = [one validStringValueForKey:PARA_INSURANCE_ID];
            info.insuranceName = [one validStringValueForKey:PARA_INSURANCE_NAME];
            info.unitPrice = [one validFloatValueForKey:PARA_INSURANCE_UNIT_PRICE];
            [insuranceTargetList addObject:info];
        }
        
        confirmOrder.insuranceList = insuranceTargetList;
        confirmOrder.insuranceTips = [data validStringValueForKey:PARA_INSURANCE_TIPS];
        confirmOrder.insuranceUrl = [data validStringValueForKey:PARA_INSURANCE_INTRODUCTION];
        //保险下单限制时间（分钟）
        confirmOrder.insuranceOrderTime = [data validIntValueForKey:PARA_INSURANCE_ORDER_TIME];
        
        confirmOrder.insuranceLimitTips = [data validStringValueForKey:PARA_INSURANCE_LIMIT_TIPS];
        
        confirmOrder.ticketNumber = [data validIntValueForKey:PARA_TICKET_NUM];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didConfirmOrder:msg:confirmOrder:)]) {
                [delegate didConfirmOrder:status msg:msg confirmOrder:confirmOrder];
            
            }
            
//            //人次 SingleBookingController
//            if ([delegate respondsToSelector:@selector(didConfirmOrder:msg:totalAmount:promoteAmount:payAmount:selectedActivityId:activityList:onePrice:userMoney:canRefund:activityMessage:isCardUser:refundMessage:isSupportClub:userClubStatus:clubDisableMsg:noBuyClubMsg:noUsedClubOrderMsg:)]) {
//                [delegate didConfirmOrder:status
//                                      msg:msg
//                              totalAmount:totalAmount
//                            promoteAmount:promoteAmount
//                                payAmount:payAmount
//                       selectedActivityId:selectedActivityId
//                             activityList:activityList
//                                 onePrice:onePrice
//                                userMoney:userMoney
//                                canRefund:canRefund
//                          activityMessage:activityMessage
//                               isCardUser:isCardUser
//                            refundMessage:refundMessage
//                            isSupportClub:isSupportClub
//                           userClubStatus:userClubStatus
//                           clubDisableMsg:clubDisableMsg
//                             noBuyClubMsg:noBuyClubMsg
//                       noUsedClubOrderMsg:noUsedClubOrderMsg];
//            }
            
        });
    }];
}

+ (void)checkOrderRefund:(id<OrderServiceDelegate>)delegate
                 userId:(NSString *)userId
                orderId:(NSString *)orderId
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_CHECK_ORDER_REFUND forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:orderId forKey:PARA_ORDER_ID];
        
    [GSNetwork getWithBasicUrlString:GS_URL_ORDER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
       
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        float refundAmount = 0;
        NSMutableArray *refundWayList = [NSMutableArray array];
        NSMutableArray *refundCauseList = [NSMutableArray array];
        int canRefundNum = 0;
        NSArray *priceList = [NSArray array];
        if ([status isEqualToString:STATUS_SUCCESS]) {
            refundAmount = [data validFloatValueForKey:PARA_REFUND_AMOUNT];
            canRefundNum = [data validFloatValueForKey:PARA_CAN_REFUND_NUM];
            priceList = [data validArrayValueForKey:PARA_PRICE_LIST];
            NSArray *refundWaySourceList = [data validArrayValueForKey:PARA_REFUND_WAY];
            for (NSDictionary *one in refundWaySourceList) {
                RefundWay *way = [[RefundWay alloc] init] ;
                way.refundWayId = [one validStringValueForKey:PARA_ID];
                way.title = [one validStringValueForKey:PARA_TITLE];
                way.subTitle = [one validStringValueForKey:PARA_DESCRIPTION];
                int isPay = [one validIntValueForKey:PARA_IS_PAYPASSWORD];
                way.isPayPassword = (isPay != 0);
                [refundWayList addObject:way];
            }
            
            NSArray *refundCauseSourceList = [data validArrayValueForKey:PARA_REFUND_CAUSE];
            for (NSDictionary *one in refundCauseSourceList) {
                RefundCause *cause = [[RefundCause alloc] init] ;
                cause.refundCauseId = [one validStringValueForKey:PARA_ID];
                cause.title = [one validStringValueForKey:PARA_TITLE];
                [refundCauseList addObject:cause];
            }

        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didCheckOrderRefund:msg:refundAmount:refundWayList:refundCauseList:canRefundNum:priceList:)]) {
                [delegate didCheckOrderRefund:status
                                          msg:msg
                                 refundAmount:refundAmount
                                refundWayList:refundWayList
                              refundCauseList:refundCauseList
                                 canRefundNum:canRefundNum
                                    priceList:priceList];
            }
        });
    }];
}

+ (void)getRefundStatus:(id<OrderServiceDelegate>)delegate
                 userId:(NSString *)userId
                orderId:(NSString *)orderId
{
    
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_GET_REFUND_STATUS forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:orderId forKey:PARA_ORDER_ID];
    [GSNetwork getWithBasicUrlString:GS_URL_ORDER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        int refundStatus = 0;
        float refundAmount = 0;
        NSString *refundWay = nil;
        
        if ([status isEqualToString:STATUS_SUCCESS]) {
            refundStatus = [data validIntValueForKey:PARA_STATUS];
            refundAmount = [data validFloatValueForKey:PARA_REFUND_AMOUNT];
            refundWay = [data validStringValueForKey:PARA_REFUND_WAY];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didGetRefundStatus:msg:refundStatus:refundAmount:refundWay:)]) {
                [delegate didGetRefundStatus:status
                                         msg:msg
                                refundStatus:refundStatus
                                refundAmount:refundAmount
                                   refundWay:refundWay];
            }
        });
    }];
}

+ (void)applyRefund:(id<OrderServiceDelegate>)delegate
             userId:(NSString *)userId
            orderId:(NSString *)orderId
        refundWayId:(NSString *)refundWayId
        refundCause:(NSString *)refundCause
        description:(NSString *)description
        refundNumer:(int)refundNumber
{

    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_APPLY_REFUND forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:orderId forKey:PARA_ORDER_ID];
    [inputDic setValue:refundWayId forKey:PARA_REFUND_WAY];
    [inputDic setValue:refundCause forKey:PARA_REFUND_CAUSE];
    [inputDic setValue:description forKey:PARA_DESCRIPTION];
    [inputDic setValue:@(refundNumber) forKey:PARA_REFUND_NUM];
    [inputDic setValue:@"1.1" forKey:PARA_VER];
    
    [GSNetwork getWithBasicUrlString:GS_URL_ORDER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
            NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        int refundStatus = 0;
        float refundAmount = 0;
        NSString *refundWay = nil;
        
        if ([status isEqualToString:STATUS_SUCCESS]) {
            refundStatus = [data validIntValueForKey:PARA_STATUS];
            refundAmount = [data validFloatValueForKey:PARA_REFUND_AMOUNT];
            refundWay = [data validStringValueForKey:PARA_REFUND_WAY];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didApplyRefund:msg:refundStatus:refundAmount:refundWay:)]) {
                [delegate didApplyRefund:status
                                     msg:msg
                            refundStatus:refundStatus
                            refundAmount:refundAmount
                               refundWay:refundWay];
            }
        });
        }];
}

+ (void)cancelClubOrder:(id<OrderServiceDelegate>)delegate
              order:(Order *)order
             userId:(NSString *)userId
{
            //send
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_CANCEL_CLUB_ORDER forKey:PARA_ACTION];
    [inputDic setValue:order.orderId forKey:PARA_ORDER_ID];
    [inputDic setValue:userId forKey:PARA_USER_ID];
        
    [GSNetwork getWithBasicUrlString:GS_URL_ORDER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;

        //parse
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        if ([status isEqualToString:STATUS_SUCCESS]) {
            order.status = OrderStatusCancelled;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didCancelClubOrder:msg:orderId:)]) {
                [delegate didCancelClubOrder:status msg:msg orderId:order.orderId];
            }
        });
    }];
}

+ (void)submitOrderByCourtJoinWithUserId:(NSString *)userId
                             courtJoinId:(NSString *)courtJoinId
                                   phone:(NSString *)phone
                              completion:(void (^)(NSString *status,NSString *msg, Order * order))completion
{
    //send
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_INSERT_ORDER forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:@"2" forKey:PARA_FROM];
    
    [inputDic setValue:[@(OrderTypeCourtJoin) stringValue] forKey:PARA_ORDER_TYPE];
    //2014-06-23版本号1.1，由于更改支付宝账户
    //2014-12-22版本号1.2，由于添加了优惠活动id
    //2015-01-28版本号1.3，由于添加了代金券id
    //2015-11-05版本号1.4，增加会员卡卡号
    //2016-06-15版本号2.0, 返回phone_encode
    [inputDic setValue:@"2.0" forKey:PARA_VER];
    
    [inputDic setValue:phone forKey:PARA_PHONE_ENCODE];
    [inputDic setValue:courtJoinId forKey:PARA_CJ_ORDER_ID];
    
    [GSNetwork getWithBasicUrlString:GS_URL_ORDER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        Order *order = nil;
        if ([status isEqualToString:STATUS_SUCCESS]) {
            order = [OrderService orderByOneOrderDictionary:data];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(status, msg, order);
            }
        });
    }];
}

+(Product *) productByOneProductDictionary:(NSDictionary *)productDictionary {
    Product *goodsTartet = [[Product alloc] init];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"H:mm"];
    NSDate *startTime = [productDictionary validDateValueForKey:PARA_START_TIME];
    
    goodsTartet.startTime = [formatter stringFromDate:startTime];
    goodsTartet.courtName = [productDictionary validStringValueForKey:PARA_COURT_NAME];
    goodsTartet.price = [productDictionary validDoubleValueForKey:PARA_PRICE];
    
    return goodsTartet;
}

@end
