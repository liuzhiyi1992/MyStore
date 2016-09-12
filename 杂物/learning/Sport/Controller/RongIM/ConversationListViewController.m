//
//  CoachConversationListViewController.m
//  Sport
//
//  Created by 江彦聪 on 15/7/23.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "ConversationListViewController.h"
#import "ConversationViewController.h"
#import "UIViewController+SportNavigationItem.h"
#import "NoDataView.h"
#import "TipNumberManager.h"
#import "RongService.h"
#import "UserManager.h"
#import "SystemMessageCategoryListView.h"
#import "LoginController.h"
#import "DateUtil.h"

@interface ConversationListViewController ()<LoginDelegate, SystemMessageCategoryListViewDelegate, UserServiceDelegate>
@property (strong, nonatomic) SystemMessageCategoryListView* listView;

@end

@implementation ConversationListViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NAME_CHANGE_TIPS_COUNT object:nil];
}

-(id)init
{
    self = [super init];
    if (self) {
       // self.hidesBottomBarWhenPushed = YES;
        [self setDisplayConversationTypes:@[@(ConversationType_PRIVATE),@(ConversationType_SYSTEM)]];
        
        //聚合会话类型
        [self setCollectionConversationType:@[@(ConversationType_GROUP),@(ConversationType_DISCUSSION)]];
        self.isShowNetworkIndicatorView = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateMessageCount)
                                                     name:NOTIFICATION_NAME_CHANGE_TIPS_COUNT
                                                   object:nil];
    }
    
    return self;
}

//从Nib加载时才会调用
//-(id)initWithCoder:(NSCoder *)aDecoder
//{
//    self =[super initWithCoder:aDecoder];
//    if (self) {
//        //设置要显示的会话类型
//        
//        [self setDisplayConversationTypes:@[@(ConversationType_PRIVATE),@(ConversationType_SYSTEM)]];
//        
//        //聚合会话类型
//        [self setCollectionConversationType:@[@(ConversationType_GROUP),@(ConversationType_DISCUSSION)]];
//        
//    }
//    return self;
//}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //设置tableView样式
    self.conversationListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.conversationListTableView.tableFooterView = [UIView new];
    [self createBackButton];
    
    [self createTitleViewWithleftButtonTitle:@"通知" rightButtonTitle:@"私信"];
    
    if (self.listView == nil) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        self.listView = [SystemMessageCategoryListView createSystemMessageCategoryListViewWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height) controller:self];
        self.listView.delegate = self;
        [self.view addSubview:self.listView];
    }

    [self selectedLeftButton];
}

//
//- (void)setTitle:(NSString *)title
//{
//    [super setTitle:title];
//    if (self.titleLabel == nil) {
//        [self createTitleView];
//    }
//    self.titleLabel.text = title;
//}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self getMessageCountList];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //判断如有头像没有刷新出来，则重新刷新用户数据
    __weak typeof(&*self) blockSelf_ = self;
    for (RCConversationModel *model in self.conversationListDataSource) {
        if (model.targetId &&
            ([model.conversationTitle rangeOfString:model.targetId].length > 0)) {
            [[RongService defaultService] getRongIMUserInfo:self
                                                     rongId:model.targetId
                                                 completion:^(RCUserInfo *user) {
                                                     if (user) {
                                                         //设置当前的用户信息
                                                         [[RCIM sharedRCIM]
                                                          refreshUserInfoCache:user
                                                          withUserId:model.targetId];
                                                         [blockSelf_ refreshConversationTableViewIfNeeded];
                                                     }
                                                 }];
            
        }
    }

}

- (void)selectedLeftButton
{
    [super selectedLeftButton];
    [MobClickUtils event:umeng_event_message_center_page_click_notice_tab];
    
    self.conversationListTableView.hidden = YES;
    
    if (self.listView) {
        self.listView.hidden = NO;
    }
}

- (void)selectedRightButton
{
    if (![UserManager isLogin]) {
        LoginController *controller = [[LoginController alloc] init] ;
        controller.loginDelegate = self;
        controller.loginDelegateParameter = @"messageList";
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        [self displayMessageList];
    }
}

-(void) displayMessageList {
    [super selectedRightButton];
    [MobClickUtils event:umeng_event_message_center_page_click_chat_tab];

    self.conversationListTableView.hidden = NO;
    [self.conversationListTableView reloadData];
    self.listView.hidden = YES;
}


- (void)didLoginAndPopController:(NSString *)parameter {
    [self displayMessageList];
}

-(void)showEmptyConversationView
{
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44);
    [self.emptyConversationView removeFromSuperview];
    self.emptyConversationView = [NoDataView createNoDataViewWithFrame:frame type:NoDataTypeDefault tips:@"暂时没有私信"];
        
    [self.conversationListTableView addSubview:self.emptyConversationView];
}

#pragma mark - 收到消息监听
-(void)didReceiveMessageNotification:(NSNotification *)notification
{
//    __weak typeof(&*self) blockSelf_ = self;

    
    dispatch_async(dispatch_get_main_queue(), ^{
        //调用父类刷新未读消息数
        [super didReceiveMessageNotification:notification];
//        [blockSelf_ resetConversationListBackgroundViewIfNeeded];
                   // [self notifyUpdateUnreadMessageCount];// super会调用notifyUpdateUnreadMessageCount
        NSNumber *left = [notification.userInfo objectForKey:@"left"];
        if (0 == left.integerValue) {
            [super refreshConversationTableViewIfNeeded];
        }
    });

}

//重载函数，onSelectedTableRow 是选择会话列表之后的事件，该接口开放是为了便于您自定义跳转事件。在快速集成过程中，您只需要复制这段代码。
-(void)onSelectedTableRow:(RCConversationModelType)conversationModelType conversationModel:(RCConversationModel *)model atIndexPath:(NSIndexPath *)indexPath
{
    if (conversationModelType == RC_CONVERSATION_MODEL_TYPE_NORMAL) {
        [self pushConversationController:model];
    }
}

- (void)didTapCellPortrait:(RCConversationModel *)model
{
    [self pushConversationController:model];
}

-(void) updateUnreadCountListWithTargetId:(NSString *)targetId {
    [[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:ConversationType_PRIVATE
                                                    targetId:targetId];
    
    NSInteger count = [[RCIMClient sharedRCIMClient] getUnreadCount:@[@(ConversationType_PRIVATE),@(ConversationType_SYSTEM)]];
    
    if ([[RongService defaultService] checkRongReady]) {
        [[TipNumberManager defaultManager] setImReceiveMessageCount:count];
    } else {
        [[TipNumberManager defaultManager] setImReceiveMessageCount:0];
    }
}

//删除会话时调用
- (void)didDeleteConversationCell:(RCConversationModel *)model {

    [self updateUnreadCountListWithTargetId:model.targetId];
}

- (void)pushConversationController:(RCConversationModel *)model {
    
    [self updateUnreadCountListWithTargetId:model.targetId];
    
    ConversationViewController *conversationVC = [[ConversationViewController alloc]init];
    conversationVC.conversationType = model.conversationType;
    conversationVC.targetId = model.targetId;
//    conversationVC.userName = model.conversationTitle;
    conversationVC.title = model.conversationTitle;
    conversationVC.conversation = model;
    
    [self.navigationController pushViewController:conversationVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)notifyUpdateUnreadMessageCount
{
    [self updateBadgeValueForTabBarItem];
}

- (void)updateBadgeValueForTabBarItem {
}

- (void)willDisplayConversationTableCell:(RCConversationBaseCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[RCConversationCell class]]) {
        RCConversationCell *rcCell = (RCConversationCell *)cell;
        rcCell.messageCreatedTimeLabel.text = [DateUtil messageBriefTimeString:[NSDate dateWithTimeIntervalSince1970:cell.model.sentTime / 1000] formatter:nil];
        [(UIImageView *)rcCell.headerImageView setContentMode:UIViewContentModeScaleAspectFill];
    }
}

-(void) updateMessageCount
{
    TipNumberManager *manager = [TipNumberManager defaultManager];

    // 在点击消息详情时更新未读消息数
     __weak typeof(&*self) blockSelf_ = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (manager.imReceiveMessageCount > 0) {
            [blockSelf_ showRightTitleTipsCount:manager.imReceiveMessageCount];
        } else {
            [blockSelf_ hideRightTitleTipsCount];
        }
        
        // 包括客服消息，系统消息，特惠促销消息
        NSUInteger notifyCount = manager.customerServiceMessageCount + manager.systemMessageCount + manager.salesMessageCount + manager.forumMessageCount;
        if (notifyCount > 0) {
            [blockSelf_ showLeftTitleTipsCount:notifyCount];
        } else {
            [blockSelf_ hideLeftTitleTipsCount];
        }
    
        //刷新列表
//        if (blockSelf_.listView) {
//            [blockSelf_.listView.systemMessageTableView reloadData];
//        }
    });
}

-(void) getMessageCountList {

    [self.listView queryData];
    
    //刷新已有的Tip，如果接口请求时Tip有更新，则会再次更新。
    [self updateMessageCount];
}


//*********************插入自定义Cell*********************//

//插入自定义会话model
//-(NSMutableArray *)willReloadTableData:(NSMutableArray *)dataSource
//{
//    
//    for (int i=0; i<dataSource.count; i++) {
//        RCConversationModel *model = dataSource[i];
//        //筛选请求添加好友的系统消息，用于生成自定义会话类型的cell
//        if(model.conversationType == ConversationType_SYSTEM)
//        {
//            model.conversationModelType = RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION;
//        }
//    }
//    
//    return dataSource;
//}


//*********************插入自定义Cell*********************//

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
