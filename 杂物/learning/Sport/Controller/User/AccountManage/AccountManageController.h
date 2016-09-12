//
//  AccountManageController.h
//  Sport
//
//  Created by haodong  on 13-7-31.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SportController.h"
#import "TitleValueCell.h"
#import "UserService.h"
#import "SNSService.h"
#import "QQManager.h"

@interface AccountManageController : SportController <UITableViewDataSource, UITableViewDelegate, TitleValueCellDelegate, UIAlertViewDelegate, UserServiceDelegate, SNSServiceDelegate, QQManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *dataTableView;


@end
