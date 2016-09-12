//
//  UserManager+mock.m
//  Sport
//
//  Created by 江彦聪 on 16/4/28.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "UserManager+mock.h"

#import <OCMock/OCMock.h>
@implementation UserManager(mock)
static UserManager *_mockglobalUserManager = nil;
static UserManager *_globalUserManager = nil;

+ (UserManager *)defaultManager
{
    if(_mockglobalUserManager) {
        return _mockglobalUserManager;
    }
    
    if (_globalUserManager == nil) {
        _globalUserManager  = [[UserManager alloc] init];
    }
    return _globalUserManager;
}


+ (void)createMock {
    _mockglobalUserManager = OCMClassMock([UserManager class]);
}

+ (void)releaseMock {
    _mockglobalUserManager = nil;
}
@end
