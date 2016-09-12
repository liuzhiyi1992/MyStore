//
//  OrderDetailPayInventoryView.h
//  Sport
//
//  Created by lzy on 16/8/1.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@class Order;
@interface OrderDetailPayInventoryView : UIView
+ (OrderDetailPayInventoryView *)createViewWithOrder:(Order *)order;
@end
