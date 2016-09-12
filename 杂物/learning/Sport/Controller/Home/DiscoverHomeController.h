//
//  DiscoverHomeController.h
//  Sport
//
//  Created by xiaoyang on 16/5/10.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "SportController.h"

@interface DiscoverHomeController : SportController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *dataTableView;

@end
