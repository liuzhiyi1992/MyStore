//
//  AboutSportController.m
//  Sport
//
//  Created by haodong  on 14-5-5.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "AboutSportController.h"
#import "SportCommonCell.h"
#import "FeedbackController.h"
#import "UIUtils.h"
#import "SportPopupView.h"
#import "AboutController.h"
#import "SportProgressView.h"
#import "FileUtil.h"
#import "BaseConfigManager.h"
#import "AccountManageController.h"
#import "UserManager.h"
#import "SportUUID.h"
#import "TipNumberManager.h"
#import "LoginController.h"

@interface AboutSportController ()
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (strong, nonatomic) NSArray *dataList;
@end

#define TITLE_ACCOUNT_MANAGE    @"账号管理"
#define TITLE_CLEANUP_CACHE     @"清理缓存"
#define TITLE_ABOUT             @"关于趣运动"
//#define TITLE_UPDATE            @"版本更新" //因为苹果审核规则的变更，去掉版本更新功能

@implementation AboutSportController

- (void)viewDidUnload {
    [self setDataTableView:nil];
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"设置";
    NSMutableArray *mutableArray = [NSMutableArray array];
    
    [mutableArray addObject:[NSArray arrayWithObjects:TITLE_ACCOUNT_MANAGE, nil]];

    [mutableArray addObject:[NSArray arrayWithObjects:TITLE_ABOUT,TITLE_CLEANUP_CACHE, nil]];
    
    self.dataList = mutableArray;
    
    [self.logoutButton setBackgroundImage:[SportImage logoutButtonImage] forState:UIControlStateNormal];
    [self updateLogoutButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateLogoutButton];
}

#define TAG_LOGOUT_ALERTVIEW 2014090301
- (void)updateLogoutButton
{
    if ([UserManager isLogin]) {
        self.logoutButton.hidden =  NO;
    } else {
        self.logoutButton.hidden = YES;
    }
}


- (IBAction)clickLogoutButton:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"确定要退出当前账号?"
                                                       delegate:self
                                              cancelButtonTitle:DDTF(@"kCancel")
                                              otherButtonTitles:DDTF(@"kOK"), nil];
    alertView.tag = TAG_LOGOUT_ALERTVIEW;
    [alertView show];
   // [alertView release];
}

- (void)didLogout:(NSString *)status
{
    [SportProgressView dismiss];

    [self updateLogoutButton];
    //在子线程完成didLogOut
    //[UserManager didLogOut];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_LOGOUT_ALERTVIEW) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            return;
        } else {
            User *user = [[UserManager defaultManager] readCurrentUser];
            [SportProgressView showWithStatus:@"退出登录" hasMask:YES];
            [UserService logout:self
                         userId:user.userId];
        }
    }
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_dataList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *list = [_dataList objectAtIndex:section];
    return [list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [SportCommonCell getCellIdentifier];
    SportCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [SportCommonCell createCell];
    }
    
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        cell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
    
    NSArray *list = [_dataList objectAtIndex:indexPath.section];
    NSString *cellTitle = [list objectAtIndex:indexPath.row];
    BOOL isLast = (indexPath.row == [list count] - 1 ? YES : NO);
    
    [cell updateCell:cellTitle indexPath:indexPath isLast:isLast tipsCount:0 isShowRedPoint:NO];
    return cell;
}

#pragma mark - UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [SportCommonCell getCellHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 11;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero] ;
}

#define TAG_FIRST_SHARE     100
#define TAG_WEIXIN_SHARE    101
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *list = [_dataList objectAtIndex:indexPath.section];
    NSString *cellTitle = [list objectAtIndex:indexPath.row];
    
    if([cellTitle isEqualToString:TITLE_ACCOUNT_MANAGE])
    {
        [self showAccountManage];
    }
    else if ([cellTitle isEqualToString:TITLE_CLEANUP_CACHE]) {
        [self cleanupCache];
    }
    else if ([cellTitle isEqualToString:TITLE_ABOUT]) {
        [self showAbout];
    }

    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

- (void)showNativeFeedback
{
    FeedbackController *controller = [[FeedbackController alloc] init] ;
    [self.navigationController pushViewController:controller animated:YES];
}

- (BOOL)isHasNewVersion
{
    NSString *onlineVersion = [[BaseConfigManager defaultManager] onLineAppVersion];
    NSString *current = [UIUtils getAppVersion];
    return [UIUtils checkHasNewVersionWithlocalVersion:current onlineVersion:onlineVersion];
}

- (void)checkAppVersion
{
    if ([self isHasNewVersion]) {
        [UIUtils openApp:APP_ID];
    } else {
        [SportPopupView popupWithMessage:@"已经是最新版本"];
    }
}

- (void)showAbout
{
    AboutController *controller = [[AboutController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)showAccountManage
{
    if ([self isLoginAndShowLoginIfNot]) {
        AccountManageController *controller = [[AccountManageController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)cleanupCache
{
    [SportProgressView showWithStatus:@"正在清理..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *imageCachePath = [NSString stringWithFormat:@"%@/%@",[FileUtil getAppCacheDir], @"com.hackemist.SDWebImageCache.default"];
        NSString *forumCachePath = [NSString stringWithFormat:@"%@/%@",[FileUtil getAppCacheDir], @"com.qiuhaodong.sport.ForumCache"];
        NSArray *list = @[imageCachePath, forumCachePath];
        
        for (NSString *onePath in list) {
            HDLog(@"cache path:%@", onePath);
            [FileUtil clearOnlyFilesAtPath:onePath];
        }
        sleep(1);
        
        //HDLog(@"finish clean cache:%lfM", fileSize / 1024.0 / 1024.0);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SportProgressView dismissWithSuccess:@"清理完成"];
        });
    });
}

@end
