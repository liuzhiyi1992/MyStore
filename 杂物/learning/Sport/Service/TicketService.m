//
//  TicketService.m
//  Sport
//
//  Created by qiuhaodong on 15/6/29.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "TicketService.h"
#import "DesUtil.h"
#import "Voucher.h"
#import "UserManager.h"
#import "Order.h"
#import "GSNetwork.h"

@implementation TicketService

+ (void)rechargeDebitCard:(id<TicketServiceDelegate>)delegate
                   userId:(NSString *)userId
                 password:(NSString *)password
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_RECHARGE_DEBIT_CARD forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:[DesUtil encryptUseDES:password key:SPORT_DES_KEY iv:SPORT_DES_IV] forKey:PARA_PASSWORD];
        
    [GSNetwork getWithBasicUrlString:GS_URL_TICKET parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        double balance = 0;
        if ([status isEqualToString:STATUS_SUCCESS]) {
            NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
            balance = [data validDoubleValueForKey:PARA_BALANCE];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didRechargeDebitCard:status:msg:)]) {
                [delegate didRechargeDebitCard:balance status:status msg:msg];
            }
        });
    }];
}

+ (void)expireTicketList:(id<TicketServiceDelegate>)delegate
                  userId:(NSString *)userId
                    page:(NSUInteger)page
                   count:(NSUInteger)count
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_EXPIRE_TICKET_LIST forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:[@(page) stringValue] forKey:PARA_PAGE];
    [inputDic setValue:[@(count) stringValue] forKey:PARA_COUNT];
    
    [GSNetwork getWithBasicUrlString:GS_URL_TICKET parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        NSArray *ticketList = [data validArrayValueForKey:PARA_TICKET_LIST];
        NSMutableArray *list = nil;
        if ([status isEqualToString:STATUS_SUCCESS]) {
            list = [NSMutableArray array];
            for (NSDictionary *one in ticketList) {
                if (![one isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                Voucher *voucher = [self voucherFormDictionary:one];
                voucher.type = VoucherTypeSport;
                [list addObject:voucher];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didExpireTicketList:status:msg:page:)]) {
                [delegate didExpireTicketList:list status:status msg:msg page:page];
            }
        });
    }];
}

+ (void)expireCouponList:(id<TicketServiceDelegate>)delegate
                  userId:(NSString *)userId
                    page:(NSUInteger)page
                   count:(NSUInteger)count
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
    [inputDic setValue:VALUE_ACTION_EXPIRE_COUPON_LIST forKey:PARA_ACTION];
    [inputDic setValue:userId forKey:PARA_USER_ID];
    [inputDic setValue:[@(page) stringValue] forKey:PARA_PAGE];
    [inputDic setValue:[@(count) stringValue] forKey:PARA_COUNT];
        
    [GSNetwork getWithBasicUrlString:GS_URL_TICKET parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
           
        id data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        NSMutableArray *list = [NSMutableArray array];
        if ([status isEqualToString:STATUS_SUCCESS]) {
            
            NSArray *couponList = [data validArrayValueForKey:PARA_TICKET_LIST];
            if ([couponList isKindOfClass:[NSArray class]]) {
                for (id one in couponList) {
                    if ([one isKindOfClass:[NSDictionary class]] == NO) {
                        break;
                    }
                    Voucher *voucher = [self voucherFormDictionary:one];
                    voucher.type = VoucherTypeDefault;
                    [list addObject:voucher];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didExpireCouponList:status:msg:page:)]){
                [delegate didExpireCouponList:list status:status msg:msg page:page];
            }
        });
    }];
}

//全部票卷的入口
+ (Voucher *)voucherFormDictionary:(NSDictionary *)dic
{
    Voucher *voucher = [[Voucher alloc] init] ;
    voucher.voucherId = [dic validStringValueForKey:PARA_ID];
    voucher.voucherNumber = [dic validStringValueForKey:PARA_SN];
    voucher.title = [dic validStringValueForKey:PARA_NAME];
    voucher.desc = [dic validStringValueForKey:PARA_DESCRIPTION];
    voucher.validDate = [dic validDateValueForKey:PARA_USE_END_DATE];
    voucher.amount = [dic validDoubleValueForKey:PARA_AMOUNT];
    voucher.minAmount = [dic validDoubleValueForKey:PARA_MIN_AMOUNT];
    voucher.maxAmount = [dic validDoubleValueForKey:PARA_MAX_AMOUNT];
    voucher.type = [dic validIntValueForKey:PARA_TICKET_TYPE];
    voucher.isEnable = [dic validBoolValueForKey:PARA_IS_ENABLE];
    voucher.disableMessage = [dic validStringValueForKey:PARA_DISABLE_MSG];
    voucher.status = [dic validIntValueForKey:PARA_STATUS];

    voucher.couponName = [dic validStringValueForKey:PARA_COUPON_NAME];

    voucher.useStartDate = [dic validDateValueForKey:PARA_USE_START_DATE];

    voucher.endDate = [dic validIntValueForKey:PARA_END_DATE];
    voucher.voucherName = [dic validStringValueForKey:PARA_FRONT_VOLUME_NAME];
    voucher.firstInstruction = [dic validStringValueForKey:PARA_FIRST_INSTRUCTION];
    voucher.secondInstruction = [dic validStringValueForKey:PARA_SECOND_INSTRUCTION];
    voucher.thirdInstruction = [dic validStringValueForKey:PARA_THIRD_INSTRUCTION];
    return voucher;
}

+ (void)getNewTicketList:(id<TicketServiceDelegate>)delegate
                  userId:(NSString *)userId
                goodsIds:(NSString *)goodsIds
               orderType:(NSString *)orderType
                   entry:(NSString * )entry
              categoryId:(NSString *)categoryId
                  cityId:(NSString *)cityId
{
//HOST/app/ticket?action=ticket_list&client_time=1441113004&user_id=3332&api_sign=46d9bd20ac686c77b4d371e35418e4ce

        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        
        [inputDic setValue:@"ticket_list" forKey:PARA_ACTION];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        [inputDic setValue:goodsIds forKey:PARA_GOODS_IDS];
        [inputDic setValue:orderType forKey:PARA_ORDER_TYPE];
      
        [inputDic setValue:entry forKey:PARA_ENTRY];
        [inputDic setValue:categoryId forKey:PARA_CATEGORY_ID];
       
       [inputDic setValue:cityId forKey:PARA_CITY_ID];
 
    
    [GSNetwork getWithBasicUrlString:GS_URL_TICKET parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        NSDictionary *resultDictionary = response.jsonResult;
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        NSArray *ticketList = [data validArrayValueForKey:PARA_TICKET_LIST];
        NSMutableArray *list = nil;
        if ([status isEqualToString:STATUS_SUCCESS]) {
            list = [NSMutableArray array];
            for (NSDictionary *one in ticketList) {
                if ([one isKindOfClass:[NSDictionary class]]) {
                    Voucher *voucher = [self voucherFormDictionary:one];
                    voucher.status = VoucherStatusActive; //在此接口下，所有都是激活状态
                    [list addObject:voucher];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didGetTicketList:status:msg:usableDays:userClubStatus:)]) {
                [delegate didGetTicketList:list status:status msg:msg usableDays:nil userClubStatus:0];
            }
        });
    }];
}


+ (void)addVoucher:(id<TicketServiceDelegate>)delegate
            userId:(NSString *)userId
     voucherNumber:(NSString *)voucherNumber
          goodsIds:(NSString *)goodsIds
         orderType:(NSString *)orderType
{
    NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_ACTIVATE_COUPONT forKey:PARA_ACTION];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        [inputDic setValue:[DesUtil encryptUseDES:voucherNumber key:SPORT_DES_KEY iv:SPORT_DES_IV] forKey:PARA_COUPON_SN];
        //[inputDic setValue:@"1.1" forKey:PARA_VER];//1.1版本：解决两次urlEncode的问题
        [inputDic setValue:@"1.2" forKey:PARA_VER];//1.2版本：添加了运动券，运动券和代金券用同一种返回结构
        [inputDic setValue:goodsIds forKey:PARA_GOODS_IDS];
        [inputDic setValue:orderType forKey:PARA_ORDER_TYPE];
        
        [GSNetwork getWithBasicUrlString:GS_URL_TICKET parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
            NSDictionary *resultDictionary = response.jsonResult;
        NSString *staus = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        Voucher *voucher = nil;

        if ([staus isEqualToString:STATUS_SUCCESS]) {
            id data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
            voucher = [self voucherFormDictionary:data];
            voucher.status = VoucherStatusActive; //在此接口下，所有都是激活状态
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didAddVoucher:msg:voucher:)]) {
                [delegate didAddVoucher:staus msg:msg voucher:voucher];
            }
        });
    }];
}

@end
