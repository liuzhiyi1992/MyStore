//
//  CommentMessageListController.m
//  Sport
//
//  Created by 江彦聪 on 15/5/19.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CommentMessageListController.h"
#import "UIScrollView+SportRefresh.h"
#import "UserManager.h"
#import "PostDetailController.h"
#import "Post.h"
#import "TipNumberManager.h"
#import "UserService.h"
#import "UserInfoController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "SportPopUpView.h"
#import "SportProgressView.h"

@interface CommentMessageListController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataList;
@property (assign, nonatomic) int finishPage;
@property (strong, nonatomic) CommentMessageListCell* cell;
@property (nonatomic, assign) BOOL cellHeightCacheEnabled;
@end

@implementation CommentMessageListController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"运动圈消息";
    //设置下拉更新
    [self.tableView addPullDownReloadWithTarget:self action:@selector(loadNewData)];
    
    //设置上拉加载更多
    [self.tableView addPullUpLoadMoreWithTarget:self action:@selector(loadMoreData)];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    //清除消息数
    NSUInteger count = [[TipNumberManager defaultManager] getMessageCount:MessageCountTypeForum];
    
    [UserService updateMessageCount:nil
                             userId:[[UserManager defaultManager] readCurrentUser].userId
                           deviceId:[SportUUID uuid]
                               type:[@(MessageCountTypeForum) stringValue]
                              count:count];
    
    self.cellHeightCacheEnabled = NO;
    self.tableView.fd_debugLogEnabled = NO;
    UINib *cellNib = [UINib nibWithNibName:[CommentMessageListCell getCellIdentifier] bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:[CommentMessageListCell getCellIdentifier]];

    
    [self.tableView beginReload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//下拉刷新
- (void)beginRefreshing
{
    [self.tableView beginReload];
}

#define COUNT_ONE_PAGE  20
#define PAGE_START      1
- (void)loadNewData
{
    self.finishPage = 0;
    [self queryData];
}

- (void)loadMoreData
{
    [self queryData];
}

- (void)queryData
{
    //[SportProgressView showWithStatus:@"加载中"];
    [ForumService  getCommentMessageList:self
                                  userId:[[UserManager defaultManager] readCurrentUser].userId
                                    page:self.finishPage + 1
                                   count:COUNT_ONE_PAGE];
}

- (void)didGetCommentMessageList:(NSArray *)list
                  page:(NSUInteger)page
                status:(NSString *)status
                   msg:(NSString *)msg
{
    [self.tableView endLoad];
    
    if ([status isEqualToString:STATUS_SUCCESS]) {
        //[SportProgressView dismiss];
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


- (void)didClickNoDataViewRefreshButton
{
    [self beginRefreshing];
}

////tableView的delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [CommentMessageListCell getCellIdentifier];
    CommentMessageListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//    if (cell == nil) {
//        cell = [CommentMessageListCell createCell];
//    }
//    
    cell.delegate = self;
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Use cell delegate
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellHeightCacheEnabled) {
        return [tableView fd_heightForCellWithIdentifier:[CommentMessageListCell getCellIdentifier] cacheByIndexPath:indexPath configuration:^(CommentMessageListCell *cell) {
            [self configureCell:cell atIndexPath:indexPath];
        }];
    } else {
        return [tableView fd_heightForCellWithIdentifier:[CommentMessageListCell getCellIdentifier] configuration:^(CommentMessageListCell *cell) {
            [self configureCell:cell atIndexPath:indexPath];
        }];
    }
}

-(void) configureCell:(CommentMessageListCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    CommentMessage *message = [self.dataList objectAtIndex:indexPath.row];
    BOOL isLast = (indexPath.row == [self.dataList count] - 1);
    
    cell.fd_enforceFrameLayout = NO;
    [cell updateCell:message
           indexPath:indexPath
              isLast:isLast];

}


-(void)didClickMessageButton:(CommentMessage *)message
{
    [MobClickUtils event:umeng_event_forum_message_list_click_content];
    
    Post *post = [[Post alloc]init];
    post.postId = message.postId;
    post.content = message.postContent;
    
    PostDetailController *controller = [[PostDetailController alloc]initWithPost:post isShowTitle:YES];
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)didClickAvatarButton:(NSIndexPath *)indexPath
{
    [MobClickUtils event:umeng_event_forum_message_list_click_user];
    
    CommentMessage *message = [self.dataList objectAtIndex:indexPath.row];
    UserInfoController *controller = [[UserInfoController alloc] initWithUserId:message.fromUserId];
    [self.navigationController pushViewController:controller animated:YES];
   
    
}

//
//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 473.0f;
//}

@end
