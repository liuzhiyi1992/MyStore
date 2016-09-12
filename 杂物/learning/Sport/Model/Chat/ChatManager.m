//
//  ChatManager.m
//  Sport
//
//  Created by haodong  on 14-5-10.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "ChatManager.h"
#import "UserManager.h"

@interface ChatManager()
@property (strong, nonatomic) NSArray *groupIdAndCountList;
@end

static ChatManager *_globalChatManager = nil;

@implementation ChatManager


+ (id)defaultManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_globalChatManager == nil) {
            _globalChatManager = [[ChatManager alloc] init];
        }
    });
    return _globalChatManager;
}

- (NSString *)groupIdAndCountKey
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    return [NSString stringWithFormat:@"KEY_CHAT_GROUP_ID_AND_COUNT_%@", user.userId];
}

- (void)saveGroupIdAndCountList:(NSArray *)list
{
    self.groupIdAndCountList = list;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:list forKey:[self groupIdAndCountKey]];
    [defaults synchronize];
}

- (NSArray *)readGroupIdAndCountList
{
    if (_groupIdAndCountList == nil) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.groupIdAndCountList = [defaults objectForKey:[self groupIdAndCountKey]];
    }
    return _groupIdAndCountList;
}

#define KEY_GROUP_ID    @"group_id"
#define KEY_CHAT_COUNT  @"chat_count"
- (int)notReadCountWithGroupId:(NSString *)groupId chatCount:(int)chatCount
{
    int oldCount = 0;
    for (NSDictionary *dic in [self readGroupIdAndCountList]) {
        NSString *gid = [dic objectForKey:KEY_GROUP_ID];
        if ([groupId isEqualToString:gid]) {
            oldCount = [[dic objectForKey:KEY_CHAT_COUNT] intValue];
            break;
        }
    }
    int result = chatCount - oldCount;
    result = (result < 0 ? 0 : result);
    return result;
}

- (void)saveGroupId:(NSString *)groupId chatCount:(int)chatCount
{
    //去除已有的
    NSMutableArray *newList = [NSMutableArray array];
    for (NSDictionary *dic in [self readGroupIdAndCountList]) {
        NSString *gid = [dic objectForKey:KEY_GROUP_ID];
        if ([groupId isEqualToString:gid] == NO) {
            [newList addObject:dic];
        }
    }
    
    NSMutableDictionary *newDic = [NSMutableDictionary dictionary];
    [newDic setObject:groupId forKey:KEY_GROUP_ID];
    [newDic setObject:[NSString stringWithFormat:@"%d", chatCount] forKey:KEY_CHAT_COUNT];
    [newList addObject:newDic];
    [self saveGroupIdAndCountList:newList];
}

@end
