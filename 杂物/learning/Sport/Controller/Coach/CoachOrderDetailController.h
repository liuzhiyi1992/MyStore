//
//  CoachOrderDetailController.h
//  Sport
//
//  Created by 江彦聪 on 15/7/15.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportController.h"
#import "CoachService.h"
@class Order;

@interface CoachOrderDetailController : SportController<UITableViewDataSource,UITableViewDelegate,CoachServiceDelegate,UIAlertViewDelegate>

-(id)initWithOrder:(Order *)order;

@end
