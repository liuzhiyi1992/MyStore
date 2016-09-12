//
//  ForumCacheManager.h
//  Sport
//
//  Created by qiuhaodong on 15/5/19.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

/*
  缓存需求：
 1.缓存热门帖子前面二十条
 2.缓存圈子首页前面二十条
 3.缓存最近打开的十个圈子详情（即帖子列表）
 */

#import <Foundation/Foundation.h>

@interface ForumCacheManager : NSObject

+ (NSString *)saveResultDictionary:(NSDictionary *)resultDictionary
                    inputDictionay:(NSDictionary *)inputDictionay;

+ (NSDictionary *)readResultDictionaryWithInputDictionay:(NSDictionary *)inputDictionay;

+ (void)addOneForumDetailCacheFilePath:(NSString *)filePath;

@end
