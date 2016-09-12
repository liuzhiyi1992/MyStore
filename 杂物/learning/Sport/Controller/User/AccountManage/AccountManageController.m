//
//  AccountManageController.m
//  Sport
//
//  Created by haodong  on 13-7-31.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "AccountManageController.h"
#import "UserManager.h"
#import "OpenInfo.h"
#import "RegisterController.h"
#import "SportPopupView.h"
#import "ChangePasswordController.h"
#import "User.h"
#import "OpenInfo.h"
#import "SportProgressView.h"
#import "SNSManager.h"
#import "TipNumberManager.h"
#import "SportUUID.h"
#import "SetPasswordController.h"
#import "WXApi.h"
#import "WeixinManager.h"
#import "BaseConfigManager.h"

@interface AccountManageController ()
@property (strong, nonatomic) NSArray *dataList;
@property (strong, nonatomic) UserManager *userManager;
@end

#define TITLE_BIND_PHONE        @"绑定手机号"
#define TITLE_LOGIN_PASSWORD    @"登录密码"
#define TITLE_BIND_SINA_WEIBO   @"绑定新浪微博"
#define TITLE_BIND_QQ           @"绑定QQ"
#define TITLE_BIND_WECHAT       @"绑定微信"

@implementation AccountManageController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SINA_WEIBO_AUTHORIZE_CALLBACK object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NAME_FINISH_WECHAT_AUTH object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NAME_WECHAT_BIND_SUCCESS object:nil];
}

- (id)init
{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleSinaCallBack:)
                                                     name:NOTIFICATION_SINA_WEIBO_AUTHORIZE_CALLBACK
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(authWeChatBack:)
                                                     name:NOTIFICATION_NAME_FINISH_WECHAT_AUTH
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(bindWXSuccess)
                                                     name:NOTIFICATION_NAME_WECHAT_BIND_SUCCESS
                                                   object:nil];
    }
    return self;
}

- (void)viewDidUnload {
    [self setDataTableView:nil];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.dataTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = DDTF(@"kAccountManage");
    self.view.backgroundColor = [SportColor defaultPageBackgroundColor];
    self.userManager = [UserManager defaultManager];
    
    NSMutableArray *mutableArray = [NSMutableArray array];
    
    [mutableArray addObject:TITLE_BIND_PHONE];
    [mutableArray addObject:TITLE_LOGIN_PASSWORD];
    
    if ([ConfigData isShowThirdPartyLogin] && [BaseConfigManager currentVersionIsInReView] == NO) {
        [mutableArray addObject:TITLE_BIND_SINA_WEIBO];
        [mutableArray addObject:TITLE_BIND_QQ];
        [mutableArray addObject:TITLE_BIND_WECHAT];
    }
    
    self.dataList = mutableArray;
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [TitleValueCell getCellIdentifier];
    TitleValueCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [TitleValueCell createCell];
        cell.delegate = self;
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        cell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
    
    NSString *cellTitle = [_dataList objectAtIndex:indexPath.row];
    NSString *valueString = nil;
    
    if ([cellTitle isEqualToString:TITLE_BIND_PHONE]) {
        User *user  = [_userManager readCurrentUser];
        if ([[user phoneNumber] length] > 0) {
            valueString = user.phoneNumber;
        } else {
            valueString = DDTF(@"kNotBind");
        }
    } else if ([cellTitle isEqualToString:TITLE_LOGIN_PASSWORD]){
        
        User *user  = [_userManager readCurrentUser];
        if ([[user phoneNumber] length] > 0) {
            if (user.hasPassWord) {
                valueString = @"修改";
            } else {
                valueString = @"设置";
            }
        } else {
            valueString = @"(适用于绑定手机号的账号)";
        }
    } else if ([cellTitle isEqualToString:TITLE_BIND_SINA_WEIBO]) {
        OpenInfo *openInfo = [[_userManager readCurrentUser] openInfoWithType:OPEN_TYPE_SINA];
        if (openInfo) {
            if (openInfo.openNickname.length == 0) {
                valueString = @"已绑定";
            }else{
                valueString = openInfo.openNickname;
            }
        }
        if (valueString == nil) {
            valueString = DDTF(@"kNotBind");
        }
    } else if ([cellTitle isEqualToString:TITLE_BIND_QQ]) {
        OpenInfo *openInfo = [[_userManager readCurrentUser] openInfoWithType:OPEN_TYPE_QQ];
        if (openInfo) {
            valueString = (openInfo.openNickname ? openInfo.openNickname : @"已绑定") ;
        }
        if (valueString == nil) {
            valueString = DDTF(@"kNotBind");
        }
    }else if ([cellTitle isEqualToString:TITLE_BIND_WECHAT]) {
        OpenInfo *openInfo = [[_userManager readCurrentUser] openInfoWithType:OPEN_TYPE_WX];
        if (openInfo) {
            valueString = (openInfo.openNickname ? openInfo.openNickname : @"已绑定") ;
        }
        if (valueString == nil) {
            valueString = DDTF(@"kNotBind");
        }
    }
    
    BOOL isLast = (indexPath.row == [_dataList count] - 1 ? YES : NO);
    [cell updateCell:cellTitle
         valueString:valueString
           indexPath:indexPath
              isLast:isLast];
    return cell;
}

#pragma mark - UITableViewDeleagate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TitleValueCell getCellHeight];
}

#define TAG_BINGD_PHONE_ALERTVIEW   2013091401
#define TAG_BINGD_SINA_WEIBO_ALERTVIEW   2013091402
#define TAG_BINGD_QQ_ALERTVIEW      2013110101
#define TAG_BINGD_WECHAT_ALERTVIEW   2015103001
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellTitle = [_dataList objectAtIndex:indexPath.row];
    if ([cellTitle isEqualToString:TITLE_BIND_PHONE]) {
        if ([[_userManager readCurrentUser].phoneNumber length] > 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"你已经绑定了手机号，确定要绑定新的手机号？"
                                                               delegate:self
                                                      cancelButtonTitle:DDTF(@"kCancel")
                                                      otherButtonTitles:DDTF(@"kOK"), nil];
            alertView.tag = TAG_BINGD_PHONE_ALERTVIEW;
            [alertView show];
        } else {
            [self bindPhone];
        }
    } else if ([cellTitle isEqualToString:TITLE_LOGIN_PASSWORD]) {
        User *user = [[UserManager defaultManager] readCurrentUser];
        if ([user.phoneNumber length] > 0) {
            if (user.hasPassWord) {
                ChangePasswordController *controller = [[ChangePasswordController alloc] init] ;
                [self.navigationController pushViewController:controller animated:YES];
            } else {
                SetPasswordController *controller = [[SetPasswordController alloc] init] ;
                [self.navigationController pushViewController:controller animated:YES];
            }
        } else {
            [SportPopupView popupWithMessage:@"此功能至针对有绑定手机号的用户"];
        }
    } else if ([cellTitle isEqualToString:TITLE_BIND_SINA_WEIBO]) {
        BOOL found = NO;
        OpenInfo *openInfo = [[_userManager readCurrentUser] openInfoWithType:OPEN_TYPE_SINA];
        if (openInfo) {
            found = YES;
        }
        if (found) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"你已经绑定了新浪微博，确定要绑定新的微博账号？"
                                                               delegate:self
                                                      cancelButtonTitle:DDTF(@"kCancel")
                                                      otherButtonTitles:DDTF(@"kOK"), nil];
            alertView.tag = TAG_BINGD_SINA_WEIBO_ALERTVIEW;
            [alertView show];
        } else{
            [self bindSinaWeibo];
        }
    } else if ([cellTitle isEqualToString:TITLE_BIND_QQ]) {
        BOOL found = NO;
        OpenInfo *openInfo = [[_userManager readCurrentUser] openInfoWithType:OPEN_TYPE_QQ];
        if (openInfo) {
            found = YES;
        }
        if (found) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"你已经绑定了QQ，确定要绑定新的QQ账号？"
                                                               delegate:self
                                                      cancelButtonTitle:DDTF(@"kCancel")
                                                      otherButtonTitles:DDTF(@"kOK"), nil];
            alertView.tag = TAG_BINGD_QQ_ALERTVIEW;
            [alertView show];
        } else{
            [self bindQQ];
        }
    }else if ([cellTitle isEqualToString:TITLE_BIND_WECHAT]){
        BOOL found = NO;
        OpenInfo *openInfo = [[_userManager readCurrentUser] openInfoWithType:OPEN_TYPE_WX];
        if (openInfo) {
            found = YES;
        }
        if (found) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"你已经绑定了微信，确定要绑定新的微信账号？"
                                                               delegate:self
                                                      cancelButtonTitle:DDTF(@"kCancel")
                                                      otherButtonTitles:DDTF(@"kOK"), nil];
            alertView.tag = TAG_BINGD_WECHAT_ALERTVIEW;
            [alertView show];
        } else{
            [self bindWechat];
        }

    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_BINGD_PHONE_ALERTVIEW) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            return;
        } else {
            [self bindPhone];
        }
    } else if (alertView.tag == TAG_BINGD_SINA_WEIBO_ALERTVIEW) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            return;
        } else {
            //alertView 在iOS 8中有bug，延时才能执行
            [self performSelector:@selector(bindSinaWeibo) withObject:nil afterDelay:0.5];
//            [self bindSinaWeibo];
        }
    } else if (alertView.tag == TAG_BINGD_QQ_ALERTVIEW) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            return;
        } else {
            [self bindQQ];
        }
    }else if (alertView.tag == TAG_BINGD_WECHAT_ALERTVIEW) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            return;
        } else {
            [self bindWechat];
        }
    }
}

/**
 *  绑定微信
 */
- (void)bindWechat{
    SendAuthReq* req =[[SendAuthReq alloc ] init];
    req.scope = @"snsapi_userinfo" ;
    req.state = @"quyundong" ;
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
}

- (void)authWeChatBack:(NSNotification *)note{
    HDLog(@"authWeChatBack");
    NSDictionary *userInfo = note.userInfo;
    int errorCode = [[userInfo valueForKey:@"error_code"] intValue];
    NSString *code = [userInfo valueForKey:@"code"];
    
    if (errorCode == 0) {
        [[WeixinManager defaultManager] bind:code];
    }
}

- (void)bindWXSuccess{
    [self.dataTableView reloadData];
}

/**
 *  绑定手机
 */
- (void)bindPhone
{
    RegisterController *controller  = [[RegisterController alloc] initWithVerifyPhoneType:VerifyPhoneTypeBind] ;
    [self.navigationController pushViewController:controller animated:YES];
}

/**
 *  绑定QQ
 */
- (void)bindQQ
{
    [[QQManager defaultManager] authorize:self];
}

- (void)didAuthorize:(BOOL)isSuccess
{
    if (isSuccess) {
        [SportProgressView showWithStatus:DDTF(@"正在绑定...") hasMask:YES];
        [[QQManager defaultManager] getQQUserInfo:self];
    }else {
        [MobClickUtils event:umeng_event_bind_for_qq label:@"绑定失败"];
    }
}

- (void)didGetQQUserInfo:(NSDictionary *)jsonResponse
{
//    [SportProgressView dismiss];
    NSString *userId = [QQManager defaultManager].oauth.openId;
    NSString *accessToken = [QQManager defaultManager].oauth.accessToken;
    NSString *nickName = [jsonResponse objectForKey:@"nickname"];
    User *user = [_userManager readCurrentUser];
    [SportProgressView showWithStatus:@"正在绑定..."];
    
    [UserService unionBind:self
                    userId:user.userId
                    openId:userId
                   unionId:nil
               accessToken:accessToken
                  openType:OPEN_TYPE_QQ
                  nickName:nickName];
}

/**
 *  绑定新浪微博
 */
- (void)bindSinaWeibo
{
    [SNSManager sinaAuthorize];
}

- (void)handleSinaCallBack:(NSNotification *)note
{
    int code = [[note.userInfo objectForKey:SINA_WEIBO_AUTHORIZE_CALLBACK_RESULT] intValue];
    if (code == 0) {
        [SportProgressView showWithStatus:@"正在绑定..."];
        [SNSService getSinaWeiboUserInfo:self userId:[[SNSManager defaultManager] sinaUserId]];
    }
}

- (void)didGetSinaWeiboUserInfo:(NSDictionary *)userInfoDic
{
//    [SportProgressView dismiss];
    NSString *userId = [[SNSManager defaultManager] sinaUserId];
    NSString *accessToken = [SNSManager readSinaAccessToken];
    NSString *nickName = [userInfoDic objectForKey:@"screen_name"];
    User *user = [_userManager readCurrentUser];
    [SportProgressView showWithStatus:@"正在绑定..."];
    
    [UserService unionBind:self
                    userId:user.userId
                    openId:userId
                   unionId:nil
               accessToken:accessToken
                  openType:OPEN_TYPE_SINA
                  nickName:nickName];
    
}


/**
 *  绑定之后的回调
 */
- (void)didUnionBindWithStatus:(NSString *)status msg:(NSString *)msg {
    if ([status isEqualToString:STATUS_SUCCESS]) {
        User *user = [_userManager readCurrentUser];
        [UserService queryUserProfileInfo:self userId:user.userId];
    } else {
        [SportProgressView dismissWithError:msg];
    }
}

- (void)didQueryUserProfileInfo:(User *)user status:(NSString *)status msg:(NSString *)msg{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismissWithSuccess:@"绑定成功"];
    } else {
        [SportProgressView dismissWithError:@"绑定失败"];
    }
    [self.dataTableView reloadData];
}


@end
