//
//  NSURLResponse+ReceivedData.h
//  Sport
//
//  Created by qiuhaodong on 16/6/30.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLResponse (ReceivedData)

- (NSData *)receivedData;

- (void)setReceivedData:(NSData *)receivedData;

@end
