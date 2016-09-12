//
//  TypeConversion.h
//  Sport
//
//  Created by qiuhaodong on 16/5/14.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TypeConversion : NSObject

+ (NSString *)toStringFromDictionary:(NSDictionary *)dictionary;

+ (NSDictionary *)toDictionaryFromString:(NSString *)string;

@end
