//
//  CoachOrderListController.h
//  Sport
//
//  Created by 江彦聪 on 15/5/19.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportController.h"
#import "CoachOrderListCell.h"
#import "CoachService.h"

@interface CoachOrderListController : SportController<UITableViewDataSource,UITableViewDelegate,CoachServiceDelegate, CoachOrderListCellDelegate>

@end
