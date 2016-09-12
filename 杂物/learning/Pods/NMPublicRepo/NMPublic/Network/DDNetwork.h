//
//  DDNetwork.h
//  TestURLConnection
//
//  Created by haodong  on 13-6-5.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef enum
{
    PostTypeString = 0,
    PostTypeJson = 1,
}PostType;

@interface DDNetwork : NSObject

+ (NSDictionary *)getReturnJsonWithBasicUrlString:(NSString *)basicUrlString
                              parameterDictionary:(NSDictionary *)parameterDictionary;

+ (NSDictionary *)postReturnJsonWithBasicUrlString:(NSString *)basicUrlString
                               parameterDictionary:(NSDictionary *)parameterDictionary
                                          postType:(PostType)postType;

+ (NSDictionary *)jsonWithpostImage:(UIImage *)image
                          imageName:(NSString *)imageName
                          urlString:(NSString *)urlString;

@end
