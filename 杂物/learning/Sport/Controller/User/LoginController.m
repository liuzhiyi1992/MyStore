//
//  LoginController.m
//  Sport
//
//  Created by haodong  on 13-6-6.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "LoginController.h"
#import "SportProgressView.h"
#import "SportPopupView.h"
#import "SportNavigationController.h"
#import "OpenInfo.h"
#import "SNSManager.h"
#import "UserManager.h"
#import "UIView+Utils.h"
#import "WXApi.h"
#import "WeixinManager.h"
#import "SportUUID.h"
#import "FastLoginController.h"
#import "NSDictionary+JsonValidValue.h"
#import "BaseConfigManager.h"
#import "AppDelegate.h"

@interface LoginController ()
@property (assign, nonatomic) BOOL isCanUseOtherLogin;
@property (assign, nonatomic) BOOL isOpenOtherLoginHolderView;
@end

@implementation LoginController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SINA_WEIBO_AUTHORIZE_CALLBACK object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NAME_FINISH_WECHAT_AUTH object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NAME_WECHAT_LOGIN_SUCCESS object:nil];
}

- (instancetype)initWithIsCanUseOtherLogin:(BOOL)isCanUseOtherLogin
{
    self = [super init];
    if (self) {
        self.isCanUseOtherLogin = isCanUseOtherLogin;
        [self initData];
    }
    return self;
}

- (instancetype)init
{
    self = [self initWithIsCanUseOtherLogin:YES];
    return self;
}

- (void)initData
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSinaCallBack:)
                                                 name:NOTIFICATION_SINA_WEIBO_AUTHORIZE_CALLBACK
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(authWeChatBack:)
                                                 name:NOTIFICATION_NAME_FINISH_WECHAT_AUTH
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(weChatLoginSuccess:)
                                                 name:NOTIFICATION_NAME_WECHAT_LOGIN_SUCCESS
                                               object:nil];
}

- (void)viewDidUnload {
    [self setPhoneNumberTextField:nil];
    [self setPasswordTextField:nil];
    [self setLoginButton:nil];
    [self setSinaWeiboButton:nil];
    [self setQqButton:nil];
    [super viewDidUnload];
}

- (BOOL)handleGestureNavigate
{
    [SportProgressView dismiss];
    return YES;
}

- (void)clickBackButton:(id)sender
{
    [SportProgressView dismiss];
    //[(SportNavigationController *)self.navigationController setCanDragBack:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.phoneNumberTextField.text length] == 0) {
        self.phoneNumberTextField.text = [UserManager readLoginPhone];
    }
    
    //[(SportNavigationController *)self.navigationController setCanDragBack:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = DDTF(@"kLogin");
    self.view.backgroundColor = [SportColor loginPageColor];
    
    if ([UserManager getFirstLoginPage]
        || [self previousControllerIsFastLoginController]) {
        self.firstOpenHolderView.hidden = YES;
        
        [self createRightTopButton:@"忘记密码"];
        
    } else {
        self.firstOpenHolderView.hidden = NO;

    }
    
    [self.mainScrollView updateHeight:[UIScreen mainScreen].bounds.size.height - 20 - 44];
    [self.mainScrollView setContentSize:CGSizeMake(self.mainScrollView.frame.size.width, self.mainScrollView.frame.size.height + 1)];
    
    [self.firstInputBackgroundImageView setImage:[SportImage otherCellBackground1Image]];
    [self.secondBackgroundImageView setImage:[SportImage otherCellBackground3Image]];
    
    [self.registerButton setTitleColor:[SportColor defaultColor] forState:UIControlStateNormal];
    [self.SMSLoginButton setTitleColor:[SportColor defaultColor] forState:UIControlStateNormal];
    
    [self.sinaWeiboButton setImage:[SportImage sinaWeiboImage] forState:UIControlStateNormal];
    [self.qqButton setImage:[SportImage qqImage] forState:UIControlStateNormal];
    [self.weChatButton setImage:[SportImage wechatImage] forState:UIControlStateNormal];
    
    self.phoneNumberTextField.textColor = [SportColor content1Color];
    self.passwordTextField.textColor = [SportColor content1Color];
    self.phoneNumberTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
    if ([ConfigData isShowThirdPartyLogin] && [BaseConfigManager currentVersionIsInReView] == NO) {
        
        if (_isCanUseOtherLogin) {
            self.otherLoginHolderView.hidden = NO;
            [self.otherLoginHolderView updateOriginY:[UIScreen mainScreen].bounds.size.height - 20 - 44 - 40];
        } else {
            self.otherLoginHolderView.hidden = YES;
        }
        
    } else {
        self.otherLoginHolderView.hidden = YES;
    }
    
    if ([self previousControllerIsFastLoginController]) {
        self.SMSLoginButton.hidden = YES;
    }
    
    self.phoneNumberTextField.inputAccessoryView = [self getNumberToolbar];
}

-(void)doneWithNumberPad{
    [self.phoneNumberTextField resignFirstResponder];
    [self.passwordTextField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.passwordTextField) {
        [self doLogin];
    } else {
        [self.phoneNumberTextField resignFirstResponder];
    }
    
    return YES;
}

- (IBAction)clickFirstOpenLoginButton:(id)sender {
    [_firstOpenHolderView removeFromSuperview];
    [self createRightTopButton:@"忘记密码"];
}

- (IBAction)clickFirstOpenRegisterButton:(id)sender {
    [self pushRegisterController];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.phoneNumberTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (IBAction)touchBackground:(id)sender {
    [self.phoneNumberTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (IBAction)clickLoginButton:(id)sender {
    [self doLogin];
}

-(void) doLogin {
    [self.phoneNumberTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    if ([self.phoneNumberTextField.text length] == 0) {
        [SportPopupView popupWithMessage:@"请输入电话号码"];
        return;
    }
    if ([self.passwordTextField.text length] == 0) {
        [SportPopupView popupWithMessage:@"请输入密码"];
        return;
    }
    
    [SportProgressView showWithStatus:DDTF(@"kLoggingIn")];
    [UserService login:self
           phoneNumber:_phoneNumberTextField.text
              password:_passwordTextField.text];
}

- (IBAction)clickRegisterButton:(id)sender {
    [self pushRegisterController];
}

// Should handle forget password.
- (IBAction)clickRightTopButton:(id)sender {
    RegisterController *controller = [[RegisterController alloc] initWithVerifyPhoneType:VerifyPhoneTypeForgotPassword phoneNumber:_phoneNumberTextField.text];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didRestPasswordAndBack:(NSString *)phoneNumber
{
    self.phoneNumberTextField.text = phoneNumber;
}

- (IBAction)clickSinaWeiboButton:(id)sender {
    [SNSManager sinaAuthorize];
}

- (IBAction)clickQQButton:(id)sender {
    [[QQManager defaultManager] authorize:self];
}

- (void)handleSinaCallBack:(NSNotification *)note
{
    dispatch_async(dispatch_get_main_queue(), ^{
        int code = [[note.userInfo objectForKey:SINA_WEIBO_AUTHORIZE_CALLBACK_RESULT] intValue];
        if (code == 0) {
            [SportProgressView showWithStatus:DDTF(@"kLoggingIn") hasMask:YES];
            [SNSService getSinaWeiboUserInfo:self userId:[[SNSManager defaultManager] sinaUserId]];
        }
    });
}

- (void)didGetSinaWeiboUserInfo:(NSDictionary *)userInfoDic
{
    dispatch_async(dispatch_get_main_queue(), ^{
//        [SportProgressView dismiss];
        NSString *userId = [[SNSManager defaultManager] sinaUserId];
        NSString *accessToken = [SNSManager readSinaAccessToken];
        NSString *nickName = [userInfoDic valueForKey:@"screen_name"];
        NSString *gender = [userInfoDic valueForKey:@"gender"];
        NSString *avatar = [userInfoDic valueForKey:@"avatar_large"];
        
        [self openLoginWithOpenUserId:userId
                          accessToken:accessToken
                         openNickName:nickName
                               gender:gender
                               avatar:avatar
                                  age:0
                             openType:OPEN_TYPE_SINA];
    });
}
//微博，qq登陆回调
- (void)openLoginWithOpenUserId:(NSString *)openUserId
                    accessToken:(NSString *)accessToken
                   openNickName:(NSString *)openNickName
                         gender:(NSString *)gender
                         avatar:(NSString *)avatar
                            age:(int)age
                       openType:(NSString *)openType 
{
    [SportProgressView showWithStatus:DDTF(@"kLoggingIn") hasMask:YES];
    
    [UserService unionLogin:self openId:openUserId unionId:nil accessToken:accessToken openType:openType nickName:openNickName gender:gender avatar:avatar];
    
}

#pragma mark - QQManagerDelegate
- (void)didAuthorize:(BOOL)isSuccess
{
    if (isSuccess) {
        [SportProgressView showWithStatus:DDTF(@"kLoggingIn") hasMask:YES];
        [[QQManager defaultManager] getQQUserInfo:self];
    }else {
        [MobClickUtils event:umeng_event_login_for_qq label:@"登陆失败"];
    }
}

- (void)didGetQQUserInfo:(NSDictionary *)jsonResponse
{
    [SportProgressView dismiss];
    NSString *userId = [QQManager defaultManager].oauth.openId;
    NSString *accessToken = [QQManager defaultManager].oauth.accessToken;
    NSString *nickName = [jsonResponse valueForKey:@"nickname"];
    NSString *avatar = [jsonResponse valueForKey:@"figureurl_qq_2"];
    NSString *genderSource = [jsonResponse valueForKey:@"gender"];
    NSString *gender = nil;
    
    if ([genderSource isEqualToString:@"男"]) {
        gender = @"m";
    } else if ([genderSource isEqualToString:@"女"]) {
        gender = @"f";
    }
    
    [self openLoginWithOpenUserId:userId
                      accessToken:accessToken
                     openNickName:nickName
                           gender:gender
                           avatar:avatar
                              age:0
                         openType:OPEN_TYPE_QQ];
}

#define TAG_ALERTVIEW_NOT_REGISTER  2015020301
#define TAG_ALERTVIEW_NO_PASSWORD   2015020302

#pragma mark  - UserServiceDelegate
- (void)didLogin:(NSString *)userId
          status:(NSString *)status
             msg:(NSString *)msg
           phone:(NSString *)phone
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismissWithSuccess:DDTF(@"kLoginSuccess")];
        [UserService queryUserProfileInfo:nil userId:userId];
        [self didLoginSuccess];
    } else {
        if ([status isEqualToString:STATUS_NOT_REGISTER]) {
            [SportProgressView dismiss];
            
            NSString *message = [NSString stringWithFormat:@"该手机号%@尚未注册趣运动", phone];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"马上注册",nil];
            alertView.tag = TAG_ALERTVIEW_NOT_REGISTER;
            [alertView show];
            
        } else if ([status isEqualToString:STATUS_NO_PASSWORD]) {
            
            NSString *message = @"该手机号仅通过短信验证登录，尚未设置密码";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"短信验证登录", nil];
            alertView.tag = TAG_ALERTVIEW_NO_PASSWORD;
            [alertView show];
            
        } else {
            [SportProgressView dismissWithError:msg];
        }
    }
}

- (void)didUnionLogin:(NSString *)status msg:(NSString *)msg data:(NSDictionary *)data openId:(NSString *)openId unionId:(NSString *)unionId accessToken:(NSString *)accessToken openType:(NSString *)openType avatar:(NSString *)avatar nickName:(NSString *)nickName gender:(NSString *)gender {
    if ([status isEqualToString:STATUS_SUCCESS]) {
        if ([data validStringValueForKey:PARA_PHONE].length > 0) {//成功&&有电话资料
            [SportProgressView dismissWithSuccess:@"登陆成功"];
            [self didLoginSuccess];
            
            //友盟统计
            if ([openType isEqualToString:@"wx"]) {
                [MobClickUtils event:umeng_event_login_for_wx label:@"登陆成功"];
            } else if ([openType isEqualToString:@"qq"]){
                [MobClickUtils event:umeng_event_login_for_qq label:@"登陆成功"];
            } else if ([openType isEqualToString:@"sina"]) {
                [MobClickUtils event:umeng_event_login_for_sina label:@"登陆成功"];
            }
        } else {//没有电话资料
            RegisterController *controller = [[RegisterController alloc] initWithVerifyPhoneType:VerifyPhoneTypeBindUnionLogin];
            controller.delegate = self;
            
            objc_setAssociatedObject(controller, &kOpenIdKey, openId, OBJC_ASSOCIATION_COPY_NONATOMIC);
            objc_setAssociatedObject(controller, &kUnionIdKey, unionId, OBJC_ASSOCIATION_COPY_NONATOMIC);
            objc_setAssociatedObject(controller, &kAccessTokenKey, accessToken, OBJC_ASSOCIATION_COPY_NONATOMIC);
            objc_setAssociatedObject(controller, &kOpenTypeKey, openType, OBJC_ASSOCIATION_COPY_NONATOMIC);
            objc_setAssociatedObject(controller, &kAvatarKey, avatar, OBJC_ASSOCIATION_COPY_NONATOMIC);
            objc_setAssociatedObject(controller, &kNickNameKey, nickName, OBJC_ASSOCIATION_COPY_NONATOMIC);
            objc_setAssociatedObject(controller, &kGenderKey, gender, OBJC_ASSOCIATION_COPY_NONATOMIC);
            
            [self.navigationController pushViewController:controller animated:YES];
        }
    } else {
        if (msg) {
            [SportProgressView dismissWithError:msg];
        } else {
            [SportProgressView dismissWithError:DDTF(@"kLoginFail")];
        }
    }
}


//unionPhone RegisterConrtoller delegate
- (void)didUnionPhoneWithStatus:(NSString *)status msg:(NSString *)msg {
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismissWithSuccess:DDTF(@"kLoginSuccess")];
        [self didLoginSuccess];
    }
    //不成功在方法调用前已处理
}

- (void)pushRegisterController
{
    RegisterController *controller = [[RegisterController alloc] initWithVerifyPhoneType:VerifyPhoneTypeRegiser phoneNumber:_phoneNumberTextField.text] ;
    controller.loginDelegate = self.loginDelegate;
    controller.loginDelegateParameter = self.loginDelegateParameter;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_ALERTVIEW_NOT_REGISTER) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            return;
        }
        [self performSelector:@selector(pushRegisterController) withObject:nil afterDelay:0.25];
    } else if (alertView.tag == TAG_ALERTVIEW_NO_PASSWORD) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            [SportProgressView dismiss];
            return;
        }
        [self performSelector:@selector(pushFastLoginController) withObject:nil afterDelay:0.25];
    }
}

- (void)pushFastLoginController
{
    if ([self previousControllerIsCertainController:@"FastLoginController"]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        FastLoginController *controller = [[FastLoginController alloc] init] ;
        controller.defaultPhone = _phoneNumberTextField.text;
        controller.loginDelegate = _loginDelegate;
        controller.loginDelegateParameter = _loginDelegateParameter;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)didLoginSuccess
{
    [UserManager didLoginSuccessWithPhoneNumber:_phoneNumberTextField.text];
    
//    [self updatePushToken];
    
    BOOL animated = (self.loginDelegate == nil);
    
    if ([self previousControllerIsFastLoginController]) { //如果前一个Controller是FastLoginController，则退两页
        NSUInteger count = [self.navigationController.viewControllers count];
        NSUInteger targetIndex = (count >= 3 ? count - 3  : 0 );
        UIViewController *targetController = [self.navigationController.childViewControllers objectAtIndex:targetIndex];
        [self.navigationController popToViewController:targetController animated:animated];
    } else {
         [self.navigationController popViewControllerAnimated:animated];
    }
    
    if ([_loginDelegate respondsToSelector:@selector(didLoginAndPopController:)]) {
        [_loginDelegate didLoginAndPopController:_loginDelegateParameter];
    }

}

//- (void)updatePushToken
//{
//    User *user = [[UserManager defaultManager] readCurrentUser];
//    NSString *pushToken = [UserManager readPushToken];
//    if (pushToken != nil) {
//        [UserService updatePushToken:nil
//                              userId:user.userId
//                           pushToken:pushToken
//                            deviceId:[SportUUID uuid]];
//    }
//}

- (IBAction)clickWeChatButton:(id)sender {
    
    SendAuthReq* req =[[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo" ;
    req.state = @"quyundong" ;
    //第三方向微信终端发送一个SendAuthReq消息结构
    //[WXApi sendReq:req];
    //支持不安装微信的情况下登录
    [WXApi sendAuthReq:req viewController:self delegate:(AppDelegate *)[[UIApplication sharedApplication] delegate]];
}

- (void)authWeChatBack:(NSNotification *)note
{
    HDLog(@"authWeChatBack");
    NSDictionary *userInfo = note.userInfo;
    int errorCode = [[userInfo valueForKey:@"error_code"] intValue];
    NSString *errorMessage = [userInfo valueForKey:@"error_message"];
    NSString *code = [userInfo valueForKey:@"code"];
    
    if (errorCode == 0) {
        [SportProgressView showWithStatus:@"正在登陆" hasMask:YES];
        [[WeixinManager defaultManager] login:code];
    } else {
        if (errorMessage) {
            [SportPopupView popupWithMessage:errorMessage];
        } else {
            [SportPopupView popupWithMessage:@"网络错误，请重试"];
        }
    }
}

//微信登陆回调
- (void)weChatLoginSuccess:(NSNotification *)note
{
    NSDictionary *infoDict = note.object;
    NSString *status = [infoDict objectForKey:PARA_STATUS];
    NSString *msg = [infoDict objectForKey:PARA_MSG];
    NSDictionary *data = [infoDict objectForKey:PARA_DATA];
    NSString *openId = [infoDict objectForKey:PARA_OPEN_ID];
    NSString *unionId = [infoDict objectForKey:PARA_UNION_ID];
    NSString *openType = [infoDict objectForKey:PARA_OPEN_TYPE];
    NSString *accessToken = [infoDict objectForKey:PARA_ACCESS_TOKEN];
    NSString *avatar = [infoDict objectForKey:PARA_AVATAR];
    NSString *gender = [infoDict objectForKey:PARA_GENDER];
    NSString *nickName = [infoDict objectForKey:PARA_NICK_NAME];
    
    [self didUnionLogin:status msg:msg data:data openId:openId unionId:unionId accessToken:accessToken openType:openType avatar:avatar nickName:nickName gender:gender];
}

- (IBAction)clickOpenOtherButton:(id)sender {
    
    self.isOpenOtherLoginHolderView = !_isOpenOtherLoginHolderView;
    
    if (_isOpenOtherLoginHolderView) {
        
        [UIView animateWithDuration:0.2 animations:^{
            [self.otherLoginHolderView updateOriginY:[UIScreen mainScreen].bounds.size.height - 20 - 44 - _otherLoginHolderView.frame.size.height];
        } completion:^(BOOL finished) {
            [self.triangleImageView setImage:[SportImage triangleDownImage]];
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            [self.otherLoginHolderView updateOriginY:[UIScreen mainScreen].bounds.size.height - 20 - 44 - 40];
        } completion:^(BOOL finished) {
            [self.triangleImageView setImage:[SportImage triangleUpImage]];
        }];
    }
}

- (IBAction)clickSMSLogin:(id)sender {
    [self pushFastLoginController];
}

- (BOOL)previousControllerIsFastLoginController //前一个Controller是否FastLoginController
{
    NSUInteger count = [self.navigationController.viewControllers count];
    if (count > 2) {
        if ([[self.navigationController.viewControllers objectAtIndex:count - 2] isKindOfClass:[FastLoginController class]]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

@end
