//
//  WeChatPayManager.m
//  Sport
//
//  Created by haodong  on 14-7-3.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "WeChatPayManager.h"
#import "WeChatUtil.h"
#import "WXApi.h"
#import "SportProgressView.h"

static WeChatPayManager *_globalWeChatPayManager = nil;

@implementation WeChatPayManager

+ (WeChatPayManager *)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _globalWeChatPayManager = [[WeChatPayManager alloc] init];
    });
    return _globalWeChatPayManager;
}

/*
+ (NSString *)genPackageWithOrderNumber:(NSString *)orderNumber
                            orderAmount:(double)orderAmount
                              orderDesc:(NSString *)orderDesc
                              notifyUrl:(NSString *)notifyUrl
{
    if (orderNumber == nil
        || orderDesc == nil
        ||  notifyUrl == nil) {
        HDLog(@"<genPackageWithOrderNumber> 参数为空");
        return @"";
    }
    
    // 构造参数列表
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"WX" forKey:@"bank_type"];
    [params setObject:orderDesc forKey:@"body"];
    [params setObject:@"1" forKey:@"fee_type"];
    [params setObject:@"UTF-8" forKey:@"input_charset"];
    [params setObject:notifyUrl forKey:@"notify_url"];
    [params setObject:orderNumber forKey:@"out_trade_no"];
    [params setObject:WEIXIN_PARTNER_ID forKey:@"partner"];
    [params setObject:[WeChatUtil getIPAddress:YES] forKey:@"spbill_create_ip"];
    [params setObject:[NSString stringWithFormat:@"%d", (int)(orderAmount * 100)] forKey:@"total_fee"];    // 1 =＝ ¥0.01
    
    NSArray *keys = [params allKeys];
    NSArray *sortedKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    // 生成 packageSign
    NSMutableString *package = [NSMutableString string];
    for (NSString *key in sortedKeys) {
        [package appendString:key];
        [package appendString:@"="];
        [package appendString:[params objectForKey:key]];
        [package appendString:@"&"];
    }
    
    [package appendString:@"key="];
    [package appendString:WEIXIN_PARTNER_KEY]; // 注意:不能hardcode在客户端,建议genPackage这个过程都由服务器端完成
    
    // 进行md5摘要前,params内容为原始内容,未经过url encode处理
    NSString *packageSign = [[WeChatUtil md5:[[package copy] autorelease]] uppercaseString]; //qhd 20141018添加了autorelease
    package = nil;
    
    // 生成 packageParamsString
    NSString *value = nil;
    package = [NSMutableString string];
    for (NSString *key in sortedKeys) {
        [package appendString:key];
        [package appendString:@"="];
        value = [params objectForKey:key];
        
        // 对所有键值对中的 value 进行 urlencode 转码
        value = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)value, nil, (CFStringRef)@"!*'&=();:@+$,/?%#[]", kCFStringEncodingUTF8));
        
        [package appendString:value];
        [package appendString:@"&"];
    }
    NSString *packageParamsString = [package substringWithRange:NSMakeRange(0, package.length - 1)];
    
    NSString *result = [NSString stringWithFormat:@"%@&sign=%@", packageParamsString, packageSign];
    
    HDLog(@"--- Package: %@", result);
    
    return result;
}

+ (NSString *)genSign:(NSDictionary *)signParams
{
    // 排序
    NSArray *keys = [signParams allKeys];
    NSArray *sortedKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    // 生成
    NSMutableString *sign = [NSMutableString string];
    for (NSString *key in sortedKeys) {
        [sign appendString:key];
        [sign appendString:@"="];
        [sign appendString:[signParams objectForKey:key]];
        [sign appendString:@"&"];
    }
    NSString *signString = [[[sign copy] autorelease] substringWithRange:NSMakeRange(0, sign.length - 1)]; //qhd 20141018添加autorelease
    
    NSString *result = [WeChatUtil sha1:signString];
    NSLog(@"--- Gen sign: %@", result);
    return result;
}

+ (void)pay:(NSString *)prepayId timeStamp:(NSString *)timeStamp nonceStr:(NSString *)nonceStr
{
    // 调起微信支付
    PayReq *request   = [[[PayReq alloc] init] autorelease];
    request.partnerId = WEIXIN_PARTNER_ID;
    request.prepayId  = prepayId;
    request.package   = @"Sign=WXPay";  // 文档为 `Request.package = _package;` , 但如果填写上面生成的 `package` 将不能支付成功
    request.nonceStr  = nonceStr;
    request.timeStamp = [timeStamp intValue];
    
    // 构造参数列表
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:WEIXIN_APP_ID forKey:@"appid"];
    [params setObject:WEIXIN_PAY_SIGN_KEY forKey:@"appkey"];
    [params setObject:request.nonceStr forKey:@"noncestr"];
    [params setObject:request.package forKey:@"package"];
    [params setObject:request.partnerId forKey:@"partnerid"];
    [params setObject:request.prepayId forKey:@"prepayid"];
    [params setObject:timeStamp forKey:@"timestamp"];
    request.sign = [WeChatPayManager genSign:params];
    
    // 在支付之前，如果应用没有注册到微信，应该先调用 [WXApi registerApp:appId] 将应用注册到微信
    [WXApi sendReq:request];
}

- (void)payWithOrderNumber:(NSString *)orderNumber
               orderAmount:(double)orderAmount
                 orderDesc:(NSString *)orderDesc
                 notifyUrl:(NSString *)notifyUrl
{
    NSMutableDictionary *customerParaDic = [NSMutableDictionary dictionary];
    [customerParaDic setValue:orderNumber forKey:@"order_number"];
    [customerParaDic setValue:[NSString stringWithFormat:@"%0.2f", orderAmount] forKey:@"order_amount"];
    [customerParaDic setValue:orderDesc forKey:@"order_desc"];
    [customerParaDic setValue:notifyUrl forKey:@"notify_url"];
    
    [SportProgressView showWithStatus:@"打开微信支付" hasMask:YES];
    [[WeChatPayService defaultService] queryAccessToken:self customerParaDic:customerParaDic];
}

#pragma mark - WeChatPayServiceDelegate
- (void)didQueryAccessToken:(NSString *)accessToken
                  expiresIn:(int)expiresIn
                    errcode:(NSString *)errcode
                     errmsg:(NSString *)errmsg
            customerParaDic:(NSDictionary *)customerParaDic
{
    if (accessToken) {
        NSString * orderNumber = [customerParaDic valueForKey:@"order_number"];
        double orderAmount = [[customerParaDic valueForKey:@"order_amount"] doubleValue];
        NSString *orderDesc = [customerParaDic valueForKey:@"order_desc"];
        NSString *notifyUrl =  [customerParaDic valueForKey:@"notify_url"];
        
        [[WeChatPayService defaultService] queryPrepayId:self
                                             accessToken:accessToken
                                             orderNumber:orderNumber
                                             orderAmount:orderAmount
                                               orderDesc:orderDesc
                                               notifyUrl:notifyUrl];
    } else {
        [SportProgressView dismiss];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:errcode forKey:@"error_code"];
        [dic setValue:errmsg forKey:@"error_message"];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_FINISH_WECHAT_PAY object:nil userInfo:dic];
    }
}

- (void)didQueryPrepayId:(NSString *)prepayId
                 errcode:(NSString *)errcode
                  errmsg:(NSString *)errmsg
               timeStamp:(NSString *)timeStamp
                 nonceStr:(NSString *)nonceStr

{
    [SportProgressView dismiss];
    HDLog(@"didQueryPrepayId:%@", prepayId);
    if (prepayId) {
        [WeChatPayManager pay:prepayId timeStamp:timeStamp nonceStr:nonceStr];
    } else {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:errcode forKey:@"error_code"];
        [dic setValue:errmsg forKey:@"error_message"];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_FINISH_WECHAT_PAY object:nil userInfo:dic];
    }
}

*/

+ (BOOL)isWXAppInstalled
{
    return [WXApi isWXAppInstalled];
}

+ (void)payWithOpenID:(NSString *)openID
            partnerId:(NSString *)partnerId
             prepayId:(NSString *)prepayId
             nonceStr:(NSString *)nonceStr
            timeStamp:(NSString *)timeStamp
              package:(NSString *)package
                 sign:(NSString *)sign
{
    PayReq *request   = [[PayReq alloc] init] ;
    
    request.openID = openID;
    request.partnerId = partnerId;
    request.prepayId  = prepayId;
    request.nonceStr  = nonceStr;
    request.timeStamp = [timeStamp intValue];
    request.package   = package;
    request.sign = sign;
    
    [WXApi sendReq:request];
}

@end
