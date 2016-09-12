//
//  FirstComment.m
//  Sport
//
//  Created by haodong  on 13-7-28.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "FirstComment.h"

@implementation FirstComment

- (void)dealloc
{
    [_replyList release];
    [super dealloc];
}

- (NSUInteger)notReadCount
{
    NSUInteger count = 0;
    for (Comment *reply in _replyList) {
        if (reply.isRead == NO) {
            count ++;
        }
    }
    return count;
}

@end
