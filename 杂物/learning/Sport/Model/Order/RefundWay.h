//
//  RefundWay.h
//  Sport
//
//  Created by haodong  on 15/3/12.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RefundWay : NSObject

@property (copy, nonatomic) NSString *refundWayId;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subTitle;
@property (assign, nonatomic) BOOL isPayPassword;

@end
