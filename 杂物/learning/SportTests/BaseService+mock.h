//
//  BaseService+mock.h
//  Sport
//
//  Created by 江彦聪 on 16/7/29.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "BaseService.h"

@interface BaseService (mock)
+ (void)createMock;
+ (void)releaseMock;

@end
