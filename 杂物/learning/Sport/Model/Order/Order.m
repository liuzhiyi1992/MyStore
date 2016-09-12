//
//  Order.m
//  Sport
//
//  Created by haodong  on 13-7-23.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "Order.h"
#import "Product.h"
#import "PriceUtil.h"
#import "UIColor+HexColor.h"
#import "FavourableActivity.h"

@implementation Order

- (NSString *)orderStatusText
{
    switch (self.status) {
        case OrderStatusUnpaid:
            return @"未支付";
        case OrderStatusPaid:
            return @"待开始";
        case OrderStatusCancelled:
            return @"已撤销";
        case OrderStatusUsed:
            return @"已完成";
        case OrderStatusExpired:
            return @"已过期";
        case OrderStatusRefund:
            switch (self.refundStatus) {
                case 1:
                    return @"退款中";
                case 2:
                    return @"已退款";
                default:
                    return @"退款";
            }
        case OrderStatusCardPaid:
            //return @"会员预订";
            return @"待开始";
        default:
            return @"未知状态";
    }
}

//未支付：ff850d
//其他：aaaaaa
- (UIColor *)orderStatusTextColor
{
    switch (self.status) {
        case OrderStatusUnpaid:
        case OrderStatusPaid:
        case OrderStatusCardPaid:
            return [SportColor defaultOrangeColor];
        default:
            return [UIColor hexColor:@"aaaaaa"];
    }
}

- (NSString *)coachOrderStatusText
{
    switch (self.coachStatus) {
        case CoachOrderStatusUnpaid:
            return @"待支付";
        case CoachOrderStatusUnPaidCancelled:
        case CoachOrderStatusCancelled:
            return @"已取消";
        case CoachOrderStatusExpired:
            return @"已过期";
        case CoachOrderStatusReadyCoach:
            return @"待开始";
        case CoachOrderStatusCoaching:
            return @"进行中";
        case CoachOrderStatusReadyConfirm:
            return @"待确认";
        case CoachOrderStatusFinished:
            return @"已完成";
        case CoachOrderStatusRefund:
            return @"已退款";
        default:
            return @"未知状态";
    }
}

#define YELLOW_COLOR [UIColor hexColor:@"f28f4c"]
#define BLACK_COLOR [UIColor hexColor:@"636363"];
#define GREY_COLOR [UIColor hexColor:@"c2c2c2"]
- (UIColor *)coachOrderStatusTextColor
{
    switch (self.coachStatus) {
        case CoachOrderStatusUnpaid:
        case CoachOrderStatusReadyConfirm:
        case CoachOrderStatusReadyCoach:
        case CoachOrderStatusCoaching:
            return YELLOW_COLOR;
        case CoachOrderStatusFinished:
            return BLACK_COLOR;
        default:
            return GREY_COLOR;
    }
}

- (NSString *)coachOrderTimeRangeText {
    switch (self.timeRange) {
        case 1:
            return @"上午";
        case 2:
            return @"下午";
        case 3:
            return @"晚上";
        default:
            return nil;
            break;
    }
}
- (NSString *)createForwardText
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
    [dateFormatter setDateFormat:@"yyyy年M月d日"];
    NSString *userDateString = [dateFormatter stringFromDate:self.useDate];
    
    NSMutableString *mutableString = [NSMutableString stringWithFormat:@"我在趣运动上预订了%@,订单号:%@,场馆:%@,地址:%@", self.categoryName, self.orderNumber, self.businessName, self.businessAddress];
    
    if (self.type == OrderTypeDefault) {
        [mutableString appendFormat:@",场次信息:%@", userDateString];
        
        NSDictionary *dic = [self createGroup:NO];
        NSArray *nameList = [dic allKeys];
        for (NSString *name in nameList) {
            
            NSMutableString *oneVenue = [NSMutableString stringWithFormat:@",%@(", name];
            NSArray *timeList = [dic objectForKey:name];
            int index = 0;
            for (NSString *time in timeList) {
                if (index > 0) {
                    [oneVenue appendString:@"、"];
                }
                [oneVenue appendString:time];
                index ++;
            }
            [oneVenue appendString:@")"];
            
            [mutableString appendString:oneVenue];
        }
    } else if (self.type == OrderTypeSingle) {
        [mutableString appendFormat:@",套餐:%@", self.goodsName];
        [mutableString appendFormat:@",数量:%d张", self.count];
    }
    
    [mutableString appendFormat:@",消费验证码:%@", self.consumeCode];
    
    return mutableString;
}

//分组，返回字典结构，key是场地名，value是数组，该数组的每一项就是时间价钱
- (NSDictionary *)createGroup:(BOOL)isShowPrice
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for (Product *product in self.productList) {
        NSString *key = product.courtName;
        NSMutableArray *value = [NSMutableArray arrayWithArray:(NSArray *)[dictionary objectForKey:key]];
        
        NSMutableString *oneItem = [NSMutableString stringWithString:[product startTimeToEndTime]];
        if (isShowPrice) {
            [oneItem appendFormat:@" %@元", [PriceUtil toValidPriceString:product.price]];
        }
        [value addObject:oneItem];
        
        [dictionary setObject:value forKey:key];
    }
    return dictionary;
}

-(NSString *)orderPayMethodString {
    NSString *subValue = @"在线支付";
    if (self.isClubPay == YES) {
        subValue = @"动Club";
    }else if (self.type == OrderTypeMembershipCard) {
        subValue = @"场馆会员卡";
    }

    return subValue;
}

- (FavourableActivity *)selectedActivity:(NSString *)selectedActivityId
{
    FavourableActivity *activity = nil;
    for (FavourableActivity *one in self.favourableActivityList) {
        if ([one.activityId isEqualToString:selectedActivityId]) {
            activity = one;
            break;
        }
    }
    
    return activity;
}


@end
