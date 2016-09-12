//
//  ForumSearchManager.m
//  Sport
//
//  Created by haodong  on 15/5/14.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "ForumSearchManager.h"
#import "FileUtil.h"
#import "NSDictionary+JsonValidValue.h"

@implementation ForumSearchManager

#define SEARCH_STATIC_DATA_FILE_PATH [[FileUtil getAppDocumentDir] stringByAppendingString:@"/forun_search_static_data"]

/*搜索数据源
 data跟网络接口search_static_data的返回数据格式一致
 */
+ (BOOL)saveSourceData:(NSDictionary *)data
{
    HDLog(@"filePath:%@", SEARCH_STATIC_DATA_FILE_PATH);
    return [data writeToFile:SEARCH_STATIC_DATA_FILE_PATH atomically:YES];
}

+ (NSDictionary *)readSourceData
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:SEARCH_STATIC_DATA_FILE_PATH];
    return dictionary;
}

+ (BOOL)sourceDataFileExists
{
    return [[NSFileManager defaultManager] fileExistsAtPath:SEARCH_STATIC_DATA_FILE_PATH];
}

/*以下是搜索历史
 每个NSDictionary下得结构是
 {'i': '123', 'n':'东英圈', 'p':'dong ying quan', 'c':'广州'}
 */
#define SEARCH_HISTORY_FILE_PATH [[FileUtil getAppDocumentDir] stringByAppendingString:@"/forun_search_histroy"]
+ (BOOL)histroyAddForum:(NSDictionary *)forum
{
    NSMutableArray *array = [NSMutableArray array];
    [array addObjectsFromArray:[NSArray arrayWithContentsOfFile:SEARCH_HISTORY_FILE_PATH]];
    if ([array count] > 20) {
        [array removeLastObject];
    }
    
    //如果之前有保存过，则删除
    NSUInteger fundIndex = 0;
    BOOL found = NO;
    for (NSDictionary *one in array) {
        if ([[forum validStringValueForKey:@"i"] isEqualToString:[one validStringValueForKey:@"i"]]) {
            found = YES;
            break;
        }
        fundIndex ++;
    }
    if (found) {
        [array removeObjectAtIndex:fundIndex];
    }
    
    //插入一个
    [array insertObject:forum atIndex:0];
    return [array writeToFile:SEARCH_HISTORY_FILE_PATH atomically:YES];
}

+ (NSArray *)historyForumList
{
    NSArray *arry = [NSArray arrayWithContentsOfFile:SEARCH_HISTORY_FILE_PATH];
    return arry;
}

+ (BOOL)clearHistroy
{
    return [[NSArray array] writeToFile:SEARCH_HISTORY_FILE_PATH atomically:YES];
}


@end
