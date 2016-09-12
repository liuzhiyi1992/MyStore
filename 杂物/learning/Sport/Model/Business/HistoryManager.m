//
//  HistoryManager.m
//  Sport
//
//  Created by haodong  on 13-8-15.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "HistoryManager.h"
#import "Business.h"
#import "FileUtil.h"

#define historyBusinessFile [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"business_history_v1.1.dat"]
static HistoryManager *_globalHistoryManager = nil;

@interface HistoryManager()

{
    NSMutableArray *_historyBusiness;
    
}

@end

@implementation HistoryManager

- (NSMutableArray *)historyBusiness
{
    if (!_historyBusiness) {
        _historyBusiness = [NSKeyedUnarchiver unarchiveObjectWithFile:historyBusinessFile];
        
        if (!_historyBusiness) {
            _historyBusiness = [NSMutableArray array];
        }
    }
    return _historyBusiness;
}


+ (HistoryManager *)defaultManager
{
    if (_globalHistoryManager == nil) {
        _globalHistoryManager = [[HistoryManager alloc] init];
    }
    return _globalHistoryManager;
}
- (NSArray*)findAllBusinesses
{
    return self.historyBusiness;
}


- (void)deleteAllBusinesses
{
    [self.historyBusiness removeAllObjects];
    
    // 存进沙盒
    [NSKeyedArchiver archiveRootObject:self.historyBusiness toFile:historyBusinessFile];
}


#define MAX_BUSINESS_HISTORY_COUNT   10
- (void)saveBusiness:(Business *)business
{
    if (business == nil) {
        return;
    }
    
   [self.historyBusiness removeObject:business];
    
    [self.historyBusiness insertObject:business atIndex:0];
    if ([self.historyBusiness count] > MAX_BUSINESS_HISTORY_COUNT) {
        [self.historyBusiness removeLastObject];
    }
     [NSKeyedArchiver archiveRootObject:self.historyBusiness toFile:historyBusinessFile];
}

@end
