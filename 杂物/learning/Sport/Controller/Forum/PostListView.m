//
//  PostListView.m
//  Sport
//
//  Created by haodong  on 15/5/12.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "PostListView.h"
#import "UIScrollView+SportRefresh.h"
#import "UserManager.h"
#import "PostDetailController.h"
#import "ForumDetailController.h"
#import "SportPopupView.h"
#import "SportMWPhotoBrowser.h"
#import "UserInfoController.h"
#import "SportProgressView.h"

@interface PostListView()

@property (strong, nonatomic) NSMutableArray *dataList;
@property (strong, nonatomic) ForumPostCell *cell;
@property (copy , nonatomic) NSString *coterieId;
@property (assign, nonatomic) id<PostListViewDelegate> delegate;
@property (assign, nonatomic) PostListType type;
@property (assign, nonatomic) UIViewController *controller;
@property (copy, nonatomic) NSString *userId;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NoDataView *noDataView;
@end

@implementation PostListView

+ (PostListView *)createPostListViewWithFrame:(CGRect)frame
                                   controller:(UIViewController *)controller
                                     delegate:(id<PostListViewDelegate>)delegate
                                         type:(PostListType)type
                                    coterieId:(NSString *)coterieId
                                       userId:(NSString *)userId
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PostListView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    PostListView *view = (PostListView *)[topLevelObjects objectAtIndex:0];
    view.frame = frame;
    view.tableView.frame = frame;
    view.tableView.separatorStyle = NO;
    view.delegate = delegate;
    view.type = type;
    view.coterieId = coterieId;
    view.controller = controller;
    view.userId = userId;
    //设置下拉更新
    [view.tableView addPullDownReloadWithTarget:view action:@selector(loadNewData)];

    //设置上拉加载更多
    [view.tableView addPullUpLoadMoreWithTarget:view action:@selector(loadMoreData)];
    
    //table估计高度
//    view.tableView.rowHeight = UITableViewAutomaticDimension;
//    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
//        view.tableView.estimatedRowHeight = 473.0f;
//    }
    return view;
}

//下拉刷新
- (void)beginRefreshing
{
    [self.tableView beginReload];
}

- (void)loadNewData
{
    self.finishPage = 0;
    [self queryData];
}

- (void)loadMoreData
{
    if (self.type == PostListTypeHot) {
        [MobClickUtils event:umeng_event_forum_home_hot_load_more];
    } else if (self.type == PostListTypeInCoterie) {
        [MobClickUtils event:umeng_event_forum_detail_load_more];
    }
    
    [self queryData];
}

- (void)queryData
{
    //[SportProgressView showWithStatus:@"加载中"];
    NSString *userId;
    if (self.type == PostListTypeHot ||
        self.type == PostListTypeInCoterie) {
        userId = [[UserManager defaultManager] readCurrentUser].userId;
    } else {
        userId = self.userId;
    }
    
    [ForumService getPostList:self
                         type:self.type
                    coterieId:self.coterieId
                       userId:userId
                         page:self.finishPage + 1
                        count:COUNT_ONE_PAGE];
}

- (void)didGetPostList:(NSArray *)list
                  page:(NSUInteger)page
                status:(NSString *)status
                   msg:(NSString *)msg
{
    [self.tableView endLoad];
 
    if ([status isEqualToString:STATUS_SUCCESS]) {
        //[SportProgressView dismiss];
        self.finishPage ++;
    } else {
        [SportPopupView popupWithMessage:msg];
    }
    
    //更新数据列表
    if (page == PAGE_START) {
        self.dataList = [NSMutableArray arrayWithArray:list];
    } else {
        [self.dataList addObjectsFromArray:list];
    }
    
    //设置是否可加载更多
    if ([status isEqualToString:STATUS_SUCCESS]
        && [list count] >= COUNT_ONE_PAGE ) {
        [self.tableView canLoadMore];
    } else {
        [self.tableView canNotLoadMore];
    }
    
    //无数据时的提示
    if ([self.dataList count] == 0) {
        CGRect frame = CGRectMake(0, 0, self.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44);
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

//tableView的delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [ForumPostCell getCellIdentifier];
    ForumPostCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [ForumPostCell createCellWithCellLineHidden:NO];
    }
    
    cell.delegate = self;
    Post *post = [self.dataList objectAtIndex:indexPath.row];
    
    [self updateCellWithCell:cell post:post
                   indexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [MobClickUtils event:umeng_event_forum_post_list_click_post_entrance];
    
    Post *post = [self.dataList objectAtIndex:indexPath.row];
    
    BOOL isShowTitle;
    if(self.type == PostListTypeInCoterie) {
        isShowTitle = NO;
    }else {
        isShowTitle = YES;
    }
    
    PostDetailController *detailController = [[PostDetailController alloc]initWithPost:post isShowTitle:isShowTitle] ;
    [self.controller.navigationController  pushViewController:detailController animated:YES];
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_cell) {
        self.cell = [ForumPostCell createCellWithCellLineHidden:NO];
    }
    
    Post *post = [self.dataList objectAtIndex:indexPath.row];
    
    [self updateCellWithCell:self.cell post:post
                   indexPath:indexPath];
    
    [self.tableView setNeedsUpdateConstraints];
    [self.tableView updateConstraintsIfNeeded];
    
    CGFloat height = [self.cell getCellHeightWithPost:post
                                       indexPath:indexPath
                                 tableViewBounds:tableView.bounds];
    
    //CGFloat height = [self.cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return height + 1;
}

-(void) updateCellWithCell:(ForumPostCell *)cell
                      post:(Post *)post
                 indexPath:(NSIndexPath *)indexPath
{
    
    BOOL isLast = (indexPath.row == [self.dataList count] - 1);
    BOOL isShowForumName;
    if (self.type == PostListTypeInCoterie) {
        isShowForumName = NO;

    }else {
        isShowForumName = YES;
    }
    
    [cell updateCell:post
           indexPath:indexPath
     isShowForumName:isShowForumName //to update
  isShowCommentCount:YES
              isLast:isLast
         ];
}


//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 473.0f;
//}

-(void)didClickForumPostImage:(NSIndexPath *)indexPath
                    openIndex:(int)openIndex
{
    NSMutableArray *list = [NSMutableArray array];
    Post *post = [self.dataList objectAtIndex:indexPath.row];
    
    int i = 0;
    for (PostPhoto *photo in post.photoList) {
        
        SportMWPhoto *mwPhoto = [SportMWPhoto photoWithURL:[NSURL URLWithString:photo.photoImageUrl]];
        mwPhoto.index = i++;
        [list addObject:mwPhoto];
    }
    
    SportMWPhotoBrowser *controller = [[SportMWPhotoBrowser alloc]initWithPhotoList:list openIndex:openIndex];
    
    UINavigationController *modelNavigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    modelNavigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self.controller presentViewController:modelNavigationController animated:YES completion:nil];
    

}

-(void)didClickForumButton:(NSIndexPath *)indexPath
{
    Post *post = [self.dataList objectAtIndex:indexPath.row];
    ForumDetailController *controller = [[ForumDetailController alloc] initWithForum:post.forum] ;
    [self.controller.navigationController pushViewController:controller animated:YES];

}


-(void)didClickAvatarButton:(NSIndexPath *)indexPath
{
    Post *post = [self.dataList objectAtIndex:indexPath.row];
    UserInfoController *controller = [[UserInfoController alloc] initWithUserId:post.userId];
    [self.controller.navigationController pushViewController:controller animated:YES];

}

- (void)showNoDataViewWithType:(NoDataType)type
                         frame:(CGRect)frame
                          tips:(NSString *)tips
{
    [_noDataView removeFromSuperview];
    self.noDataView = [NoDataView createNoDataViewWithFrame:frame
                                                       type:type
                                                       tips:tips];
    self.noDataView.delegate = self;
    [self.tableView addSubview:_noDataView];
}

- (void)removeNoDataView
{
    [_noDataView removeFromSuperview];
}


- (void)didClickNoDataViewRefreshButton
{
    [self beginRefreshing];
}

- (void)scrollVIewToTopToYes{
    self.tableView.scrollsToTop = YES;
}

- (void)scrollVIewToTopToNo{
    self.tableView.scrollsToTop = NO;
}

@end
