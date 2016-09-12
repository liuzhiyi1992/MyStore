//
//  HistoryManager.h
//  Sport
//
//  Created by haodong  on 13-8-15.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@class Business;

@interface HistoryManager : NSObject
/**
 *  返回最近浏览的记录
 */
@property (nonatomic, strong, readonly) NSMutableArray *historyBusiness;

+ (HistoryManager *)defaultManager;

- (NSArray*)findAllBusinesses;
//- (void)deleteBusiness:(Business *)business;
- (void)saveBusiness:(Business *)business;
- (void)deleteAllBusinesses;

@end
