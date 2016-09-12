//
//  JPushManager.m
//  Sport
//
//  Created by qiuhaodong on 16/2/20.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "JPushManager.h"
#import "CityManager.h"
#import "JPUSHService.h"
#import "GSJPushService.h"
#import "UserManager.h"
#import "SportUUID.h"
#import "UIUtils.h"

@interface JPushManager()<GSJPushServiceDelegate>
@property (assign, nonatomic) int failCount;
@property (copy, nonatomic) NSString *tagsString;
@end

static JPushManager *_globalJPushManager = nil;

@implementation JPushManager

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_globalJPushManager == nil) {
            _globalJPushManager = [[JPushManager alloc] init];
        }
    });
    return _globalJPushManager;
}

//极光推送设置标签
- (void)setJPushTags {
    NSString *currentVersion = [UIUtils getAppVersion];
    self.failCount = 0;
    NSSet *tags = [NSSet setWithObjects:[NSString stringWithFormat:@"%@c_%@", JPUSH_SETTAG_PREFIX, [CityManager readCurrentCityId]],[NSString stringWithFormat:@"%@v_%@", JPUSH_SETTAG_PREFIX, [currentVersion stringByReplacingOccurrencesOfString:@"." withString:@"_"]], nil];
    [JPUSHService setTags:tags
      callbackSelector:@selector(tagsAliasCallback:tags:alias:)
                object:self];
}

// 极光推送设置标签之后的回调
- (void)tagsAliasCallback:(int)iResCode
                     tags:(NSSet *)tags
                    alias:(NSString *)alias {
    //只有call back 返回值为 0 才设置成功
    if (iResCode == 0) {
        NSArray *array = [tags allObjects];
        if (array.count == 2) {
            self.tagsString = [NSString stringWithFormat:@"%@,%@",array[1],array[0]];
        }
        [self addTagToQuyundong];
    } else{
        if (self.isLoginToJpush) {
            [self setJPushTags];
        }
    }
}

- (void)addTagToQuyundong {
    [GSJPushService addJpushTag:self
                       userId:[[UserManager defaultManager] readCurrentUser].userId
                         tags:self.tagsString
               registrationId:[JPUSHService registrationID]
                     deviceId:[SportUUID uuid]];
}

// 向服务器推送设置标签之后的回调
- (void)didAddJpushTagWithStatus:(NSString *)status msg:(NSString *)msg {
    if ([status isEqualToString: STATUS_SUCCESS]) {
        self.failCount = 0;
    }else{
        self.failCount += 1;
        if (self.failCount < 10) {
            
            [self performSelector:@selector(addTagToQuyundong) withObject:nil afterDelay:2];
        }
    }
}

@end
