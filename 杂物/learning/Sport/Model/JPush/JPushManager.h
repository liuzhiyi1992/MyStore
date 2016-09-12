//
//  JPushManager.h
//  Sport
//
//  Created by qiuhaodong on 16/2/20.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPushManager : NSObject

@property (assign, nonatomic) BOOL isLoginToJpush;

+ (instancetype)defaultManager;

- (void)setJPushTags;

@end
