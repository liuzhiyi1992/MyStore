//
//  SportNetwrok.m
//  Sport
//
//  Created by haodong  on 13-6-6.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SportNetwork.h"
#import "SportNetworkContent.h"
#import "GSNetworkAssist.h"

@implementation SportNetwork

+ (NSDictionary *)getJsonWithPrameterDictionary:(NSDictionary *)parameterDictionary
{
    return [self getJsonWithPrameterDictionary:parameterDictionary
                                     urlString:SPORT_URL_DEFAULT_APP_V2];
}

+ (NSDictionary *)getJsonWithPrameterDictionary:(NSDictionary *)parameterDictionary
                                      urlString:(NSString *)urlString
{
    if ([GSNetworkAssist checkTokenNetworkReq:parameterDictionary] == NO){
        NSDictionary *reDic = @{PARA_STATUS:STATUS_UKNOW_ERROR, PARA_MSG:@"系统繁忙，请稍后再试"};
        return reDic;
    }
    
    NSDictionary *inputDic = [GSNetworkAssist addCommonParameters:parameterDictionary];
    NSDictionary *outputDic = [DDNetwork getReturnJsonWithBasicUrlString:urlString
                                                     parameterDictionary:inputDic];
    return [GSNetworkAssist checkResult:outputDic response:nil];
}

+ (NSDictionary *)postReturnJsonWithPrameterDictionary:(NSDictionary *)parameterDictionary
{
    return [self postReturnJsonWithPrameterDictionary:parameterDictionary
                                            urlString:SPORT_URL_DEFAULT_APP_V2];
}

+ (NSDictionary *)postReturnJsonWithPrameterDictionary:(NSDictionary *)parameterDictionary
                                             urlString:(NSString *)urlString
{
    return [self postReturnJsonWithPrameterDictionary:parameterDictionary
                                            urlString:urlString
                                             postType:PostTypeString];
}

+ (NSDictionary *)postReturnJsonWithPrameterDictionary:(NSDictionary *)parameterDictionary
                                             urlString:(NSString *)urlString
                                              postType:(PostType)postType
{
    if ([GSNetworkAssist checkTokenNetworkReq:parameterDictionary] == NO){
        NSDictionary *reDic = @{PARA_STATUS:STATUS_UKNOW_ERROR, PARA_MSG:@"系统错误，请稍后再试"};
        return reDic;
    }
    
    NSDictionary *inputDic = [GSNetworkAssist addCommonParameters:parameterDictionary];
    NSDictionary *outputDic = [DDNetwork postReturnJsonWithBasicUrlString:urlString
                                   parameterDictionary:inputDic
                                              postType:postType];
    return [GSNetworkAssist checkResult:outputDic response:nil];
}

+ (NSDictionary *)jsonWithpostImage:(UIImage *)image
                          imageName:(NSString *)imageName
                     basicUrlString:(NSString *)basicUrlString
                parameterDictionary:(NSDictionary *)parameterDictionary
{
    if ([GSNetworkAssist checkTokenNetworkReq:parameterDictionary] == NO){
        NSDictionary *reDic = @{PARA_STATUS:STATUS_UKNOW_ERROR, PARA_MSG:@"系统错误，请稍后再试"};
        return reDic;
    }
    
    NSDictionary *dic = [GSNetworkAssist addCommonParameters:parameterDictionary];
    NSMutableString *urlString = [NSMutableString stringWithString:basicUrlString];
    NSArray *allKeys = [dic allKeys];
    int index = 0;
    for (NSString *key in allKeys) {
        NSString *value = [dic objectForKey:key];
        if (value == nil){
            continue;
        }
        [urlString appendFormat:@"%@%@=%@", (index == 0 ? @"?" : @"&" ), key, value];
        index ++;
    }
    NSDictionary *outputDic = [DDNetwork jsonWithpostImage:image imageName:imageName urlString:urlString];
    
    return [GSNetworkAssist checkResult:outputDic response:nil];
}

@end
