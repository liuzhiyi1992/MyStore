//
//  GSNetworkAssist.h
//  Sport
//
//  Created by qiuhaodong on 16/6/1.
//  Copyright © 2016年 haodong . All rights reserved.
//
//  功能:网络助手，用于发送请求前添加公共参数，校验响应结果
//

#import <Foundation/Foundation.h>

@interface GSNetworkAssist : NSObject

/*
 必须保证addCommonParameters:和checkResult:成对调用。
 因为前者有调用OSAtomicIncrement32Barrier(&networkQueueCount)
 后者有调用OSAtomicDecrement32Barrier(&networkQueueCount) 
 */
+ (NSDictionary *)addCommonParameters:(NSDictionary *)dictionary;

+ (NSDictionary *)checkResult:(NSDictionary *)dic response:(NSURLResponse *)response;

+ (BOOL)checkTokenNetworkReq:(NSDictionary *)parameterDictionary;

@end
