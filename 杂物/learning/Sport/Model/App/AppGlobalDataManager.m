//
//  AppGlobalDataManager.m
//  Sport
//
//  Created by haodong  on 14/11/24.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "AppGlobalDataManager.h"

#import "SportNetworkContent.h"

static AppGlobalDataManager *_globalAppGlobalDataManager = nil;
@interface AppGlobalDataManager()

@end
@implementation AppGlobalDataManager
+ (AppGlobalDataManager *)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _globalAppGlobalDataManager = [[AppGlobalDataManager alloc] init];
        _globalAppGlobalDataManager.tokenReqList = @[VALUE_ACTION_GET_QYD_TOKEN,VALUE_ACTION_UNION_LOGIN,VALUE_ACTION_UNION_PHONE,VALUE_ACTION_LOGIN,VALUE_ACTION_QUICK_LOGIN,VALUE_ACTION_RESET_PASSWORD,VALUE_ACTION_UPDATE_PASSWORD,VALUE_ACTION_SET_PASSWORD,VALUE_ACTION_LOGOUT];
    });
    
    return _globalAppGlobalDataManager;
}

- (BOOL) isTokenRequest:(NSString *)action {
    for (NSString *tokenAction in self.tokenReqList) {
        if([action isEqualToString:tokenAction]) {
            return YES;
        }
    }
    return NO;

}
@end
