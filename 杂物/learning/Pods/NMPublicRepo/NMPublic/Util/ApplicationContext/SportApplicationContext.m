//
//  SportApplicationContext.m
//  
//
//  Created by 江彦聪 on 16/5/20.
//
//

#import "SportApplicationContext.h"
#import <objc/runtime.h>
@implementation SportApplicationContext

static SportApplicationContext *_sharedContext;
+ (SportApplicationContext *)sharedContext {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ _sharedContext = [[SportApplicationContext alloc] init]; });
    return _sharedContext;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.alertViewHashTable = [NSHashTable weakObjectsHashTable];
        self.actionSheetHashTable = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (NSArray *)availableAlertViews {
    return [[self.alertViewHashTable allObjects] copy];
}

- (void)dismissAllAlertViews {
    if (self.availableAlertViews.count > 0) {
        [self.availableAlertViews enumerateObjectsUsingBlock:^(UIAlertView *obj, NSUInteger idx, BOOL *stop) {
            [obj dismissWithClickedButtonIndex:obj.cancelButtonIndex animated:NO];
        }];
    }
}


- (NSArray *)availableActionSheets {
    return [[self.actionSheetHashTable allObjects] copy];
}


- (void)dismissAllActionSheets {
    if (self.availableActionSheets.count > 0) {
        [self.availableActionSheets enumerateObjectsUsingBlock:^(UIAlertView *obj, NSUInteger idx, BOOL *stop) {
            [obj dismissWithClickedButtonIndex:-1 animated:NO];
        }];
    }
}


@end
