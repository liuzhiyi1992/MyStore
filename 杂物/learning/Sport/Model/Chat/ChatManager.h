//
//  ChatManager.h
//  Sport
//
//  Created by haodong  on 14-5-10.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatManager : NSObject

+ (id)defaultManager;

- (int)notReadCountWithGroupId:(NSString *)groupId chatCount:(int)chatCount;
- (void)saveGroupId:(NSString *)groupId chatCount:(int)chatCount;

@end
