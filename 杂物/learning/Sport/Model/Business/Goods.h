//
//  Goods.h
//  Sport
//
//  Created by haodong  on 14-8-15.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

//price一定有，promotePrice不一定有

@interface Goods : NSObject

@property (copy, nonatomic) NSString *goodsId;
@property (copy, nonatomic) NSString *name;
@property (assign, nonatomic) float price;
@property (assign, nonatomic) float promotePrice;
@property (assign, nonatomic) int totalCount;
@property (assign, nonatomic) int limitCount;
@property (copy, nonatomic) NSString *desc;
@property (copy, nonatomic) NSString *detailUrl;
@property (copy, nonatomic) NSString *promoteMessage;
@property (copy, nonatomic) NSString *businessName;
@property (copy, nonatomic) NSString *isSupportClub;

- (float)validPrice;

@end
