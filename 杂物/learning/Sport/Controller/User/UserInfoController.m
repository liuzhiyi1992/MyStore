//
//  UserInfoController.m
//  Sport
//
//  Created by qiuhaodong on 15/5/17.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "UserInfoController.h"
#import "UserManager.h"
#import "Forum.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "UIView+Utils.h"
#import "ForumDetailController.h"
#import "EditUserInfoController.h"
#import <QuartzCore/QuartzCore.h>
#import "UserPostListController.h"
#import "BrowsePhotoView.h"
#import "SportPopupView.h"
#import "NSString+Utils.h"
#import "SportProgressView.h"
#import "UserInfoHolderView.h"
#import "PostHolderView.h"
#import "ConversationViewController.h"

@interface UserInfoController () <UserInfoHolderViewDelegate>
@property (copy, nonatomic) NSString *userId;
@property (strong, nonatomic) User *user;

@property (weak, nonatomic) IBOutlet UIView *userInfoHolderView;
@property (weak, nonatomic) IBOutlet UIView *businessHolderView;
@property (weak, nonatomic) IBOutlet UIView *postHolderView;
@property (weak, nonatomic) IBOutlet UITableView *forumTableView;
@property (weak, nonatomic) IBOutlet UILabel *forumCountLabel;

@end

@implementation UserInfoController


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (instancetype)initWithUserId:(NSString *)userId
{
    self = [super init];
    if (self) {
        self.userId = userId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"个人详情";
    
    self.businessHolderView.hidden = YES;
    self.postHolderView.hidden = YES;
    
    [self initUI];
    //[self queryData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self queryData];
}

//to do 1.91去除
//- (void)clickRightTopButton:(id)sender
//{
////    [MobClickUtils event:umeng_event_user_detail_click_edit];
//    
//    EditUserInfoController *controller = [[EditUserInfoController alloc] initWithUser:_user];
//    [self.navigationController pushViewController:controller animated:YES];
//}

//to do 1.91改版去除  (转移)
//- (IBAction)clickAvatarButton:(id)sender {
//    [MobClickUtils event:umeng_event_user_detail_click_avatar];
//    
//    NSString *validAvatar = nil;
//    if (_user.avatarBigUrl != nil) {
//        validAvatar = _user.avatarBigUrl;
//    } else if (_user.avatarUrl != nil) {
//        validAvatar = _user.avatarUrl;
//    }
//    
//    if (validAvatar == nil) {
//        [SportPopupView popupWithMessage:@"还没有头像哦"];
//        return;
//    }
//    
//    BrowsePhotoView *view = [BrowsePhotoView createBrowsePhotoView];
//    [view showImageList:[NSArray arrayWithObjects:validAvatar, nil] openIndex:0];
//}

- (BOOL)isMyself
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    if ([user.userId isEqualToString:_userId]) {
        return YES;
    } else {
        return NO;
    }
}

#define TAG_BACKGROUND_IMAGE_VIEW       200
#define TAG_BACKGROUND_ROUND_IMAGE_VIEW 201
#define TAG_LINE_IMAGE_VIEW 100

#define WIDTH_SIGNTURE_TEXT_VIEW  ([UIScreen mainScreen].bounds.size.width - 52)

- (void)updateOneImageViwe:(UIView *)imageView
{
    if ([imageView isKindOfClass:[UIImageView class]]) {
        if (imageView.tag == TAG_BACKGROUND_IMAGE_VIEW) {
            [(UIImageView *)imageView setImage:[SportImage whiteBackgroundImage]];
        } else if (imageView.tag == TAG_BACKGROUND_ROUND_IMAGE_VIEW) {
            [(UIImageView *)imageView setImage:[SportImage whiteBackgroundRoundImage]];
        } else if (imageView.tag == TAG_LINE_IMAGE_VIEW) {
            [(UIImageView *)imageView setImage:[SportImage lineImage]];
        }
    }
}

- (void)initUI
{
    for(UIView *first in self.view.subviews) {
        [self updateOneImageViwe:first];
        for (UIView *second in first.subviews) {
            [self updateOneImageViwe:second];
            for (UIView *third in second.subviews) {
                [self updateOneImageViwe:third];
            }
        }
    }
}

#define TAG_SIGNTURE 2015052301
- (void)updateUI
{
    self.businessHolderView.hidden = NO;
    self.postHolderView.hidden = NO;
    
    //头像
//    [self.avatarButton sd_setBackgroundImageWithURL:[NSURL URLWithString:self.user.avatarUrl] forState:UIControlStateNormal placeholderImage:[SportImage avatarDefaultImage]];
    //[self.avatarButton sd_setImageWithURL:[NSURL URLWithString:self.user.avatarUrl] forState:UIControlStateNormal placeholderImage:[SportImage avatarDefaultImage]];
    
    //to do 1.91改版顶部用户详情
    //设置签名
//    [[self.baseHolderView viewWithTag:TAG_SIGNTURE] removeFromSuperview];
//    UITextView *signtureTextView = [self createSigntureTextView];
//    signtureTextView.tag = TAG_SIGNTURE;
//    signtureTextView.text = self.user.signture;
//    CGSize size = [signtureTextView sizeThatFits:CGSizeMake(WIDTH_SIGNTURE_TEXT_VIEW, 500)];
//    [signtureTextView updateOriginY:116];
//    CGFloat height = MAX(size.height, 40);
//    [signtureTextView updateHeight:height];
//    [self.baseHolderView addSubview:signtureTextView];
//    [self.baseHolderView updateHeight:signtureTextView.frame.origin.y + signtureTextView.frame.size.height + 5];
    
    NSURL *avatarUrl = [NSURL URLWithString:self.user.avatarUrl];
    
    //用户基本信息
    UserInfoHolderView *userInfoView = [UserInfoHolderView creatViewWithAvatarUrl:avatarUrl userName:self.user.nickname city:self.user.cityName signture:self.user.signture gender:self.user.gender level:self.user.rulesTitle iconUrl:self.user.rulesIconUrl isRulesDisplay:([self.user.rulesIsDisplay isEqualToString:@"1"] ? YES : NO) viewStatus:[self isMyself]?ViewStatusMyself:ViewStatusOther];
    userInfoView.delegate = self;
    
    [userInfoView updateWidth:[UIScreen mainScreen].bounds.size.width];
    [self.userInfoHolderView addSubview:userInfoView];
    [self.userInfoHolderView updateHeight:userInfoView.frame.size.height];
    
    CGFloat y = CGRectGetMaxY(self.userInfoHolderView.frame) + 10;
    
    //设置常去圈子
    NSUInteger forumCount = [self.user.oftenGoToForumList count];
    if (forumCount > 0) {
        
        if (forumCount == 1) {
            self.forumCountLabel.font = [UIFont systemFontOfSize:24];
        } else {
            self.forumCountLabel.font = [UIFont systemFontOfSize:36];
        }
        self.forumCountLabel.text = [@(forumCount) stringValue];
        
        self.businessHolderView.hidden = NO;
        [self.businessHolderView updateHeight:forumCount * [UserForumCell getCellHeight]];
        [self.forumTableView updateHeight:forumCount * [UserForumCell getCellHeight]];
        
        [self.businessHolderView updateOriginY:y];
        y = y + self.businessHolderView.frame.size.height + 10;
        
        [self.forumTableView reloadData];
    } else {
        self.businessHolderView.hidden = YES;
    }
    
    //设置最近发的一张贴子
    if (self.user.postCount > 0) {
        self.postHolderView.hidden = NO;
 
        NSURL *imageUrl = [NSURL URLWithString:self.user.lastPost.coverImageUrl];
        PostHolderView *view = [PostHolderView creatViewWithStatus:[self isMyself] count:[@(self.user.postCount) stringValue] imageUrl:imageUrl content:self.user.lastPost.content];
        [view updateWidth:[UIScreen mainScreen].bounds.size.width];
        view.delegate = self;
        [self.postHolderView addSubview:view];
        [self.postHolderView updateHeight:view.frame.size.height];
        if([self.user.oftenGoToForumList count] > 0) {
            [self.postHolderView updateOriginY:CGRectGetMaxY(self.businessHolderView.frame) + 10];
        }else {
            [self.postHolderView updateOriginY:CGRectGetMaxY(self.userInfoHolderView.frame) + 10];
        }
//to do 1.91去除，重用PostHoldeView
//        self.whosPostLabel.text = ([self isMyself] ? @"我的贴子" : @"Ta的贴子");
//        self.postCountLabel.text = [@(self.user.postCount) stringValue];
//        
//        if ([self.user.lastPost.coverImageUrl length] > 0) {
//            [self.postImageView sd_setImageWithURL:[NSURL URLWithString:self.user.lastPost.coverImageUrl]];
//        } else {
//            [self.postContentLabel updateOriginX:self.postImageView.frame.origin.x];
//        }
//        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
//        [self.postContentLabel updateWidth:screenWidth - self.postContentLabel.frame.origin.x - 5];
//        self.postContentLabel.text = self.user.lastPost.content;
//        
//        [self.postHolderView updateOriginY:y];
//        y = y + self.postHolderView.frame.size.height + 10;
    } else {
        self.postHolderView.hidden = YES;
    }
    
    [(UIScrollView *)self.view setContentSize:CGSizeMake(self.view.frame.size.width, y)];
}

- (UITextView *)createSigntureTextView
{
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - WIDTH_SIGNTURE_TEXT_VIEW) / 2, 0, WIDTH_SIGNTURE_TEXT_VIEW, 200)] ;
    textView.backgroundColor = [UIColor clearColor];
    [textView setTextColor:[UIColor colorWithRed:147.0/255.0 green:147.0/255.0 blue:147.0/255.0 alpha:1]];
    textView.font = [UIFont systemFontOfSize:14];
    textView.scrollEnabled = NO;
    textView.editable = NO;
    if ([textView respondsToSelector:@selector(setSelectable:)]) {
        textView.selectable = NO;
    }
    return textView;
}

- (void)queryData
{
    [SportProgressView showWithStatus:@"请稍候"];
    if ([self isMyself]) {
        [UserService queryUserProfileInfo:self userId:_userId];
    } else {
        [UserService getUserInfo:self userId:_userId];
    }
}

- (void)didQueryUserProfileInfo:(User *)user status:(NSString *)status msg:(NSString *)msg
{
    [self handleDidGetUserInfo:user status:status msg:msg];
}

- (void)didGetUserInfo:(User *)user status:(NSString *)status msg:(NSString *)msg
{
    [self handleDidGetUserInfo:user status:status msg:msg];
}

- (void)handleDidGetUserInfo:(User *)user status:(NSString *)status msg:(NSString *)msg
{
    [SportProgressView dismiss];
    if ([status isEqualToString:STATUS_SUCCESS]) {
        self.user = user;
        [self updateUI];
        [self removeNoDataView];
    } else {
        [SportPopupView popupWithMessage:msg];
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44);
        [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:nil];
    }
}

- (void)didClickNoDataViewRefreshButton
{
    [self queryData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.user.oftenGoToForumList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [UserForumCell getCellIdentifier];
    UserForumCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [UserForumCell createCell];
        cell.delegate = self;
    }
    BOOL isLast = (indexPath.row == [self.user.oftenGoToForumList count] - 1);
    Forum *forum = [self.user.oftenGoToForumList objectAtIndex:indexPath.row];
    [cell updateCellWithForum:forum isLast:isLast];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [UserForumCell getCellHeight];
}

- (void)didClickUserForumCell:(Forum *)forum
{
    [MobClickUtils event:umeng_event_user_detail_click_often_business];
    
    ForumDetailController *controller = [[ForumDetailController alloc] initWithForum:forum] ;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark PostHoleView delegate
- (void)postHolderViewDidClickedWithTitle:(NSString *)title {
    [MobClickUtils event:umeng_event_user_detail_click_post];
    
    UserPostListController *controller = [[UserPostListController alloc] initWithUserId:_userId] ;
    controller.title = title;
    [self.navigationController pushViewController:controller animated:YES];
}


-(void) didSendMessage {
    if ([self isLoginAndShowLoginIfNot]) {
        
        ConversationViewController *conversationVC = [[ConversationViewController alloc]init];
        conversationVC.conversationType = ConversationType_PRIVATE;
        conversationVC.targetId = self.userId;
        conversationVC.title = self.user.nickname;
        
        [self.navigationController pushViewController:conversationVC animated:YES];
    }
}

@end
