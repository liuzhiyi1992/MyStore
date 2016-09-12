//
//  PayDefaultOrderView.h
//  Sport
//
//  Created by qiuhaodong on 15/6/11.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"

@interface PayDefaultOrderView : UIView

+ (PayDefaultOrderView *)createViewWithOrder:(Order *)order;

@end
