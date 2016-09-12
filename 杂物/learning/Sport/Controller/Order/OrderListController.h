//
//  OrderListController.h
//  Sport
//
//  Created by haodong  on 13-7-29.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SportController.h"
#import "OrderService.h"
#import <MessageUI/MessageUI.h>
#import "OrderSimpleCell.h"

@interface OrderListController : SportController <UITableViewDelegate, UITableViewDataSource, OrderServiceDelegate, UIActionSheetDelegate, UIAlertViewDelegate, OrderSimpleCellDelegate>

@property (weak, nonatomic) IBOutlet UIButton *firstFilterButton;
@property (weak, nonatomic) IBOutlet UIButton *secondFilterButton;
@property (weak, nonatomic) IBOutlet UIButton *thirdFilterButton;
@property (weak, nonatomic) IBOutlet UIButton *unpaidTipsButton;
- (instancetype)initWithOpenIndex:(int)index;
@end
