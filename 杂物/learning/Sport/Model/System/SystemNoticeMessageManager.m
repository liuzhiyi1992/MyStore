//
//  SystemNoticeMessageManager.m
//  Sport
//
//  Created by haodong  on 14-5-17.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SystemNoticeMessageManager.h"
#import "UserManager.h"

#define KEY_SYSTEM_NOTICEMESSAGE_COUNT @"KEY_SYSTEM_NOTICEMESSAGE_COUNT"

@interface SystemNoticeMessageManager()
@property (copy, nonatomic) NSString *currentMessageCount;
@end

static SystemNoticeMessageManager *_globalSystemNoticeMessageManager = nil;

@implementation SystemNoticeMessageManager


+ (id)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _globalSystemNoticeMessageManager = [[SystemNoticeMessageManager alloc] init];
    });
    return _globalSystemNoticeMessageManager;
}

- (NSString *)messageCountKey
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    return [NSString stringWithFormat:@"%@_%@",KEY_SYSTEM_NOTICEMESSAGE_COUNT,  user.userId];
}

- (void)saveMessageCount:(int)messageCount
{
    self.currentMessageCount = [NSString stringWithFormat:@"%d", messageCount];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_currentMessageCount forKey:[self messageCountKey]];
    [defaults synchronize];
}

- (int)readMessageCount
{
    if (_currentMessageCount == nil) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.currentMessageCount = [defaults objectForKey:[self messageCountKey]];
    }
    return [_currentMessageCount intValue];
}

@end
