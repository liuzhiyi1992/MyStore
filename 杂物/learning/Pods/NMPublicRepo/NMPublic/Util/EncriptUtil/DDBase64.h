//
//  DDBase64.h
//  Sport
//
//  Created by haodong  on 13-9-17.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTMBase64.h"

@interface DDBase64 : NSObject

+ (NSString*)encodeBase64String:(NSString*)input;
+ (NSString*)decodeBase64String:(NSString*)input;
+ (NSString*)encodeBase64Data:(NSData*)data;
+ (NSString*)decodeBase64Data:(NSData*)data;

+ (NSData*)toDataDecodeBase64String:(NSString*)input;

@end
