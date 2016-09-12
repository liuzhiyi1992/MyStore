//
//  mineInfor.h
//  Sport
//
//  Created by 赵梦东 on 15/9/8.
//  Copyright (c) 2015年 haodong . All rights reserved.
//


@class OrderTips;

#import <Foundation/Foundation.h>

//order_notify	今日订单提醒
//my_order_tips
//我的订单

@interface MineInfo : NSObject

@property (copy, nonatomic)  NSString *nickName;

@property (copy, nonatomic)  NSString * gender;

@property (copy, nonatomic)  NSString *signature;

@property (copy, nonatomic)  NSString *avatar;

@property (copy, nonatomic) NSString *rulesTitle;
@property (copy, nonatomic) NSString *rulesIconUrl;
@property (copy, nonatomic) NSString *rulesIsDisplay;

@property (assign, nonatomic)  int buyedClub;

@property (copy, nonatomic)  NSString *clubEndTime;

@property (assign, nonatomic)  CGFloat money;

@property (assign, nonatomic)  int integral;
@property (assign, nonatomic)  int credit;
@property (assign, nonatomic)  int couponNumber;

@property (strong, nonatomic) NSMutableArray *orderNotify;

@property (strong, nonatomic) OrderTips *orderTips;

@end
