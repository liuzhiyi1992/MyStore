//
//  PackageService.m
//  Sport
//
//  Created by haodong  on 14/11/28.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "PackageService.h"
#import "SportNetwork.h"
#import "Package.h"


@implementation PackageService

+ (Package *)packageWithDictionary:(NSDictionary *)one
{
    Package *package = [[Package alloc] init] ;
    
    package.goodsId = [one validStringValueForKey:PARA_GOODS_ID];
    package.name = [one validStringValueForKey:PARA_GOODS_NAME];
    package.price = [one validFloatValueForKey:PARA_PRICE];
    package.totalCount = [one validIntValueForKey:PARA_GOODS_NUMBER];
    package.limitCount = [one validIntValueForKey:PARA_LIMIT_NUMBER];
    
    package.promotePrice = [one validFloatValueForKey:PARA_PROMOTE_PRICE];
    package.promoteEndDateDesc = [one validStringValueForKey:PARA_PROMOTE_END_DATE];
    package.imageUrl = [one validStringValueForKey:PARA_IMAGE_URL];
    package.desc = [one validStringValueForKey:PARA_DESCRIPTION];
    package.detailUrl = [one validStringValueForKey:PARA_DETAIL_URL];
    
    package.businessName = [one validStringValueForKey:PARA_NAME];
    
    package.status = [one validIntValueForKey:PARA_STATUS];
    
    package.startDate = [NSDate dateWithTimeIntervalSince1970:[one validIntValueForKey:PARA_START_DATE]];
    package.endDate = [NSDate dateWithTimeIntervalSince1970:[one validIntValueForKey:PARA_END_DATE]];
    
    return package;
}

+ (void)queryPackageList:(id<PackageServiceDelegate>)delegate
                  cityId:(NSString *)cityId
                    page:(int)page
                   count:(int)count
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_GET_SALE_LIST forKey:PARA_ACTION];
        [inputDic setValue:cityId forKey:PARA_CITY_ID];
        [inputDic setValue:[NSString stringWithFormat:@"%d", page] forKey:PARA_PAGE];
        [inputDic setValue:[NSString stringWithFormat:@"%d", count] forKey:PARA_COUNT];
        
        //版本1.1，更改金额是float类型
        [inputDic setValue:@"1.1" forKey:PARA_VER];
        
        NSDictionary *resultDictionary  = [SportNetwork getJsonWithPrameterDictionary:inputDic];
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        id data = [resultDictionary validArrayValueForKey:PARA_DATA];
        
        NSMutableArray *packageList = [NSMutableArray array];
        if ([data isKindOfClass:[NSArray class]]) {
            for (id one in (NSArray *)data) {
                Package *package = [self packageWithDictionary:one];
                [packageList addObject:package];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([delegate respondsToSelector:@selector(didQueryPackageList:status:msg:)]) {
                [delegate didQueryPackageList:packageList status:status msg:msg];
            }
            
        });
    });
}

+ (void)queryPackage:(id<PackageServiceDelegate>)delegate
           packageId:(NSString *)packageId
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableDictionary *inputDic = [NSMutableDictionary dictionary];
        [inputDic setValue:VALUE_ACTION_GET_SALE_INFO forKey:PARA_ACTION];
        [inputDic setValue:packageId forKey:PARA_GOODS_ID];
        
        //版本1.1，更改金额是float类型
        [inputDic setValue:@"1.1" forKey:PARA_VER];
        
        NSDictionary *resultDictionary  = [SportNetwork getJsonWithPrameterDictionary:inputDic];
        
        NSString *status = [resultDictionary validStringValueForKey:PARA_STATUS];
        NSString *msg = [resultDictionary validStringValueForKey:PARA_MSG];
        
        Package *package = nil;
        
        id data = [resultDictionary validDictionaryValueForKey:PARA_DATA];
        if ([data isKindOfClass:[NSDictionary class]]) {
            package = [self packageWithDictionary:data];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([delegate respondsToSelector:@selector(didQueryPackage:status:msg:)]) {
                [delegate didQueryPackage:package status:status msg:msg];
            }
            
        });
    });
}

@end