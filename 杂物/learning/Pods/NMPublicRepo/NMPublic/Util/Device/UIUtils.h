//
//  UIUtils.h
//  
//
//  Created by haodong on 12-9-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIUtils : NSObject

+ (NSString*)getAppVersion;

+ (NSString*)getAppName;

+ (NSString*)getAppLink:(NSString*)appId;

+ (void)openApp:(NSString*)appId;

+ (void)gotoReview:(NSString*)appId;

+ (BOOL)makeCall:(NSString *)phoneNumber;

+ (BOOL)makePromptCall:(NSString *)phoneNumber;

+ (BOOL)checkHasNewVersionWithlocalVersion:(NSString *)localVersion
                             onlineVersion:(NSString *)onlineVersion;
							 
+ (BOOL) adjustScreenToShowOrHideKeyBoard:(UIView *)view
                               flag:(BOOL) flag
                             offset:(CGFloat)offset;
@end
