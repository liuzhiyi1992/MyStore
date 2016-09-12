//
//  DesUtil.h
//  Sport
//
//  Created by haodong  on 14-4-28.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DesUtil : NSObject

+ (NSString *)encryptUseDES:(NSString *)plainText
                        key:(NSString *)key
                         iv:(NSString *)iv;

+ (NSString *)decryptUseDES:(NSString *)cipherText
                        key:(NSString *)key
                         iv:(NSString *)iv;

@end
