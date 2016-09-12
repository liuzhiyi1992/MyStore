//
//  ForumSearchManager.h
//  Sport
//
//  Created by haodong  on 15/5/14.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ForumSearchManager : NSObject

+ (BOOL)saveSourceData:(NSDictionary *)data;
+ (NSDictionary *)readSourceData;
+ (BOOL)sourceDataFileExists;

+ (BOOL)histroyAddForum:(NSDictionary *)forum;
+ (NSArray *)historyForumList;
+ (BOOL)clearHistroy;


@end
