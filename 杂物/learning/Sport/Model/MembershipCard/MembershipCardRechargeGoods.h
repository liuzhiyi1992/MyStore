//
//  MembershipCardRechargeGoods.h
//  Sport
//
//  Created by haodong  on 15/4/27.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MembershipCardRechargeGoods : NSObject

@property (copy, nonatomic) NSString *goodsId;
@property (assign, nonatomic) float amount;
@property (assign, nonatomic) float giftAmount;
@property (copy, nonatomic) NSString *message;

@end
