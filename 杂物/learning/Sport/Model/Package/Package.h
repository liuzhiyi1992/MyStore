//
//  Package.h
//  Sport
//
//  Created by haodong  on 14/12/1.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Goods.h"

enum {
    PackageStatusSaleOut = 0,
    PackageStatusCanSale = 1,
    PackageStatusWaitSale = 2
};

@interface Package : Goods

@property (copy, nonatomic) NSString *promoteEndDateDesc;
@property (copy, nonatomic) NSString *imageUrl;
@property (assign, nonatomic) int status;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;

@end