//
//  DayBookingInfo.m
//  Sport
//
//  Created by haodong  on 13-7-17.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "DayBookingInfo.h"
#import "Product.h"
#import "Court.h"
#import "CourtJoin.h"

@implementation DayBookingInfo

- (Product *)findProductWithProductId:(NSString *)productId
{
    for (Court *court in self.courtList) {
        for (Product *product in court.productList) {
            if ([productId isEqualToString:product.productId]) {
                return product;
            }
        }
    }
    return nil;
}

- (CourtJoin *)courtJoinWithProduct:(Product *)product {
    CourtJoin *cj = nil;
    for (CourtJoin *one in self.courtJoinlist) {
        if ([one.courtJoinId isEqualToString:product.courtJoinId]) {
            cj = one;
            break;
        }
    }
    return cj;
}

- (NSArray *)otherProductsOfSameCourtJoinWithProduct:(Product *)product {
    CourtJoin *cj = [self courtJoinWithProduct:product];
    
    NSMutableArray *array = [NSMutableArray array];
    for (Product *one in cj.productList) {
        if (![one.productId isEqualToString:product.productId]) {
            Product *realProduct = [self findProductWithProductId:one.productId];
            if (realProduct) {
                [array addObject:realProduct];
            }
        }
    }
    return array;
}

@end
