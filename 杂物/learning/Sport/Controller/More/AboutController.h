//
//  AboutController.h
//  Sport
//
//  Created by haodong  on 13-8-1.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SportController.h"

@interface AboutController : SportController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *businessCooperationLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *websiteLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
