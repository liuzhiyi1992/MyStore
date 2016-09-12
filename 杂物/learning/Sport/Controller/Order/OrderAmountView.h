//
//  OrderAmountView.h
//  Sport
//
//  Created by 江彦聪 on 15/4/14.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"
@interface OrderAmountView : UIView<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
+ (OrderAmountView *)createOrderAmountViewWithOrder:(Order *)order;
-(void)updateData:(Order *)order;
- (void)show;
@end
