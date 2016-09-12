//
//  FileUtil.m
//  Sport
//
//  Created by haodong  on 13-8-15.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "FileUtil.h"
#import "LogUtil.h"
//#import "StringUtil.h"

#include <sys/stat.h>
#include <dirent.h>

@implementation FileUtil

+ (BOOL)createDir:(NSString*)dir
{
    // Check if the directory already exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:dir]) {
        // Directory does not exist so create it
        HDLog(@"create dir = %@", dir);
        
        NSError* error = nil;
        BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];
        if (result == NO){
            HDLog(@"create dir (%@) but error (%@)", dir, [error description]);
        }
        return result;
    }
    else{
        return YES;
    }
}

+ (NSString*)getAppDocumentDir
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDir = [paths objectAtIndex:0];
	
	return documentDir;
}

+ (NSString*)getAppCacheDir
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *retDir = [paths objectAtIndex:0];
	
	return retDir;
}

+ (NSString*)getAppTempDir
{
	return NSTemporaryDirectory();
}

+ (long long)clearOnlyFilesAtPath:(NSString*)folderPath{
    return [self clearFolderAtPath:[folderPath cStringUsingEncoding:NSUTF8StringEncoding]];
}

+ (long long)clearFolderAtPath: (const char*)folderPath{
    long long folderSize = 0;
    DIR* dir = opendir(folderPath);
    if (dir == NULL) return 0;
    struct dirent* child;
    while ((child = readdir(dir))!=NULL) {
        if (child->d_type == DT_DIR && (
                                        (child->d_name[0] == '.' && child->d_name[1] == 0) || // 忽略目录 .
                                        (child->d_name[0] == '.' && child->d_name[1] == '.' && child->d_name[2] == 0) // 忽略目录 ..
                                        )) continue;
        
        NSUInteger folderPathLength = strlen(folderPath);
        char childPath[1024]; // 子文件的路径地址
        stpcpy(childPath, folderPath);
        if (folderPath[folderPathLength-1] != '/'){
            childPath[folderPathLength] = '/';
            folderPathLength++;
        }
        stpcpy(childPath+folderPathLength, child->d_name);
        childPath[folderPathLength + child->d_namlen] = 0;
        if (child->d_type == DT_DIR){ // directory
            folderSize += [self clearFolderAtPath:childPath]; // 递归调用子目录
            // 把目录本身所占的空间也加上
            //            struct stat st;
            //            if(lstat(childPath, &st) == 0) folderSize += st.st_size;
        }else if (child->d_type == DT_REG || child->d_type == DT_LNK){ // file or link
            struct stat st;
            if(lstat(childPath, &st) == 0) folderSize += st.st_size;
            remove(childPath);
        }
    }
    return folderSize;
}


@end
