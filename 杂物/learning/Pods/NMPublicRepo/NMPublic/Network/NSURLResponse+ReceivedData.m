//
//  NSURLResponse+ReceivedData.m
//  Sport
//
//  Created by qiuhaodong on 16/6/30.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "NSURLResponse+ReceivedData.h"
#import <objc/runtime.h>

@implementation NSURLResponse (ReceivedData)

- (NSData *)receivedData
{
    return (NSData *)objc_getAssociatedObject(self, @selector(setReceivedData:));
}

- (void)setReceivedData:(NSData *)receivedData
{
    objc_setAssociatedObject(self, @selector(setReceivedData:), receivedData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
