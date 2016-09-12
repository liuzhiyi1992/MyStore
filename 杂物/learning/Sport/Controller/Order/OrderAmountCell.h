//
//  OrderAmountCell.h
//  Sport
//
//  Created by 江彦聪 on 15/4/14.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDTableViewCell.h"
#import "Order.h"

enum OrderAmountType{
    OrderTotalAmount = 0, //总计
    OrderPromoteAmount,   //优惠
    OrderMoneyAmount,     //余额支付
    OrderPayAmount,       //支付余额
};

typedef enum OrderAmountType OrderAmountType;
const NSArray *___OrderAmountType;

// 创建初始化函数。等于用宏创建一个getter函数
#define OrderAmountTypeGet (___OrderAmountType == nil ? ___OrderAmountType = [[NSArray alloc] initWithObjects:\
@"总计",\
@"优惠",\
@"余额支付",\
@"支付余额",\
nil] : ___OrderAmountType)
// 枚举 to 字串
#define OrderAmountTypeString(type) ([OrderAmountTypeGet objectAtIndex:type])
// 字串 to 枚举
#define OrderAmountTypeEnum(string) ([OrderAmountTypeGet indexOfObject:string])


@interface OrderAmountCell : DDTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
- (void)updateCellWithTitle:(NSString *)title
                     amount:(NSString *)ammount
                  indexPath:(NSIndexPath *)indexPath;
@end
