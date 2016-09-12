//
//  OtherController.h
//  Sport
//
//  Created by haodong  on 14-5-3.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SportController.h"
#import "UserService.h"
#import "UserInfoCell.h"
#import "TicketService.h"
#import "MineService.h"


@interface OtherController : SportController<UITableViewDataSource, UITableViewDelegate, UserServiceDelegate, UserInfoCellDelegate, UIAlertViewDelegate, UIActionSheetDelegate,TicketServiceDelegate,MineServiceDelegate>
@property (weak, nonatomic) IBOutlet UIView *picHeader;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;

@property (weak, nonatomic) IBOutlet UITableView *dataTableView;
@property (weak, nonatomic) IBOutlet UIButton *headerButton;


- (IBAction)logInButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *headerInfoView;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *dongButton;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *jiFenLabel;
@property (weak, nonatomic) IBOutlet UILabel *kaQuanLabel;

@end
