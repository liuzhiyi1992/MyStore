//
//  GSNetworkResponse.m
//  Sport
//
//  Created by qiuhaodong on 16/5/28.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "GSNetworkResponse.h"

@interface GSNetworkResponse()

@property (readwrite, nonatomic, strong) NSDictionary *jsonResult;
@property (readwrite, nonatomic, strong) NSURLResponse *response;

@end


@implementation GSNetworkResponse

- (instancetype)initWithJsonResult:(NSDictionary *)jsonResult
                          response:(NSURLResponse *)response
{
    self = [super init];
    if (self) {
        self.jsonResult = jsonResult;
        self.response = response;
    }
    return self;
}

@end
