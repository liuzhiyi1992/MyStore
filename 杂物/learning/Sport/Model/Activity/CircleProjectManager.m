//
//  CircleProjectManager.m
//  Sport
//
//  Created by haodong  on 14-3-11.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "CircleProjectManager.h"

@implementation CircleProject


@end


static CircleProjectManager *_globalCircleProjectManager = nil;

@implementation CircleProjectManager

+ (id)defaultManager
{
    if (_globalCircleProjectManager == nil) {
        _globalCircleProjectManager = [[CircleProjectManager alloc] init];
    }
    return _globalCircleProjectManager;
}


@end
