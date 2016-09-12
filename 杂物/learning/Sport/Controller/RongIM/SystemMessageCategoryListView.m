//
//  SystemMessageCategoryListView.m
//  Sport
//
//  Created by 江彦聪 on 15/10/14.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "SystemMessageCategoryListView.h"
#import "SystemMessageCategoryListCell.h"

#import "UITableView+FDTemplateLayoutCell.h"
#import "UserManager.h"
#import "UserService.h"
#import "SportPopupView.h"
#import "SystemMessageCenterController.h"
#import "CommentMessageListController.h"
#import "NoDataView.h"
#import "SportProgressView.h"

@interface SystemMessageCategoryListView()<UserServiceDelegate,UITableViewDataSource,UITableViewDelegate,SystemMessageCategoryListCellDelegate,NoDataViewDelegate>
@property (strong, nonatomic) NSMutableArray *dataList;
@property (weak, nonatomic) UIViewController *controller;
@property   (strong, nonatomic) NoDataView *noDataView;
@property (assign, nonatomic) int lastTimeStamp;
@end
@implementation SystemMessageCategoryListView
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NAME_CHANGE_TIPS_COUNT object:nil];
}

- (void)awakeFromNib {
    self.systemMessageTableView.dataSource = self;
    self.systemMessageTableView.delegate = self;
}

+ (SystemMessageCategoryListView *)createSystemMessageCategoryListViewWithFrame:(CGRect)frame
                                   controller:(UIViewController *)controller
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SystemMessageCategoryListView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    
    SystemMessageCategoryListView *view = (SystemMessageCategoryListView *)[topLevelObjects objectAtIndex:0];
    view.frame = frame;
    view.controller = controller;
    
    //设置下拉更新
    [view.systemMessageTableView addPullDownReloadWithTarget:view action:@selector(loadNewData)];
    

    view.systemMessageTableView.rowHeight = UITableViewAutomaticDimension;
    
    view.systemMessageTableView.fd_debugLogEnabled = NO;
    UINib *cellNib = [UINib nibWithNibName:[SystemMessageCategoryListCell getCellIdentifier] bundle:nil];
    [view.systemMessageTableView registerNib:cellNib forCellReuseIdentifier:[SystemMessageCategoryListCell getCellIdentifier]];
    
    //首次进来刷新数据
    [[NSNotificationCenter defaultCenter] addObserver:view
                                             selector:@selector(refreshCategoryList)
                                                 name:NOTIFICATION_NAME_CHANGE_TIPS_COUNT
                                               object:nil];
    [SportProgressView showWithStatus:@"加载中"];
    
    return view;
}

- (void)loadNewData
{
    // 首先需要更新messageCountList，再需要load数据
    [UserService getMessageCountList:self
                              userId:[[UserManager defaultManager] readCurrentUser].userId
                            deviceId:[SportUUID uuid]];
    [self queryData];
}

-(void) refreshCategoryList {
    // 这里要开子线程才能执行成功, 防止多次触发同一个url
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.lastTimeStamp != (int)[[NSDate date] timeIntervalSince1970]){
            [self queryData];
        }
    });
}

- (void)queryData
{
    NSString *userId = [[UserManager defaultManager] readCurrentUser].userId;
    
    [UserService getSystemMessageCategory:self userId:userId];

    self.lastTimeStamp = (int)[[NSDate date] timeIntervalSince1970];
    
}

- (void)didGetSystemMessageCategory:(NSString *)status
                                msg:(NSString *)msg
                               list:(NSArray *)list {
    [SportProgressView dismiss];
    [self.systemMessageTableView endLoad];
    
    if ([status isEqualToString:STATUS_SUCCESS]) {

        self.dataList = [NSMutableArray arrayWithArray:list];
 
    }else {
        [SportPopupView popupWithMessage:msg];
    }
    
    //无数据时的提示
    if ([self.dataList count] == 0) {
        CGRect frame = CGRectMake(0, 0, self.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44);
        if ([status isEqualToString:STATUS_SUCCESS]) {
            [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"暂时没有通知"];
        } else {
            [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:msg];
        }
    } else {
        [self.noDataView removeFromSuperview];
    }
    
    [self.systemMessageTableView reloadData];
}

- (void)showNoDataViewWithType:(NoDataType)type
                         frame:(CGRect)frame
                          tips:(NSString *)tips
{
    [self.noDataView removeFromSuperview];
    self.noDataView = [NoDataView createNoDataViewWithFrame:frame
                                                       type:type
                                                       tips:tips];
    self.noDataView.delegate = self;
    [self addSubview:self.noDataView];
}

- (void)didClickNoDataViewRefreshButton
{
    [self.systemMessageTableView beginReload];
}

//tableView的delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [SystemMessageCategoryListCell getCellIdentifier];
    SystemMessageCategoryListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    cell.delegate = self;
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SystemMessage *message = [self.dataList objectAtIndex:indexPath.row];

    //运动圈消息直接跳到运动圈页面
    if (message.type != MessageCountTypeForum) {
        [MobClickUtils event:umeng_event_click_msg_act];
        SystemMessageCenterController *controller = [[SystemMessageCenterController alloc]initWithType:message.type];
        controller.title = message.typeName;
        [self.controller.navigationController pushViewController:controller animated:YES];
        
    } else {
        [MobClickUtils event:umeng_event_click_msg_forum];
        CommentMessageListController *controller = [[CommentMessageListController alloc]init];
        [self.controller.navigationController pushViewController:controller animated:YES];
    }
    
    message.number = 0;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier:[SystemMessageCategoryListCell getCellIdentifier] configuration:^(SystemMessageCategoryListCell *cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
    
}

- (void)configureCell:(SystemMessageCategoryListCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    SystemMessage *message = [self.dataList objectAtIndex:indexPath.row];
    BOOL isLast = (indexPath.row == [self.dataList count] - 1);
    
    cell.fd_enforceFrameLayout = NO;
    [cell updateCell:message
           indexPath:indexPath
              isLast:isLast];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
