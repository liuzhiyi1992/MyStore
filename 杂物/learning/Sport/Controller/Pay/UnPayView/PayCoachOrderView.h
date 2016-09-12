//
//  PayCoachOrderView.h
//  Sport
//
//  Created by qiuhaodong on 15/7/25.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@class Order;

@interface PayCoachOrderView : UIView

+ (PayCoachOrderView *)createViewWithOrder:(Order *)order;

@end
