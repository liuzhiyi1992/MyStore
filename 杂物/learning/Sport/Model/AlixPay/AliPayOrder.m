//
//  AliPayOrder.m
//  Sport
//
//  Created by haodong  on 14/12/23.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "AliPayOrder.h"

@implementation AliPayOrder

- (NSString *)description {
    NSMutableString * discription = [NSMutableString string];
    [discription appendFormat:@"partner=\"%@\"", self.partner ? self.partner : @""];
    [discription appendFormat:@"&seller_id=\"%@\"", self.seller ? self.seller : @""];
    [discription appendFormat:@"&out_trade_no=\"%@\"", self.tradeNO ? self.tradeNO : @""];
    [discription appendFormat:@"&subject=\"%@\"", self.productName ? self.productName : @""];
    [discription appendFormat:@"&body=\"%@\"", self.productDescription ? self.productDescription : @""];
    [discription appendFormat:@"&total_fee=\"%@\"", self.amount ? self.amount : @""];
    [discription appendFormat:@"&notify_url=\"%@\"", self.notifyURL ? self.notifyURL : @""];
    
    [discription appendFormat:@"&service=\"%@\"", self.service ? self.service : @"mobile.securitypay.pay"];
    [discription appendFormat:@"&_input_charset=\"%@\"", self.inputCharset ? self.inputCharset : @"utf-8"];
    [discription appendFormat:@"&payment_type=\"%@\"", self.paymentType ? self.paymentType : @"1"];
    
    [discription appendFormat:@"&it_b_pay=\"%@\"", self.itBPay ? self.itBPay : @"12m"];
    [discription appendFormat:@"&show_url=\"%@\"", self.showUrl ? self.showUrl : @"m.alipay.com"];
    
    if (self.rsaDate) {
        [discription appendFormat:@"&sign_date=\"%@\"",self.rsaDate];
    }
    if (self.appID) {
        [discription appendFormat:@"&app_id=\"%@\"",self.appID];
    }
    
    for (NSString * key in [self.extraParams allKeys]) {
        [discription appendFormat:@"&%@=\"%@\"", key, [self.extraParams objectForKey:key]];
    }
    return discription;
    
}

@end
