//
//  SportHistoryController.h
//  Sport
//
//  Created by haodong  on 15/6/10.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportController.h"
#import "MonthCardService.h"

@interface SportHistoryController : SportController<UITableViewDelegate,UITableViewDataSource,MonthCardServiceDelegate>

@end
