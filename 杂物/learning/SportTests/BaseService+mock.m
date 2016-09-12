//
//  BaseService+mock.m
//  Sport
//
//  Created by 江彦聪 on 16/7/29.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "BaseService+mock.h"
#import <OCMock/OCMock.h>

@implementation BaseService (mock)
static BaseService *_mockBaseService = nil;
static BaseService *_baseService = nil;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
+ (BaseService *)defaultService {
    if (_mockBaseService) {
        return _mockBaseService;
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _baseService = [[BaseService alloc] init];
    });
    return _baseService;
}
#pragma clang diagnostic pop

+ (void)createMock {
    _mockBaseService = OCMClassMock([BaseService class]);
}

+ (void)releaseMock {
    _mockBaseService = nil;
}
@end
