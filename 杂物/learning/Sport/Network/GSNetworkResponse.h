//
//  GSNetworkResponse.h
//  Sport
//
//  Created by qiuhaodong on 16/5/28.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSNetworkResponse : NSObject

@property (readonly, nonatomic, strong) NSDictionary *jsonResult;
@property (readonly, nonatomic, strong) NSURLResponse *response;

- (instancetype)initWithJsonResult:(NSDictionary *)jsonResult
                          response:(NSURLResponse *)response;

@end
