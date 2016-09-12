//
//  Business.m
//  Sport
//
//  Created by haodong  on 13-6-20.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "Business.h"
#import "Goods.h"

@implementation ProductInfo

- (float)minSinglePrice
{
    float minPrice = 0;
    int index = 0;
    for (Goods *goods in _goodsList) {
        if (index == 0) {
            minPrice = goods.price;
        }
        
        if (goods.price < minPrice) {
            minPrice = goods.price;
        }
        
        index ++;
    }
    return minPrice;
}

@end

@implementation Business


- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.name forKey:@"name"];
    
    [encoder encodeObject:self.address forKey:@"address"];
    
    
    
    [encoder encodeDouble:self.price forKey:@"price"];
    [encoder encodeDouble:self.promotePrice forKey:@"promotePrice"];
    [encoder encodeDouble:self.rating forKey:@"rating"];
   [encoder encodeObject:self.businessId forKey:@"businessId"];
    
    [encoder encodeObject:self.defaultCategoryId forKey:@"defaultCategoryId"];
    

    
    
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        // 读取文件的内容
        self.name = [decoder decodeObjectForKey:@"name"];
        self.address = [decoder decodeObjectForKey:@"address"];
        self.price = [decoder decodeDoubleForKey:@"price"];
       self.businessId = [decoder decodeObjectForKey:@"businessId"];
        self.rating=[decoder decodeDoubleForKey:@"rating"];
        self.promotePrice = [decoder decodeDoubleForKey:@"promotePrice"];
        self.defaultCategoryId=[decoder decodeObjectForKey:@"defaultCategoryId"];
        
    }
    return self;
}

- (BOOL)isEqual:(Business *)other
{
    return [self.businessId isEqualToString:other.businessId];
}


@end
