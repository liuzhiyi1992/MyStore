//
//  SportNetwrok.h
//  Sport
//
//  Created by haodong  on 13-6-6.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+JsonValidValue.h"
#import "DDNetwork.h"

@interface SportNetwork : NSObject

+ (NSDictionary *)getJsonWithPrameterDictionary:(NSDictionary *)parameterDictionary;

+ (NSDictionary *)getJsonWithPrameterDictionary:(NSDictionary *)parameterDictionary urlString:(NSString *)urlString;

+ (NSDictionary *)postReturnJsonWithPrameterDictionary:(NSDictionary *)parameterDictionary;

+ (NSDictionary *)postReturnJsonWithPrameterDictionary:(NSDictionary *)parameterDictionary urlString:(NSString *)urlString;

+ (NSDictionary *)jsonWithpostImage:(UIImage *)image
                          imageName:(NSString *)imageName
                     basicUrlString:(NSString *)basicUrlString
                parameterDictionary:(NSDictionary *)parameterDictionary;

@end
