//
//  Product.h
//  Sport
//
//  Created by haodong  on 13-7-17.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    ProductStatusCanOrder = 0,    //可以订
    ProductStatusOrdered = 1,     //已出售
    ProductStatusCanNotOrder = 2  //不可订
}ProductStatus;

@interface Product : NSObject

@property (copy, nonatomic) NSString *productId;
@property (copy, nonatomic) NSString *startTime; //开始时间
@property (assign, nonatomic) float price;
@property (assign, nonatomic) int status;
@property (copy, nonatomic) NSString *courtId;   //场地id
@property (copy, nonatomic) NSString *courtName; //场地名称
@property (assign, nonatomic) float courtJoinPrice;

@property (copy, nonatomic) NSString *courtJoinId;   //球局id，如果不属于球局的则是nil
@property (assign, nonatomic) BOOL courtJoinCanBuy;  //球局是否可下单

//时间的小时
- (int)startTimeHour;

//时间的分钟
- (NSString *)startTimeMinuteString;

//时间段，例如12:30-13:30
- (NSString *)startTimeToEndTime;

- (BOOL)canBuy;

- (BOOL)isCourtJoinProduct;

+ (NSString *)courtDetailString:(NSArray *)list;

@end
