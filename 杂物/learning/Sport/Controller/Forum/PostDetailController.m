//
//  PostDetailController.m
//  Sport
//
//  Created by 江彦聪 on 15/5/12.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "PostDetailController.h"
#import "UIScrollView+SportRefresh.h"
#import "SportProgressView.h"
#import "SportPopupView.h"
#import "PostComment.h"
#import "UIImageView+WebCache.h"
#import "ForumDetailController.h"
#import "NSString+Utils.h"
#import "UserManager.h"
#import "LoginController.h"
#import "SportMWPhotoBrowser.h"
#import "UserInfoController.h"
#import "UIView+Utils.h"

@interface PostDetailController ()
@property (strong, nonatomic) NSMutableArray *dataList;
@property (strong, nonatomic) Post *post;
@property (weak, nonatomic) IBOutlet UIImageView *forumImageView;
@property (weak, nonatomic) IBOutlet UILabel *forumNameLabel;

@property (weak, nonatomic) IBOutlet UIButton *enterForumButton;

@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (assign, nonatomic) BOOL isShowTitle;

@property (weak, nonatomic) IBOutlet UITextField *writePostTextField;
@property (assign, nonatomic) int page;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *tableHeaderView;

@property (strong, nonatomic) PostCommentCell* commentCell;
@property (strong, nonatomic) ForumPostCell *postCell;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *writeCommentOffsetConstraint;
@property (weak, nonatomic) IBOutlet UIButton *writeCommentButton;
@property (weak, nonatomic) IBOutlet UIView *writeCommentView;
@property (assign, nonatomic) BOOL canLoadMore;
@property (weak, nonatomic) IBOutlet UILabel *noDataLabel;
@property (weak, nonatomic) IBOutlet UIView *tableFooterView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lineViewConstraintHeight;

@end

@implementation PostDetailController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self deregsiterKeyboardNotification];
}

- (id)initWithPost:(Post *)post
      isShowTitle:(BOOL)isShowTitle
{
    self = [super init];
    if (self) {
        self.post = post;
        self.isShowTitle = isShowTitle;
        
        [self registerForKeyboardNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self.writePostTextField];
    }
    
    return self;
}

#define COUNT_ONE_PAGE  20
#define PAGE_START      1
- (void)loadNewCommentData
{
    int page = self.page;
    if (self.canLoadMore) {
        page++;
    }
    
    [self queryCommentDataWithPage:page];
}

- (void)reloadPostData
{
    [self queryPostDetailData];
    [self loadNewCommentData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"帖子详情";
    self.page = PAGE_START;
    self.canLoadMore = NO;
    
    [self.tableView addPullUpLoadMoreWithTarget:self action:@selector(loadNewCommentData)];
    [self.tableView addPullDownReloadWithTarget:self action:@selector(reloadPostData)];

    [self deactiveSendButton];
    
    self.writePostTextField.delegate = self;
    //[self.tableView beginReload];
    [self reloadPostData];
    [self.enterForumButton setBackgroundImage:[SportColor createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    
    [self hideNoDataOrNetworkFail];
    self.titleView.hidden = YES;
    self.lineViewConstraintHeight.constant = 0.5;
    //[self loadPostDetailCell:self.post];
    
    //table估计高度
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
//    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
//        self.tableView.estimatedRowHeight = 122.0f;
//    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadPostDetailCell:self.post];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
//    [self loadPostDetailCell:self.post];
    [self.view layoutSubviews];
}

#define SECTION_MARGIN 10
-(void)loadPostDetailCell:(Post *)post
{
    if (self.postCell == nil) {
        self.postCell = [ForumPostCell createCellWithCellLineHidden:YES];
        self.postCell.delegate = self;
    }
    
    //保证table View布局变量都更新后，才计算高度
    [self.tableView setNeedsUpdateConstraints];
    [self.tableView updateConstraintsIfNeeded];
    
    post.lastUpdateTime = nil;
    [self.postCell updateCell:post indexPath:nil isShowForumName:NO isShowCommentCount:NO isLast:YES];
    self.forumNameLabel.text = post.forum.forumName;
    [self.forumImageView sd_setImageWithURL:[NSURL URLWithString:self.post.forum.imageUrl]];
    self.forumImageView.clipsToBounds = YES;
    
    CGFloat height = [self.postCell getCellHeightWithPost:post indexPath:nil tableViewBounds:self.tableView.bounds];
    
    CGFloat y;
    if (self.isShowTitle == NO) {
        self.titleView.hidden = YES;
        y = 0.0f;
    } else {
        self.titleView.hidden = NO;
        y = self.titleView.frame.size.height+ SECTION_MARGIN;
    }
    
    self.postCell.frame =  CGRectMake(0, y, [UIScreen mainScreen].bounds.size.width,height);
    
    [self.tableView.tableHeaderView addSubview:self.postCell];
    [self.tableView setNeedsLayout];
    [self.tableView layoutIfNeeded];
    y = y + height + SECTION_MARGIN;
    [self.tableView sizeHeaderToFit:y];
}

- (void)queryPostDetailData {
    [ForumService getPostDetail:self
                         postId:self.post.postId];
}

- (void)queryCommentDataWithPage:(int) page {
    
    [ForumService getCommentList:self postId:self.post.postId page:page count:COUNT_ONE_PAGE];
    
}

- (void)didGetPostDetail:(Post *)post
                  status:(NSString *)status
                     msg:(NSString *)msg
{
    
    if ([status isEqualToString:STATUS_SUCCESS]) {
        self.post = post;
        
        [self loadPostDetailCell:self.post];
        
    } else {
        
        [SportPopupView popupWithMessage:msg];
    }
    
    [self.tableView reloadData];
    [self.tableView endLoad];
}

-(void)didGetCommentList:(NSArray *)list page:(NSUInteger)page status:(NSString *)status msg:(NSString *)msg
{
    [self.tableView endLoad];
    [self hideNoDataOrNetworkFail];
    int cellHeight = [self.commentCell getCellHeightWithTableViewBounds:self.tableView.bounds];
    int adjustHeight = cellHeight;
    if ([status isEqualToString:STATUS_SUCCESS]) {
        self.page = (int)page;
        
        if (self.page == PAGE_START) {
            self.dataList = [NSMutableArray arrayWithArray:list];
        } else {
            for (PostComment *newComment in list) {
                BOOL isNew = YES;
                for (PostComment *oldComment in self.dataList) {
                    if ([newComment.commentId isEqualToString:oldComment.commentId]) {
                        isNew = NO;
                        break;
                    }
                }
                
                //只对不重复的评论添加到列表
                if (isNew) {
                    [self.dataList addObject:newComment];
                    adjustHeight += cellHeight;
                }
            }
        }
        
        if ([self.dataList count] == 0) {
            [self showNoDataOrNetworkFail:@"没有相关数据，快来抢沙发吧"];
        }
        
    } else {
        [SportPopupView popupWithMessage:msg];
        [self showNoDataOrNetworkFail:@"网络不给力，请稍候再试"];
    }
    
    self.canLoadMore = ([list count] < COUNT_ONE_PAGE)? NO : YES;
    if (self.canLoadMore == YES) {
        [self.tableView canLoadMore];
    } else {
        [self.tableView canNotLoadMore];
    }
    
    [self.tableView reloadData];
    //self.tableView.contentOffset = CGPointMake(0,self.tableView.contentOffset.y+adjustHeight);
}

-(void)showNoDataOrNetworkFail:(NSString *)title
{
    self.noDataLabel.text = title;
    self.noDataLabel.hidden = NO;
    [self.tableView sizeFooterToFit:77];
}

-(void)hideNoDataOrNetworkFail
{
    self.noDataLabel.text = @"";
    self.noDataLabel.hidden = YES;
    [self.tableView sizeFooterToFit:0];
}

#pragma mark -- tableView的delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [PostCommentCell getCellIdentifier];
    PostCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [PostCommentCell createCell];
        cell.delegate = self;
    }
    
    PostComment *comment = [self.dataList objectAtIndex:indexPath.row];
    BOOL isLast = (indexPath.row == [self.dataList count] - 1);
    [cell updateCell:comment indexPath:indexPath isLast:isLast];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.writePostTextField resignFirstResponder];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.commentCell == nil) {
        self.commentCell = [PostCommentCell createCell];
    }
    
    PostComment *comment = [self.dataList objectAtIndex:indexPath.row];
    BOOL isLast = (indexPath.row == [self.dataList count] - 1);
    [self.commentCell updateCell:comment indexPath:indexPath isLast:isLast];
    
    CGFloat height = [self.commentCell getCellHeightWithTableViewBounds:tableView.bounds];
    
    //CGFloat height = [self.cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return height + 1;
}

- (IBAction)clickForumTopBarButton:(id)sender {
    [MobClickUtils event:umeng_event_forum_post_detail_click_top_forum_entrance];
    
    [SportProgressView dismiss];
    
    ForumDetailController *controller = [[ForumDetailController alloc]initWithForum:self.post.forum];
    
    [self.navigationController pushViewController:controller animated:YES];
    

}

-(void)clickBackButton:(id)sender
{
    [SportProgressView dismiss];
    
    [self.navigationController popViewControllerAnimated:YES];

}

#pragma mark --Keyboard show and hide
- (void) keyboardWasShown:(NSNotification *) notif
{
    NSDictionary *info = [notif userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    [UIView animateWithDuration:0.3 animations:^{

        self.writeCommentOffsetConstraint.constant = keyboardSize.height;
    }];
    ///keyboardWasShown = YES;
}

- (void) keyboardWasHidden:(NSNotification *) notif
{
    self.writeCommentOffsetConstraint.constant = 0;
    // keyboardWasShown = NO;
}


#pragma mark -- textFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.writePostTextField resignFirstResponder];
    [self addPost];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [MobClickUtils event:umeng_event_forum_post_detail_click_input];
    
    if ([self isLoginAndShowLoginIfNot]) {
        return YES;
    } else {
        return NO;
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.writePostTextField.text length] == 0) {
        [self deactiveSendButton];
    }
}

- (IBAction)touchDownBackground:(id)sender {
    [self.writePostTextField resignFirstResponder];
}

#define MAX_COMMENT_LENGTH 140
#pragma mark --UITextFieldTextDidChangeNotification
- (void)textFieldDidChange:(NSNotification *)obj
{
    UITextField * textField = (UITextField *)obj.object;
    NSString *inputText = [[textField.text stringByTrimmingLeadingWhitespaceAndNewline] stringByTrimmingTrailingWhitespaceAndNewline];
    NSString *toBeString = inputText;
    
    // 键盘输入模式

    UITextRange *selectedRange = [textField markedTextRange];
    
    //获取高亮部分
    UITextPosition *position = nil;
    if (selectedRange) {
        position = [textField positionFromPosition:selectedRange.start offset:0];
    }
    
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position) {
        if ([toBeString length] > 0) {
            [self activeSendButton];
        }
        else {
            [self deactiveSendButton];
        }
        
        if (toBeString.length > MAX_COMMENT_LENGTH) {
            textField.text = [toBeString substringToIndex:MAX_COMMENT_LENGTH];
            [SportPopupView popupWithMessage:[NSString stringWithFormat:@"超过%d字啦",MAX_COMMENT_LENGTH]];
        }
    }
    // 有高亮选择的字符串，则暂不对文字进行统计和限制
    else{
        
    }
}

-(void)activeSendButton
{
    [self.writeCommentButton setTitleColor:[SportColor defaultColor] forState:UIControlStateNormal];
    
//    [self.writeCommentButton setBackgroundImage:[SportImage blueFrameButtonImage] forState:UIControlStateNormal];
//    [self.writeCommentButton setBackgroundImage:[SportImage blueButtonImage] forState:UIControlStateHighlighted];
    self.writeCommentButton.layer.borderColor = [SportColor defaultColor].CGColor;
    [self.writeCommentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    self.writeCommentButton.enabled = YES;
}

-(void)deactiveSendButton
{
    self.writeCommentButton.layer.borderColor = [SportColor defaultButtonInactiveColor].CGColor;
    [self.writeCommentButton setTitleColor:[SportColor defaultButtonInactiveColor] forState:UIControlStateNormal];
    [self.writeCommentButton setBackgroundImage:[SportImage grayFrameButtonImage] forState:UIControlStateNormal];
    self.writeCommentButton.enabled = NO;
}

- (IBAction)clickWriteCommentButton:(id)sender {
    [self addPost];
}

- (void) addPost
{
    NSString *inputText = [[self.writePostTextField.text stringByTrimmingLeadingWhitespaceAndNewline] stringByTrimmingTrailingWhitespaceAndNewline];
    
    
    if ([inputText length] == 0) {
        [SportPopupView popupWithMessage:@"请输入你的看法"];
        return;
    }
    
    [MobClickUtils event:umeng_event_forum_post_detail_click_send];
    
    User *user = [[UserManager defaultManager] readCurrentUser];
    [SportProgressView showWithStatus:@"发表中"];
    [self deactiveSendButton];
    self.writePostTextField.enabled = NO;
    [ForumService addComment:self forumId:self.post.forum.forumId content:inputText userId:user.userId postId:self.post.postId];

}

- (void)didAddComment:(NSString *)commentId status:(NSString *)status msg:(NSString *)msg
{
    self.writePostTextField.enabled = YES;
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismiss];
        self.writePostTextField.text = @"";
        [self.writePostTextField resignFirstResponder];
        
        //如当前不可下拉，也就是说已经拉到最后一页的时候，才更新
        if (self.canLoadMore == NO) {
            [self.tableView beginLoadMore];
        }
    }
    else {
        [self activeSendButton];
        [SportProgressView dismissWithError:msg];
    }
}

-(void)didClickForumPostImage:(NSIndexPath *)indexPath
                    openIndex:(int)openIndex
{
    NSMutableArray *list = [NSMutableArray array];
    
    int i = 0;
    for (PostPhoto *photo in self.post.photoList) {
        
        SportMWPhoto *mwPhoto = [SportMWPhoto photoWithURL:[NSURL URLWithString:photo.photoImageUrl]];
        mwPhoto.index = i++;
        [list addObject:mwPhoto];
    }
    
    SportMWPhotoBrowser *controller = [[SportMWPhotoBrowser alloc]initWithPhotoList:list openIndex:openIndex];
    
    UINavigationController *modelNavigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    modelNavigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:modelNavigationController animated:YES completion:nil];
    
}

-(void)didClickAvatarButton:(NSIndexPath *)indexPath
{
    UserInfoController *controller = [[UserInfoController alloc] initWithUserId:self.post.userId];
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (void)didClickPostCommentCellUser:(NSIndexPath *)indexPath
{
    [MobClickUtils event:umeng_event_forum_post_detail_click_comment_user];
    
    PostComment *comment = [self.dataList objectAtIndex:indexPath.row];
    UserInfoController *controller = [[UserInfoController alloc] initWithUserId:comment.userId] ;
    [self.navigationController pushViewController:controller animated:YES];
}




@end
