//
//  FirstComment.h
//  Sport
//
//  Created by haodong  on 13-7-28.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "Comment.h"

@interface FirstComment : Comment

@property (retain, nonatomic) NSArray *replyList;

@property (assign, nonatomic) BOOL isTipsNotRead;

- (NSUInteger)notReadCount;

@end
