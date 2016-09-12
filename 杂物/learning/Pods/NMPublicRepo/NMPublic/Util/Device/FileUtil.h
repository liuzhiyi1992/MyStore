//
//  FileUtil.h
//  Sport
//
//  Created by haodong  on 13-8-15.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileUtil : NSObject

+ (BOOL)createDir:(NSString*)dir;

+ (NSString*)getAppDocumentDir;

+ (NSString*)getAppCacheDir;

+ (NSString*)getAppTempDir;

+ (long long)clearOnlyFilesAtPath:(NSString*)folderPath;

@end
