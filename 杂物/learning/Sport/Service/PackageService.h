//
//  PackageService.h
//  Sport
//
//  Created by haodong  on 14/11/28.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SportNetworkContent.h"

@class Package;

@protocol PackageServiceDelegate <NSObject>
@optional

- (void)didQueryPackageList:(NSArray *)list
                     status:(NSString *)status
                        msg:(NSString *)msg;

- (void)didQueryPackage:(Package *)package
                 status:(NSString *)status
                    msg:(NSString *)msg;
@end


@interface PackageService : NSObject

+ (void)queryPackageList:(id<PackageServiceDelegate>)delegate
                  cityId:(NSString *)cityId
                    page:(int)page
                   count:(int)count;

+ (void)queryPackage:(id<PackageServiceDelegate>)delegate
           packageId:(NSString *)packageId;

@end