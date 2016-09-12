//
//  MineService.m
//  Sport
//
//  Created by 赵梦东 on 15/9/8.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "MineService.h"
#import "TicketService.h"
#import "DesUtil.h"
#import "Voucher.h"
#import "UserManager.h"
#import "MineInfo.h"
#import "TodayOrderInfo.h"
#import "OrderTips.h"
#import "GSNetwork.h"

@implementation MineService


+ (void)getMineInfor:(id<MineServiceDelegate>)delegate
              userId:(NSString *)userId
{
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_MY_HOME forKey:PARA_ACTION];
        [inputDic setValue:userId forKey:PARA_USER_ID];
        //1.94+ 增加返回拼场订单
        [inputDic setValue:@"2.0" forKey:PARA_VER];
        
    
    [GSNetwork getWithBasicUrlString:GS_URL_USER parameters:inputDic responseHandler:^(GSNetworkResponse *response) {
        
        NSDictionary *resultDictionary = response.jsonResult;
        
        MineInfo *info=[[MineInfo alloc] init];
        info.orderNotify=[[NSMutableArray alloc] init];
   
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        NSDictionary *data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        
        info.nickName=[data validStringValueForKey:@"nick_name"];
        info.gender=[data validStringValueForKey:@"gender"];
        info.signature=[data validStringValueForKey:@"signature"];
        info.avatar=[data validStringValueForKey:@"avatar"];
        info.buyedClub=[data validIntValueForKey:@"buyed_club"];
        info.clubEndTime=[data validStringValueForKey:@"club_end_time"];
        info.money=[data validFloatValueForKey:@"money"];
        info.integral=[data validIntValueForKey:@"integral"];
        
        NSDictionary *rulesDict = [data validDictionaryValueForKey:PARA_MY_RULES];
        info.rulesTitle = [rulesDict validStringValueForKey:PARA_RULES_TITLE];
        info.rulesIconUrl = [rulesDict validStringValueForKey:PARA_RULES_ICON_URL];
        info.rulesIsDisplay = [rulesDict validStringValueForKey:PARA_RULES_IS_DISPLAY];
        
        info.credit=[data validIntValueForKey:@"credit"];
        info.couponNumber=[data validIntValueForKey:@"coupon_number"];
        NSArray *list=[data validArrayValueForKey:@"order_notify"];
        
        for (NSDictionary *one in list) {
            TodayOrderInfo *tr=[[TodayOrderInfo alloc] init];
            tr.orderId = [one validStringValueForKey:PARA_ORDER_ID];
            tr.name=[one validStringValueForKey:@"name"];
            tr.icon=[one validStringValueForKey:@"icon"];
            tr.verificationCode=[one validStringValueForKey:PARA_VERIFICATION_CODE];
            tr.startTime=[one validStringValueForKey:PARA_START_TIME];
            tr.type = [one validIntValueForKey:PARA_ORDER_TYPE];
            tr.status = [one validIntValueForKey:PARA_ORDER_STATUS];
            tr.isCourtJoinParent = [one validBoolValueForKey:PARA_IS_COURT_JOIN_PARENT];
            [info.orderNotify addObject:tr];
            
        }
        
        NSDictionary *tip=[data validDictionaryValueForKey:@"my_order_tips"];
        
        OrderTips *ot=[[OrderTips alloc] init];
        
        ot.orderPreComment=[tip validIntValueForKey:@"order_pre_comment"];
        ot.orderPrePay=[tip validIntValueForKey:@"order_pre_pay"];
        ot.orderPreStart=[tip validIntValueForKey:@"order_pre_start"];
        
        info.orderTips=ot;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(didGetMineInfor:status:msg:)]) {
                [delegate didGetMineInfor:info status:status msg:msg];
            }
        });
    }];
}

@end
