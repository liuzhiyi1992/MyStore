//
//  BusinessSearchDataManager.m
//  Sport
//
//  Created by 冯俊霖 on 15/11/4.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "BusinessSearchDataManager.h"
#import "FileUtil.h"
#import "SSZipArchive.h"

@implementation BusinessSearchDataManager

#define BUSINESS_SEARCH_STATIC_DATA_FILE_ZIP_PATH [[FileUtil getAppDocumentDir] stringByAppendingString:@"/business_search_static_data_zip"]
#define BUSINESS_SEARCH_STATIC_DATA_FILE_JSON_PATH [[FileUtil getAppDocumentDir] stringByAppendingString:@"/business_search_static_data_json"]

static BusinessSearchDataManager *_BusinessSearchDataManager = nil;
+ (BusinessSearchDataManager *)defaultManager
{
    if (_BusinessSearchDataManager == nil) {
        _BusinessSearchDataManager = [[BusinessSearchDataManager alloc] init];
    }
    return _BusinessSearchDataManager;
}

- (void)DownloadTextFile:(NSString*)fileUrl cityID:(NSString *)cityID{
    NSString *filePath = [NSString stringWithFormat:@"%@_%@",BUSINESS_SEARCH_STATIC_DATA_FILE_ZIP_PATH,cityID];
    NSURL *url = [NSURL URLWithString:fileUrl];
    NSData *data = [NSData dataWithContentsOfURL:url];
    [data writeToFile:filePath atomically:YES];//将NSData类型对象data写入文件，文件名为FileName
    [SSZipArchive unzipFileAtPath:filePath toDestination:
    [NSString stringWithFormat:@"%@_%@",BUSINESS_SEARCH_STATIC_DATA_FILE_JSON_PATH,cityID]];
}

- (NSArray *)analysisSourceData{
    NSString *cityID = [[NSUserDefaults standardUserDefaults] objectForKey:@"SEARCHCITYID"];
    NSString *path = [NSString stringWithFormat:@"%@_%@",BUSINESS_SEARCH_STATIC_DATA_FILE_JSON_PATH,cityID];
    NSString *JsonPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"st_%@.json",cityID]];
    NSData *JsonData = [NSData dataWithContentsOfFile:JsonPath];
    id JsonObject;
    if (JsonData) {
       JsonObject  = [NSJSONSerialization JSONObjectWithData:JsonData options:NSJSONReadingAllowFragments error:nil];
    }
    return [NSArray arrayWithArray:JsonObject];
}

@end
