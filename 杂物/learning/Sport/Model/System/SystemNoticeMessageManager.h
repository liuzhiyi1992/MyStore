//
//  SystemNoticeMessageManager.h
//  Sport
//
//  Created by haodong  on 14-5-17.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SystemNoticeMessageManager : NSObject
@property (assign, nonatomic) int allCountFromServer;

+ (id)defaultManager;

- (void)saveMessageCount:(int)messageCount;
- (int)readMessageCount;

@end
