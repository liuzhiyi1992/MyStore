//
//  BusinessGoods.m
//  Sport
//
//  Created by 江彦聪 on 16/8/5.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "BusinessGoods.h"

@implementation BusinessGoods

- (id)copyWithZone:(nullable NSZone *)zone {
    BusinessGoods *goods = [[BusinessGoods allocWithZone:zone]init];
    goods.goodsId = [self.goodsId copyWithZone:zone];
    goods.name = [self.name copyWithZone:zone];
    goods.totalCount = self.totalCount;
    goods.price = self.price;
    goods.speci = [self.speci copyWithZone:zone];
    goods.limitCount = self.limitCount;
    
    return goods;
}

@end
