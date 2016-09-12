//
//  ForumCacheManager.m
//  Sport
//
//  Created by qiuhaodong on 15/5/19.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "ForumCacheManager.h"
#import "FileUtil.h"
#import "NSString+Utils.h"

@implementation ForumCacheManager

//记得每添加一个路径时，在删除缓存的功能添加一个功能
#define FORUM_CACHE_DIR [[FileUtil getAppCacheDir] stringByAppendingString:@"/com.qiuhaodong.sport.ForumCache/"]

//缓存的目录
+ (NSString *)forumCacheDirectory
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:FORUM_CACHE_DIR]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:FORUM_CACHE_DIR withIntermediateDirectories:YES attributes:nil error:&error];
    }
    HDLog(@"path:%@", FORUM_CACHE_DIR);
    return FORUM_CACHE_DIR;
}

//根据字典生成文件名，生成规则：排序拼接，然后生成md5
+ (NSString *)fileNameWithinputDictionay:(NSDictionary *)inputDictionay
{
    NSArray *keyList = [inputDictionay allKeys];
    NSArray *sortedKeyList = [keyList sortedArrayWithOptions:NSSortStable
                                             usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                                 NSString *item1 = (NSString *)obj1;
                                                 NSString *item2 = (NSString *)obj2;
                                                 return [item1 compare:item2];
                                             }];
    NSMutableString *source = [NSMutableString stringWithString:@""];
    for (NSString *key in sortedKeyList) {
        [source appendFormat:@"%@=%@&", key, [inputDictionay objectForKey:key]];
    }
    NSString *fileName = [source md5];
    return fileName;
}

//缓存
+ (NSString *)saveResultDictionary:(NSDictionary *)resultDictionary
                    inputDictionay:(NSDictionary *)inputDictionay
{
    NSString *fileName = [self fileNameWithinputDictionay:inputDictionay];
    NSString *filePath = [[self forumCacheDirectory] stringByAppendingString:fileName];
    [resultDictionary writeToFile:filePath atomically:YES];
    return filePath;
}

//读缓存
+ (NSDictionary *)readResultDictionaryWithInputDictionay:(NSDictionary *)inputDictionay
{
    NSString *fileName = [self fileNameWithinputDictionay:inputDictionay];
    if (fileName == nil) {
        return nil;
    }
    NSString *filePath = [[self forumCacheDirectory] stringByAppendingString:fileName];
    NSDictionary *result = [NSDictionary dictionaryWithContentsOfFile:filePath];
    return result;
}

#define forum_detail_cache_file_path_list @"forum_detail_cache_file_path_list"
+ (BOOL)saveForumDetailCacheFilePathList:(NSArray *)pathList
{
    NSString *filePath = [[self forumCacheDirectory] stringByAppendingString:forum_detail_cache_file_path_list];
    return [pathList writeToFile:filePath atomically:YES];
}

+ (NSArray *)readForumDetailCacheFilePathList
{
    NSString *filePath = [[self forumCacheDirectory] stringByAppendingString:forum_detail_cache_file_path_list];
    NSArray *array = [NSArray arrayWithContentsOfFile:filePath];
    return array;
}

+ (void)addOneForumDetailCacheFilePath:(NSString *)filePath
{
    NSMutableArray *list = [NSMutableArray arrayWithArray:[self readForumDetailCacheFilePathList]];
    
    //查找之前是否有相同文件名
    BOOL found = NO;
    for (NSString *one in list) {
        if ([filePath isEqualToString:one]) {
            found = YES;
        }
    }
    if (found) {
        return;
    }
    
    //最多缓存20个圈子详情
    if ([list count] >= 20) {
        NSString *last = [list lastObject];
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:last error:&error];
        [list removeLastObject];
    }
    [list insertObject:filePath atIndex:0];
    [self saveForumDetailCacheFilePathList:list];
}

@end
