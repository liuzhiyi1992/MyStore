//
//  DayBookingInfo.h
//  Sport
//
//  Created by haodong  on 13-7-17.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@class Product;
@class CourtJoin;

@interface DayBookingInfo : NSObject

@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSArray *courtList;

@property (strong, nonatomic) NSArray *courtJoinlist; //注意:这个数据只是利用productId做关联，这里面的product信息不全，用product的信息时要用courtList里的product.

- (Product *)findProductWithProductId:(NSString *)productId;

- (CourtJoin *)courtJoinWithProduct:(Product *)product;

- (NSArray *)otherProductsOfSameCourtJoinWithProduct:(Product *)product;

@end
