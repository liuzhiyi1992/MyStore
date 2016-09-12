//
//  PaySingleOrderView.h
//  Sport
//
//  Created by qiuhaodong on 15/6/12.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"

@interface PaySingleOrderView : UIView

+ (PaySingleOrderView *)createViewWithOrder:(Order *)order;

@end
