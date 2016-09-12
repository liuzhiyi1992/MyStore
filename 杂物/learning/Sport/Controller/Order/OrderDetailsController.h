//
//  OrderDetailsController.h
//  Sport
//
//  Created by lzy on 16/8/1.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SportController.h"

@class Order;
@interface OrderDetailPlaceholderView : UIView
@property (assign, nonatomic) NSInteger margin;
@end



@interface OrderDetailsController : SportController
- (id)initWithOrder:(Order *)order;
- (id)initWithOrder:(Order *)order isReload:(BOOL)isReload;
@end
