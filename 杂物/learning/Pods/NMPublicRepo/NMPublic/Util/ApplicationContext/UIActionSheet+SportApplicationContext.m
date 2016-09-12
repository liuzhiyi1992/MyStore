//
//  UIActionSheet+SportApplicationContext.m
//  Sport
//
//  Created by 江彦聪 on 16/5/20.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "UIActionSheet+SportApplicationContext.h"
#import "SportApplicationContext.h"
#import <objc/runtime.h>
@implementation UIActionSheet (SportApplicationContext)
+ (void)load {
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(showInView:)), class_getInstanceMethod(self, @selector(st_showInView:)));
}

- (void)st_showInView:(UIView *)view {
    SportApplicationContext *context = [SportApplicationContext sharedContext];
    NSHashTable *hashTable = context.actionSheetHashTable;
    if ([hashTable isKindOfClass:[NSHashTable class]]) {
        [hashTable addObject:self];
    }
    
    [self st_showInView:view];
}
@end
