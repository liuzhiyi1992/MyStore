//
//  GSNetwork.h
//  GSNetwork
//
//  Created by qiuhaodong on 16/5/30.
//  Copyright © 2016年 qiuhaodong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSNetworkResponse.h"
#import "SportNetworkContent.h"
#import "NSDictionary+JsonValidValue.h"


typedef void(^GSNetworkResponseHandler)(GSNetworkResponse *response);

@interface GSNetwork : NSObject

+ (NSURLSessionTask *)getWithBasicUrlString:(NSString *)basicUrlString
                                 parameters:(NSDictionary *)parameters
                            responseHandler:(GSNetworkResponseHandler)responseHandler;

+ (NSURLSessionTask *)postWithBasicUrlString:(NSString *)basicUrlString
                                  parameters:(NSDictionary *)parameters
                             responseHandler:(GSNetworkResponseHandler)responseHandler;

+ (NSURLSessionTask *)postWithBasicUrlString:(NSString *)basicUrlString
                                  parameters:(NSDictionary *)parameters
                                       image:(UIImage *)image
                             responseHandler:(GSNetworkResponseHandler)responseHandler;

+ (NSArray *)allTasks;

@end
