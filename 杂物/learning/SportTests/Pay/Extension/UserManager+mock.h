//
//  UserManager+mock.h
//  Sport
//
//  Created by 江彦聪 on 16/4/28.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UserManager.h"
@interface UserManager(mock)
+ (void)createMock;
+ (void)releaseMock;
@end
