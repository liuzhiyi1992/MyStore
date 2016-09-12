//
//  SystemMessageCenterController.m
//  Sport
//
//  Created by 江彦聪 on 15/10/8.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "SystemMessageCenterController.h"
#import "SystemMessageImageCell.h"
#import "SystemMessageTextCell.h"

#import "UIScrollView+SportRefresh.h"
#import "UITableView+FDTemplateLayoutCell.h"

#import "UserService.h"
#import "UserManager.h"
#import "SportPopupView.h"
#import "BusinessDetailController.h"
#import "PostDetailController.h"
#import "SportWebController.h"
#import "MyVouchersController.h"
#import "OrderListController.h"
#import "PrizeShareController.h"

@interface SystemMessageCenterController ()<UserServiceDelegate,SystemMessageTextCellDelegate,SystemMessageImageCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) int type;
@property (strong, nonatomic) NSMutableArray *dataList;
@property (assign, nonatomic) int finishPage;
@end

@implementation SystemMessageCenterController

#define READ_MSG_COUNT_ONCE 100

#define COUNT_ONE_PAGE  20
#define PAGE_START      1

-(instancetype) initWithType:(int)type
{
    self = [super init];
    if (self) {
        self.type = type;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //设置下拉更新
    [self.tableView addPullDownReloadWithTarget:self action:@selector(loadNewData)];
    
    //[self.tableView beginReload];
    self.tableView.fd_debugLogEnabled = NO;
    UINib *cellNib = [UINib nibWithNibName:[SystemMessageTextCell getCellIdentifier] bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:[SystemMessageTextCell getCellIdentifier]];
    
    cellNib = [UINib nibWithNibName:[SystemMessageImageCell getCellIdentifier] bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:[SystemMessageImageCell getCellIdentifier]];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.scrollsToTop = YES;
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
        self.tableView.estimatedRowHeight = 110.0f;
    }
    
    self.dataList = [NSMutableArray array];
    [self.tableView beginReload];
    
    NSUInteger count = [[TipNumberManager defaultManager] getMessageCount:self.type];
    
    [UserService updateMessageCount:nil
                              userId:[[UserManager defaultManager] readCurrentUser].userId
                            deviceId:[SportUUID uuid]
                                type:[@(self.type) stringValue]
                               count:count];
//    [[TipNumberManager defaultManager] setMessageCount:self.type count:0];
    
    [self.tableView reloadData];
}

- (void)loadNewData
{
    self.finishPage = 0;
    [self queryData];
}

- (void)queryData
{
    [UserService getSystemMessageCategoryMessage:self userId:[UserManager defaultManager].readCurrentUser.userId type:self.type page:self.finishPage+1 count:COUNT_ONE_PAGE];
}

-(void) didGetSystemMessageCategoryMessage:(NSString *)status msg:(NSString *)msg list:(NSArray *)list page:(int)page
{
    [self.tableView endLoad];
    
    if ([status isEqualToString:STATUS_SUCCESS]) {
        if (page == PAGE_START) {
            self.dataList = [NSMutableArray arrayWithArray:list];
        } else {
            [self.dataList addObjectsFromArray:list];
        }
        
        self.finishPage = (int)page;
        
        if ([list count] < COUNT_ONE_PAGE) {
            [self.tableView canNotLoadMore];
        } else {
            [self.tableView canLoadMore];
        }
    }else {
        [SportPopupView popupWithMessage:msg];
    }
    
    //无数据时的提示
    if ([self.dataList count] == 0) {
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44);
        if ([status isEqualToString:STATUS_SUCCESS]) {
            [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"没有相关数据"];
        } else {
            [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:@"网络错误"];
        }
    } else {
        [self removeNoDataView];
    }
    
    [self.tableView reloadData];

}

#pragma mark -- tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    SystemMessage *message = self.dataList[indexPath.row];

    if (message.flag == MessageFormatText) {
        NSString *identifier = [SystemMessageTextCell getCellIdentifier];
        cell = (SystemMessageTextCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        
    }else if(message.flag == MessageFormatImageText){
        NSString *identifier = [SystemMessageImageCell getCellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    } else {
        // 不显示除了文字和图文以外的消息
        return nil;
    }
    
    [self configureCell:cell
            atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataList count] == 0) {
        return;
    }
    
    SystemMessage *message = [self.dataList objectAtIndex:indexPath.row];
    BOOL isLast = (indexPath.row == [self.dataList count] - 1);
    
    if (message.flag == MessageFormatText) {
        [(SystemMessageTextCell *)cell updateCell:message
                                               indexPath:indexPath
                                                  isLast:isLast];
        [(SystemMessageTextCell *)cell setDelegate:self];
        
    }else if(message.flag == MessageFormatImageText){

        [(SystemMessageImageCell *)cell updateCell:message
                                             indexPath:indexPath
                                                isLast:isLast];
        
        [(SystemMessageImageCell *)cell setDelegate:self];
    }
    
    cell.fd_enforceFrameLayout = NO;
    return;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SystemMessage *message = [self.dataList objectAtIndex:indexPath.row];
    
   if (message.flag == MessageFormatText) {
        NSString *identifier;
        identifier = [SystemMessageTextCell getCellIdentifier];
        
        return [tableView fd_heightForCellWithIdentifier:identifier configuration:^(SystemMessageTextCell *cell) {
            [self configureCell:cell atIndexPath:indexPath];
        }];
   }else if(message.flag == MessageFormatImageText){

        NSString *identifier;
        identifier = [SystemMessageImageCell getCellIdentifier];
        
        return [tableView fd_heightForCellWithIdentifier:identifier configuration:^(SystemMessageImageCell *cell) {
            [self configureCell:cell atIndexPath:indexPath];
        }];
   } else {
       return 0;
   }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark SystemMessageTextCellDelegate
- (void)pushBusinessDetailControllerWithBusinessId:(NSString *)businessId
                                        categoryId:(NSString *)categoryId {
    
    BusinessDetailController *controller = [[BusinessDetailController alloc]initWithBusinessId:businessId categoryId:categoryId];
    [self.navigationController pushViewController:controller animated:YES];
}
- (void)pushWebViewWithUrl:(NSString *)url
              title:(NSString *)title{
    SportWebController *controller = [[SportWebController alloc]initWithUrlString:url title:title];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)pushPostDetailControllerWithPostId:(NSString *)postId
                                   content:(NSString *)content{
    
    Post *post = [[Post alloc]init];
    post.postId = postId;
    post.content = content;
    PostDetailController *controller = [[PostDetailController alloc]initWithPost:post isShowTitle:YES];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)pushVoucherController {
    if ([self isLoginAndShowLoginIfNot]) {
        MyVouchersController *controller = [[MyVouchersController alloc]init];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)pushOrderListController {
    if ([self isLoginAndShowLoginIfNot]) {
        OrderListController *controller = [[OrderListController alloc]init];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)pushInviteShareController {
    if ([self isLoginAndShowLoginIfNot]) {
        PrizeShareController *controller = [[PrizeShareController alloc]init];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)pushMembershipWebController:(NSString *)url {
    if ([self isLoginAndShowLoginIfNot]) {
        [self pushWebViewWithUrl:url
                           title:@"我的会员"];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
