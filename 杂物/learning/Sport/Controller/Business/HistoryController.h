//
//  HistoryController.h
//  Sport
//
//  Created by haodong  on 13-8-20.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SportController.h"

@interface HistoryController : SportController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *dataTableView;

@end
