//
//  SportApplicationContext.h
//  
//
//  Created by 江彦聪 on 16/5/20.
//
//

#import <Foundation/Foundation.h>

@interface SportApplicationContext : NSObject
+ (SportApplicationContext *)sharedContext;
/// 目前存在的所有UIAlertView
@property(nonatomic, copy, readonly) NSArray *availableAlertViews;
@property (nonatomic, strong) NSHashTable *alertViewHashTable;
@property (nonatomic, strong) NSHashTable *actionSheetHashTable;
- (void)dismissAllAlertViews;
- (void)dismissAllActionSheets;
@end
