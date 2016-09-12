//
//  UIAlertView+SportApplicationContext.m
//  Sport
//
//  Created by 江彦聪 on 16/5/20.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "UIAlertView+SportApplicationContext.h"
#import "SportApplicationContext.h"
#import <objc/runtime.h>

@implementation UIAlertView (SportApplicationContext)
+ (void)load {
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(show)), class_getInstanceMethod(self, @selector(st_show)));
}

- (void)st_show {
    SportApplicationContext *context = [SportApplicationContext sharedContext];
    NSHashTable *hashTable = context.alertViewHashTable;
    if ([hashTable isKindOfClass:[NSHashTable class]]) {
        [hashTable addObject:self];
    }
    [self st_show];
}
@end
