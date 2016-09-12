//
//  PointGoods.h
//  Sport
//
//  Created by haodong  on 14/11/12.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

enum{
    PointGoodsTypeDraw = 1,     //抽奖
    PointGoodsTypeVoucher = 2,  //代金券
    PointGoodsTypePhysical = 3, //实物
    PointGoodsTypePoint = 4,    //积分
};

@interface PointGoods : NSObject

@property (copy, nonatomic) NSString *goodsId;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subTitle;
@property (copy, nonatomic) NSString *imageUrl;
@property (copy, nonatomic) NSString *desc;
@property (assign, nonatomic) int originalPoint;
@property (assign, nonatomic) int point;
@property (assign, nonatomic) int type;
@property (assign, nonatomic) NSUInteger joinTimes;

@end
