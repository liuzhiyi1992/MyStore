//
//  CoachCommentListController.m
//  Sport
//
//  Created by qiuhaodong on 15/7/27.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CoachCommentListController.h"
#import "Comment.h"
#import "CommentCell.h"
#import "CoachService.h"
#import "UIScrollView+SportRefresh.h"
#import "SportMWPhoto.h"
#import "SportMWPhotoBrowser.h"
#import "UIView+Utils.h"
#import "SportProgressView.h"
#import "SportPopupView.h"

@interface CoachCommentListController () <CommentCellDelegate, CoachServiceDelegate>

@property (copy, nonatomic) NSString *coachId;
@property (strong, nonatomic) NSMutableArray *commentList;
@property (assign, nonatomic) NSUInteger finishPage;
@property (strong, nonatomic) CommentCell *commentCell;
@property (weak, nonatomic) IBOutlet UITableView *dataTableView;
@property (assign, nonatomic) int type;

@end

@implementation CoachCommentListController


- (instancetype)initWithCoachId:(NSString *)coachId type:(int)type
{
    self = [super init];
    if (self) {
        self.coachId = coachId;
        self.type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"评论列表";
    
    [self.dataTableView updateHeight:[UIScreen mainScreen].bounds.size.height - 64];
    
    [self.dataTableView addPullDownReloadWithTarget:self action:@selector(loadNewData)];
    [self.dataTableView addPullUpLoadMoreWithTarget:self action:@selector(loadMoreData)];
    [self.dataTableView beginReload];
    
    [self setExtraCellLineHidden:self.dataTableView];
}

//清除多余的分隔线
- (void)setExtraCellLineHidden: (UITableView *)tableView{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

- (void)loadNewData
{
    self.finishPage = 0;
    [self queryData];
}

- (void)loadMoreData
{
    [self queryData];
}

#define COUNT_ONE_PAGE  20
- (void)queryData
{
    [CoachService getCoachCommentList:self
                              coachId:self.coachId
                                 page:self.finishPage + 1
                                count:COUNT_ONE_PAGE];
}

- (void)didGetCoachCommentList:(NSArray *)commentList
                          page:(NSUInteger)page
                        status:(NSString *)status
                           msg:(NSString *)msg
{
    [self.dataTableView endLoad];
    if ([status isEqualToString:STATUS_SUCCESS]) {
        
        self.finishPage = page;
        if (page == 1) {
            self.commentList = [NSMutableArray arrayWithArray:commentList];
        } else {
            [self.commentList addObjectsFromArray:commentList];
        }
        
        if ([commentList count] < COUNT_ONE_PAGE) {
            [self.dataTableView canNotLoadMore];
        } else {
            [self.dataTableView canLoadMore];
        }
    } else {
        [SportPopupView popupWithMessage:msg];
    }
    
    [self.dataTableView reloadData];
    
    //没数据时的提示
    if ([self.commentList count] == 0) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        CGRect frame = CGRectMake(0, 0, screenSize.width, screenSize.height - 64);
        if ([status isEqualToString:STATUS_SUCCESS]) {
            [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"还没有评论"];
        } else {
            [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:@"网络错误"];
        }
    } else {
        [self removeNoDataView];
    }
}

- (void)didClickNoDataViewRefreshButton
{
    [self queryData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.commentList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.commentCell == nil) {
        self.commentCell = [CommentCell createCell];
        self.commentCell.delegate = self;
    }
    
    Comment *comment = [self.commentList objectAtIndex:indexPath.row];
    [self.commentCell updateCell:comment indexPath:indexPath];
    CGFloat height = [self.commentCell getCellHeightWithComment:comment tableViewBounds:self.dataTableView.bounds];
    
    return height + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [CommentCell getCellIdentifier];
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [CommentCell createCell];
        cell.delegate = self;
    }
    
    Comment *comment = [self.commentList objectAtIndex:indexPath.row];
    [cell updateCell:comment indexPath:indexPath];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

- (void)didClickCommentCellImage:(NSIndexPath *)indexPath openIndex:(int)openIndex
{
    NSMutableArray *list = [NSMutableArray array];
    Comment *comment = [self.commentList objectAtIndex:indexPath.row];
    int i = 0;
    for (PostPhoto *photo in comment.photoList) {
        SportMWPhoto *mwPhoto = [SportMWPhoto photoWithURL:[NSURL URLWithString:photo.photoImageUrl]];
        mwPhoto.index = i++;
        [list addObject:mwPhoto];
    }
    SportMWPhotoBrowser *controller = [[SportMWPhotoBrowser alloc] initWithPhotoList:list openIndex:openIndex];
    UINavigationController *modelNavigationController = [[UINavigationController alloc] initWithRootViewController:controller] ;
    modelNavigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:modelNavigationController animated:YES completion:nil];
}

@end
