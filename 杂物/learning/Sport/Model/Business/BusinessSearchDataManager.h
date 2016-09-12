//
//  BusinessSearchDataManager.h
//  Sport
//
//  Created by 冯俊霖 on 15/11/4.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BusinessSearchDataManager : NSObject
+ (BusinessSearchDataManager *)defaultManager;

- (void)DownloadTextFile:(NSString*)fileUrl cityID:(NSString*)cityID;
- (NSArray *)analysisSourceData;
@end
