//
//  SearchManager.h
//  Sport
//
//  Created by haodong  on 13-8-30.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchManager : NSObject

+ (BOOL)saveMaxTenSearchWords:(NSString *)searchWord;
+ (NSArray *)tenSearchWords;
+ (BOOL)clearTenSearchWords;

+ (BOOL)saveSearchWord:(NSString *)searchWord;
+ (NSArray *)allSearchWords;
+ (BOOL)clearAllSearchWords;

@end
