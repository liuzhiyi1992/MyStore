//
//  SearchManager.m
//  Sport
//
//  Created by haodong  on 13-8-30.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SearchManager.h"


#define KEY_SEARCH_WORD     @"KEY_SEARCH_WORD"
#define KEY_SEARCH_TEN_WORD     @"KEY_SEARCH_TEN_WORD"

@implementation SearchManager
+ (BOOL)saveMaxTenSearchWords:(NSString *)searchWord{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:[self tenSearchWords]];
    if (mutableArray == nil || [mutableArray count] == 0) {
        mutableArray = [NSMutableArray array];
    } else {
        for (NSString *one in mutableArray) {
            if ([one isEqualToString:searchWord]) {
                [mutableArray removeObject:one];
                break;
            }
        }
    }
    [mutableArray insertObject:searchWord atIndex:0];
    if ([mutableArray count] > 10) {
        [mutableArray removeLastObject];
    }
    [userDefaults setObject:(NSArray *)mutableArray forKey:KEY_SEARCH_TEN_WORD];
    return [userDefaults synchronize];
}

+ (NSArray *)tenSearchWords{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return (NSArray *)[userDefaults objectForKey:KEY_SEARCH_TEN_WORD];
}

+ (BOOL)clearTenSearchWords{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nil forKey:KEY_SEARCH_TEN_WORD];
    return [userDefaults synchronize];
}




+ (BOOL)saveSearchWord:(NSString *)searchWord
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:[self allSearchWords]];
    if (mutableArray == nil || [mutableArray count] == 0) {
        mutableArray = [NSMutableArray array];
    } else {
        for (NSString *one in mutableArray) {
            if ([one isEqualToString:searchWord]) {
                [mutableArray removeObject:one];
                break;
            }
        }
    }
    [mutableArray insertObject:searchWord atIndex:0];
    if ([mutableArray count] > 30) {
        [mutableArray removeLastObject];
    }
    [userDefaults setObject:(NSArray *)mutableArray forKey:KEY_SEARCH_WORD];
    return [userDefaults synchronize];
}

+ (NSArray *)allSearchWords
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return (NSArray *)[userDefaults objectForKey:KEY_SEARCH_WORD];
}

+ (BOOL)clearAllSearchWords
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nil forKey:KEY_SEARCH_WORD];
    return [userDefaults synchronize];
}

@end
