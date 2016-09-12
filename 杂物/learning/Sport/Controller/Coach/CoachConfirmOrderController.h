//
//  CoachConfirmOrderController.h
//  Sport
//
//  Created by qiuhaodong on 15/7/24.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportController.h"
#import "OrderConfirmPriceView.h"

@class CoachOftenArea;
@interface CoachConfirmOrderController : SportController

- (instancetype)initWithCoachId:(NSString *)coachId
                        goodsId:(NSString *)goodsId
                      startTime:(NSDate *)startTime
                        address:(CoachOftenArea *)address;


@property (strong, nonatomic) OrderConfirmPriceView *orderConfirmPriceView;
@end
