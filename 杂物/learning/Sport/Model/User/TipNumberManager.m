//
//  TipNumberManager.m
//  Sport
//
//  Created by haodong  on 13-11-7.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "TipNumberManager.h"
#import <Objc/runtime.h>

static TipNumberManager *_globalTipNumberManager = nil;

@implementation TipNumberManager

+ (TipNumberManager *)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_globalTipNumberManager == nil) {
            _globalTipNumberManager  = [[TipNumberManager alloc] init];
            [_globalTipNumberManager addObserverForAllProperties];
            
        }
    });
    return _globalTipNumberManager;
}

- (void)clearAllCount
{
    self.userMessageCount = 0;
    self.chatMessageCount = 0;
    self.needPayOrderCount = 0;
    self.voucherCount = 0;
    self.canCommentCount = 0;
    self.forumMessageCount = 0;
    self.imReceiveMessageCount = 0;
    self.readyBeginCount = 0;
    self.newCardCount = 0;
    self.customerServiceMessageCount = 0; //客服消息数
    self.salesMessageCount = 0;     //优惠消息数
    self.systemMessageCount = 0;   //系统消息数
    self.cardChangeCount = 0;
}

-(void)setMessageCount:(MessageCountType)type
                 count:(NSUInteger)count
{
    switch (type) {
        case MessageCountTypeUser:
            self.userMessageCount = count;
            break;
            
        case MessageCountTypeChat:
            self.chatMessageCount = count;
            break;
            
        case MessageCountTypeNeedPayOrder:
            self.needPayOrderCount = count;
            break;
            
        case MessageCountTypeVoucher:
            self.voucherCount = count;
            break;
            
        case MessageCountTypeBroadcast:
            self.broadcastCount = count;
            break;
            
        case MessageCountTypeCanComment:
            self.canCommentCount = count;
            break;
            
        case MessageCountTypeForum:
            self.forumMessageCount = count;
            break;
            
        case MessageCountTypeReadyBegin:
            self.readyBeginCount = count;
            break;
            
        case MessageCountTypeNewCard:
            self.newCardCount = count;
            break;

        case MessageCountTypeCustomService:
            self.customerServiceMessageCount = count;
            break;
            
        case MessageCountTypeSales:
            self.salesMessageCount = count;
            break;
            
        case MessageCountTypeSystem:
            self.systemMessageCount = count;
            break;
        case MessageCountTypeCardChange:
            self.cardChangeCount = count;
            break;
        default:
            break;
    }
}

-(NSUInteger)getMessageCount:(MessageCountType)type
{
    NSUInteger count = 0;
    switch (type) {
        case MessageCountTypeUser:
            count = self.userMessageCount;
            break;
            
        case MessageCountTypeChat:
            count = self.chatMessageCount;
            break;
            
        case MessageCountTypeNeedPayOrder:
            count = self.needPayOrderCount;
            break;
            
        case MessageCountTypeVoucher:
            count = self.voucherCount;
            break;
            
        case MessageCountTypeBroadcast:
            count = self.broadcastCount;
            break;
            
        case MessageCountTypeCanComment:
            count = self.canCommentCount;
            break;
            
        case MessageCountTypeReadyBegin:
            count = self.readyBeginCount;
            break;
            
        case MessageCountTypeNewCard:
            count = self.newCardCount;
            break;
        case MessageCountTypeForum:
            count = self.forumMessageCount;
            break;

        case MessageCountTypeCustomService:
            count = self.customerServiceMessageCount;
            break;
            
        case MessageCountTypeSales:
            count = self.salesMessageCount;
            break;
            
        case MessageCountTypeSystem:
            count = self.systemMessageCount;
            break;
            
        case MessageCountTypeCardChange:
            count = self.cardChangeCount;
            break;
        default:
            break;
    }
    
    return count;
}

-(void)addObserverForAllProperties {
    [self addObserverForAllProperties:self
                              options:(NSKeyValueObservingOptionNew |NSKeyValueObservingOptionOld)
                              context:NULL];
}

- (void)addObserverForAllProperties:(NSObject *)observer
                            options:(NSKeyValueObservingOptions)options
                            context:(void *)context {
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (size_t i = 0; i < count; ++i) {
        NSString *key = [NSString stringWithCString:property_getName(properties[i]) encoding:NSASCIIStringEncoding];
        [self addObserver:observer forKeyPath:key
                  options:options context:context];
    }
    free(properties);
}

-(void)removeObserverForAllProperties{
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (size_t i = 0; i < count; ++i) {
        NSString *key = [NSString stringWithCString:property_getName(properties[i]) encoding:NSASCIIStringEncoding];
        [self removeObserver:self forKeyPath:key context:nil];
    }
    free(properties);
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([object isKindOfClass:[TipNumberManager class]]) {
        int oldValue = [(NSNumber *)[change objectForKey:@"old"] intValue];
        int newValue = [(NSNumber *)[change objectForKey:@"new"] intValue];
        if (oldValue != newValue) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_CHANGE_TIPS_COUNT object:nil userInfo:nil];
        }
    }
}

@end
