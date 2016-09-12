//
//  DeviceDetection.h
//  
//
//  Created by haodong on 12-8-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/utsname.h>
#import <UIKit/UIKit.h>

enum {
	MODEL_UNKNOWN,
    MODEL_IPHONE_SIMULATOR,
    MODEL_IPOD_TOUCH,
	MODEL_IPOD_TOUCH_2G,
	MODEL_IPOD_TOUCH_3G,
	MODEL_IPOD_TOUCH_4G,
    MODEL_IPHONE,
	MODEL_IPHONE_3G,
	MODEL_IPHONE_3GS,
	MODEL_IPHONE_4G,
	MODEL_IPAD,
    MODEL_KNOWN
};

NSUInteger DeviceSystemMajorVersion();

@interface DeviceDetection : NSObject

+ (uint) detectDevice;
+ (int) detectModel;
+ (NSString *)platform;

+ (NSString *) returnDeviceName:(BOOL)ignoreSimulator;
+ (BOOL) isIPodTouch;
+ (BOOL) isOS4;
+ (BOOL) isOS5;
+ (BOOL) canSendSms;
+ (BOOL) isIPAD;

+ (NSString *)deviceOS;
+ (BOOL) isRetinaDisplay;



@end