//
//  UUIDManager.m
//  
//  UUID 全局管理
//  Created by 江彦聪 on 16/1/11.
//
//

#import "UUIDManager.h"
#import "SportUUID.h"

static UUIDManager *_globalUUIDManager = nil;
@interface UUIDManager()
@property (strong, nonatomic) NSString *uuid;
@end


@implementation UUIDManager

+ (UUIDManager *)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _globalUUIDManager = [[UUIDManager alloc] init];
    });
    return _globalUUIDManager;
}

- (NSString *)readUUID {
    if ([self.uuid length] == 0) {
        self.uuid = [SportUUID uuid];
    }
    return self.uuid;
}

@end
