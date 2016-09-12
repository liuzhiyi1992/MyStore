//
//  DDNetwork.m
//  TestURLConnection
//
//  Created by haodong  on 13-6-5.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "DDNetwork.h"
#import "LogUtil.h"
#import "NSString+Utils.h"

//timeout default is 60
#define TIMEOUT_INTERVAL    30

@implementation DDNetwork

+ (NSDictionary *)getReturnJsonWithBasicUrlString:(NSString *)basicUrlString
                              parameterDictionary:(NSDictionary *)parameterDictionary
{
    NSData *data = [DDNetwork sendRequestWithBasicUrlString:basicUrlString parameterDictionary:parameterDictionary];
    
    HDLog(@"<DDNetwork> Receive data:%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] );
    if (data == nil) {
        return nil;
    }
    NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    return resultDic;
}


+ (NSString *)urlStringByBasicUrlString:(NSString *)basicUrlString parameterDictionary:(NSDictionary *)parameterDictionary
{
    NSMutableString *urlString = [NSMutableString stringWithString:basicUrlString];
    NSArray *allKeys = [parameterDictionary allKeys];
    
    int index = 0;
    for (NSString *key in allKeys) {
        NSString *value = [parameterDictionary objectForKey:key];
        if (value == nil){
            continue;
        }
        [urlString appendFormat:@"%@%@=%@", (index == 0 ? @"?" : @"&" ), key, [value encodedURLParameterString]];
        index ++;
    }
    //不用stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding
    
    return urlString;
}


+ (NSData *)sendRequestWithBasicUrlString:(NSString *)basicUrlString
                      parameterDictionary:(NSDictionary *)parameterDictionary
{
    NSURL *url = [NSURL URLWithString:[self urlStringByBasicUrlString:basicUrlString parameterDictionary:parameterDictionary]];
    
    NSURLRequest *request  = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:TIMEOUT_INTERVAL];
    NSURLResponse *respose = nil;
    NSError *error = nil;
    HDLog(@"<DDNetwork> Send url:%@", url);
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&respose error:&error];
    //    if (error == nil) {
    //        NSLog(@"succ");
    //    } else {
    //        NSLog(@"error");
    //    }
    //    NSLog(@"respose url:%@ textEncodingName:%@ MIMEType:%@ suggestedFilename:%@ expectedContentLength:%lld", respose.URL, respose.textEncodingName, respose.MIMEType,  respose.suggestedFilename, respose.expectedContentLength);
    return data;
}


+ (NSDictionary *)postReturnJsonWithBasicUrlString:(NSString *)basicUrlString
                               parameterDictionary:(NSDictionary *)parameterDictionary
                                          postType:(PostType)postType
{
    NSData *data = [DDNetwork postSendRequestWithBasicUrlString:basicUrlString parameterDictionary:parameterDictionary postType:postType];
    
    HDLog(@"<DDNetwork> Receive data:%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] );
    if (data == nil) {
        return nil;
    }
    NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    return resultDic;
}


+ (NSData *)postSendRequestWithBasicUrlString:(NSString *)basicUrlString
                          parameterDictionary:(NSDictionary *)parameterDictionary
                                     postType:(PostType)postType
{
    NSURL *url = [NSURL URLWithString:basicUrlString];
    HDLog(@"<DDNetwork> Send url:%@", url);
    
    NSMutableString *bodyString = [NSMutableString stringWithString:@""];
    NSData * bodyData = nil;
    
    if (postType == PostTypeString) {
        NSArray *allKeys = [parameterDictionary allKeys];
        int index = 0;
        for (NSString *key in allKeys) {
            NSString *value = [parameterDictionary objectForKey:key];
            if (value == nil){
                continue;
            }
            if (index > 0) {
                [bodyString appendString:@"&"];
            }
            [bodyString appendFormat:@"%@=%@", key, ([value isKindOfClass:[NSString class]] ? [value encodedURLParameterString] : value)];
            index ++;
        }
        bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
        
        HDLog(@"<DDNetwork> post stringPara:%@", bodyString);
    } else if (postType == PostTypeJson){
        
        //进行urlencode
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        NSArray *allKeys = [parameterDictionary allKeys];
        for (NSString *key in allKeys) {
            NSString *value = [parameterDictionary objectForKey:key];
            [dic setValue:[value encodedURLParameterString] forKey:key];
        }
        
        HDLog(@"<DDNetwork> post josn:%@", parameterDictionary);
        
        bodyData = [NSJSONSerialization dataWithJSONObject:parameterDictionary options:NSJSONWritingPrettyPrinted error:nil];
        
        //        NSDictionary *logDic = [NSJSONSerialization JSONObjectWithData:bodyData options:NSJSONReadingMutableContainers error:nil];
        //        HDLog(@"<DDNetwork> post jsonPara:%@", logDic);
    }
    
    NSMutableURLRequest *mutableURLRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:TIMEOUT_INTERVAL];
    [mutableURLRequest setHTTPMethod:@"post"];
    [mutableURLRequest setHTTPBody:bodyData];
    
    //HDLog(@"post allHTTPHeaderFields%@", [mutableURLRequest allHTTPHeaderFields]);
    
    NSURLResponse *respose = nil;
    NSError *error = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:mutableURLRequest returningResponse:&respose error:&error];
    
    //    if (error == nil) {
    //        NSLog(@"succ");
    //    } else {
    //        NSLog(@"error");
    //    }
    //    NSLog(@"respose url:%@ textEncodingName:%@ MIMEType:%@ suggestedFilename:%@ expectedContentLength:%lld", respose.URL, respose.textEncodingName, respose.MIMEType,  respose.suggestedFilename, respose.expectedContentLength);
    //
    //    HDLog(@"mutableURLRequest%@", mutableURLRequest);
    
    return data;
}


+ (NSDictionary *)jsonWithpostImage:(UIImage *)image
                          imageName:(NSString *)imageName
                          urlString:(NSString *)urlString
{
    NSData *data = [DDNetwork postImage:image imageName:imageName urlString:urlString];
    
    HDLog(@"<DDNetwork> Receive data:%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] );
    if (data == nil) {
        return nil;
    }
    NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    return resultDic;
}


+ (NSData *)postImage:(UIImage *)image
            imageName:(NSString *)imageName
            urlString:(NSString *)urlString
{
    NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uploadedfile\"; filename=\"%@\"\r\n", imageName] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imageData]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    NSURLResponse *respose = nil;
    NSError *error = nil;
    HDLog(@"<DDNetwork> postImage:%@", urlString);
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&respose error:&error];
    
    return data;
}

@end
