//
//  BusinessGoods.h
//  Sport
//
//  Created by 江彦聪 on 16/8/5.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "Goods.h"

@interface BusinessGoods : Goods<NSCopying>
@property (copy, nonatomic) NSString *speci;

@end
