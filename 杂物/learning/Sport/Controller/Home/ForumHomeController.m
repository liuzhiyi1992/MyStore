//
//  ForumHomeController.m
//  Sport
//
//  Created by haodong  on 15/5/11.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "ForumHomeController.h"
#import "UIView+Utils.h"
#import "UIScrollView+SportRefresh.h"
#import "ForumHomeCell.h"
#import "NSDictionary+JsonValidValue.h"
#import "ForumSearchManager.h"
#import "ForumSearchController.h"
#import "ForumDetailController.h"
#import "ActivityListController.h"
#import "UserListController.h"
#import "SportPopupView.h"
#import "TipNumberManager.h"
#import "CommentMessageListController.h"
#import "LoginController.h"
#import "UserManager.h"
#import "SportProgressView.h"

@interface ForumHomeController ()

@property (strong, nonatomic) UIButton *leftTitleButton;
@property (strong, nonatomic) UIButton *rightTitleButton;
@property (strong, nonatomic) PostListView *postListView;
@property (strong, nonatomic) NSMutableArray *forumList;
@property (assign, nonatomic) NSUInteger finishPage;

@property (weak, nonatomic) IBOutlet UITableView *forumTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIImageView *searchBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *searchImageView;
@property (weak, nonatomic) IBOutlet UIImageView *searchLineImageView;

@end

@implementation ForumHomeController

- (void)dealloc {
}

- (instancetype)init
{
    self = [super init];
    if (self) {
       
        [self createTitleViewWithleftButtonTitle:@"热门" rightButtonTitle:@"圈子"];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];

    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat tableHeight = screenSize.height - 20 - 44;
    
    //设置热门帖子页面
    if (_postListView == nil) {
                self.postListView = [PostListView createPostListViewWithFrame:CGRectMake(0, 0, screenSize.width, tableHeight)
                                                           controller:self
                                                             delegate:self
                                                                 type:PostListTypeHot
                                                            coterieId:nil
                                                               userId:nil];
        [self.view addSubview:self.postListView];
    }
    [self.postListView beginRefreshing];
    
    //默认选中热门
    [self selectedLeftButton];
    
    //设置圈子页面
    [self.forumTableView updateHeight:tableHeight];
    
    [self.forumTableView addPullDownReloadWithTarget:self action:@selector(loadNewData)];
    [self.forumTableView addPullUpLoadMoreWithTarget:self action:@selector(loadMoreData)];

    [self.searchLineImageView setImage:[SportImage lineImage]];
    [self.searchBackgroundImageView setImage:[SportImage searchGrayBackgroundImage]];
}

- (void)updateRightTipRedPoint
{
    if ([[TipNumberManager defaultManager] forumMessageCount] > 0) {
        [self showRightTopTipsCount:[[TipNumberManager defaultManager] forumMessageCount]];
    } else {
        [self hideRightTopTipsCount];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateRightTipRedPoint];
}

#define PAGE_START 1
#define COUNT_ONE_PAGE  20
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
//    [SportProgressView showWithStatus:@"加载中"];
    [ForumService getCoterieList:self
                            page:self.finishPage + 1
                           count:COUNT_ONE_PAGE
                          userId:[[UserManager defaultManager] readCurrentUser].userId
                          cityId:nil
                        regionId:nil];
}

- (void)didGetCoterieList:(NSArray *)list
                     page:(NSUInteger)page
                   status:(NSString *)status
                      msg:(NSString *)msg
{
    [self.forumTableView endLoad];
    
    if ([status isEqualToString:STATUS_SUCCESS]) {
        //[SportProgressView dismiss];
        self.finishPage = page;
    } else {
        [SportPopupView popupWithMessage:msg];
    }
    
    //添加数据列表
    if (page == PAGE_START) {
        self.forumList = [NSMutableArray arrayWithArray:list];
    } else {
        [self.forumList addObjectsFromArray:list];
    }
    
    if ([list count] >= COUNT_ONE_PAGE
        && [status isEqualToString:STATUS_SUCCESS]) {
        [self.forumTableView canLoadMore];
    } else {
        [self.forumTableView canNotLoadMore];
    }
    
    [self.forumTableView reloadData];
}

- (void)selectedLeftButton
{
    [super selectedLeftButton];
    
    self.postListView.hidden = NO;
    self.forumTableView.hidden = YES;
    
    [self.postListView scrollVIewToTopToYes];
    self.forumTableView.scrollsToTop = NO;
    
}

- (void)selectedRightButton
{
    [super selectedRightButton];
    self.postListView.hidden = YES;
    self.forumTableView.hidden = NO;
    
    self.forumTableView.scrollsToTop = YES;
    [self.postListView scrollVIewToTopToNo];
    
    if ([_forumList count] == 0) {
        [self.forumTableView beginReload];
    }
}

- (void)clickLeftTitleButton:(id)sender
{
    [MobClickUtils event:umeng_event_forum_home_click_hot_post_list_title];
    [super clickLeftTitleButton:sender];
}

- (void)clickRightTitleButton:(id)sender
{
    [MobClickUtils event:umeng_event_forum_home_click_forum_list_title];
    [super clickRightTitleButton:sender];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    } else {
        return [_forumList count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSString *identifier = [ForumHomeCell getCellIdentifier];
        ForumHomeCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [ForumHomeCell createCell];
        }
        if (indexPath.row == 0) {
            [cell updateCellWithImage:[SportImage forumHomeLocationImage]
                                 name:@"附近的人"
                            indexPath:indexPath
                               isLast:NO];
        } else {
            [cell updateCellWithImage:[SportImage forumHomeActivityImage]
                                 name:@"活动"
                            indexPath:indexPath
                               isLast:YES];
        }
        return cell;
    } else {
        NSString *identifier = [ForumCell getCellIdentifier];
        ForumCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [ForumCell createCell];
        }
        Forum *forum = [self.forumList objectAtIndex:indexPath.row];
        BOOL isLast = (indexPath.row == [self.forumList count] - 1);
        [cell updateCellWithForum:forum indexPath:indexPath isLast:isLast];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            
            [MobClickUtils event:umeng_event_forum_home_click_people_nearby];
            UserListController *controller = [[UserListController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
            
        } else if (indexPath.row == 1) {
            
            [MobClickUtils event:umeng_event_forum_home_click_activity];
            ActivityListController *controller = [[ActivityListController alloc] init] ;
            [self.navigationController pushViewController:controller animated:YES];
        }
    } else {
         Forum *forum = [self.forumList objectAtIndex:indexPath.row];
        ForumDetailController *controller = [[ForumDetailController alloc] initWithForum:forum] ;
        [self.navigationController pushViewController:controller animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ForumCell getCellHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    } else {
        return 12;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero] ;
}

- (IBAction)clickSearchButton:(id)sender {
    [MobClickUtils event:umeng_event_forum_home_click_search];
    ForumSearchController *controller = [[ForumSearchController alloc] init] ;
    [self.navigationController pushViewController:controller animated:NO];
}

- (void)clickRightTopButton:(id)sender
{
    [MobClickUtils event:umeng_event_forum_home_click_message];
    
    if ([self isLoginAndShowLoginIfNot] == NO) {
        return;
    }
    
    CommentMessageListController *controller = [[CommentMessageListController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
    
}

@end
