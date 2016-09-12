//
//  AppDelegate.m
//  Sport
//
//  Created by haodong  on 13-6-4.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "AppDelegate.h"
#import "UserManager.h"
#import "SportNavigationController.h"
#import "BusinessService.h"
#import "AliPayManager.h"
#import "UIUtils.h"
#import "ConfigData.h"
#import "BootPageView.h"
#import "MobClick.h"
#import "MobClickUtils.h"
#import "UserService.h"
#import "SportProgressView.h"
#import "OrderService.h"
#import "BaseConfigManager.h"
#import "SDWebImageDownloader.h"
#import "WeChatPayManager.h"
#import "PriceUtil.h"
#import "SportUUID.h"
#import "HomeController.h"
#import "ActivityHomeController.h"
#import "OtherController.h"
#import "SportWebController.h"
#import "BusinessDetailController.h"
#import "MyVouchersController.h"
#import "OrderListController.h"
#import "LoginController.h"
#import "TipNumberManager.h"
#import "ForumHomeController.h"
#import "ForumService.h"
#import "AboutController.h"
#import "CommentMessageListController.h"
#import "ShareView.h"
#import "PrizeShareController.h"
#import "CoachListController.h"
#import "RongService.h"
#import "HistoryManager.h"
#import "ForumSearchManager.h"
#import "UIView+Utils.h"
#import "TencentOpenAPI/QQApiInterface.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "NSDictionary+JsonValidValue.h"
#import "BusinessSearchDataManager.h"
#import "PostDetailController.h"
#import "JPUSHService.h"
#import "GSJPushService.h"
#import "JPushManager.h"
#import "NSDate+Correct.h"
#import "DiscoverHomeController.h"
#import "HWWeakTimer.h"
#import "AppGlobalDataManager.h"
#import "SportApplicationContext.h"
#import "UnionPayManager.h"
#import "AFNetworkActivityLogger.h"
#import "MainController.h"
#import "MainHomeSignInGuideView.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>


@interface AppDelegate() <RCIMConnectionStatusDelegate,RCIMReceiveMessageDelegate,RongServiceDelegate,GSJPushServiceDelegate,UserServiceDelegate>
@property (strong, nonatomic) UIView *startView;
@property (assign, nonatomic) BOOL isShowingUpdateAlertView;
@property (strong, nonatomic) SportNavigationController *homeNavigationController;  // 2.0后弃用
@property (strong, nonatomic) SportNavigationController *coachNavigationController; // 2.0后弃用
@property (strong, nonatomic) SportNavigationController *forumNavigationController; //2.0后弃用
@property (strong, nonatomic) SportNavigationController *myNavigationController;
@property (strong, nonatomic) SportNavigationController *discoverNavigationController;
@property (strong, nonatomic) SportNavigationController *mainNavigationController;

@property (assign, nonatomic) int failCount;
@property (strong, nonatomic) NSTimer *accessTokenTimer;
@property (strong, nonatomic) NSDictionary *launchOptions;

@end

@implementation AppDelegate

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NAME_CHANGE_TIPS_COUNT object:nil];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:RCKitDispatchMessageNotification
     object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NAME_ACCESS_TOKEN_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NAME_DID_CHANGE_CITY object:nil];
}

#define KEY_LAST_TIME_GOSPORT_SERVER_ADDRESS @"KEY_LAST_TIME_GOSPORT_SERVER_ADDRESS"
/*如果服务器地址有变化则清空用户信息、浏览场馆历史、圈子搜索历史
此方法一般是正式服务器和测试服务器切换时起作用
 */
- (void)checkServerAddressChange
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *address = nil;
    address = [defaults objectForKey:KEY_LAST_TIME_GOSPORT_SERVER_ADDRESS];
    
    if (address == nil) {
        [defaults setObject:[ConfigData defaultHost] forKey:KEY_LAST_TIME_GOSPORT_SERVER_ADDRESS];
        [defaults synchronize];
    } else {
        
        if (![address isEqualToString:[ConfigData defaultHost]]) {
            //清空用户信息
            [[UserManager defaultManager] clearCurrentUser];
            
            //清空场馆浏览历史
            [[HistoryManager defaultManager] deleteAllBusinesses];
            
            //清空圈子搜索历史
            [ForumSearchManager clearHistroy];
            
            [defaults setObject:[ConfigData defaultHost] forKey:KEY_LAST_TIME_GOSPORT_SERVER_ADDRESS];
            [defaults synchronize];
            
            UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:nil
                                                                message:@"您切换服务器了，建议您删除此app，重新安装"
                                                               delegate:nil
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil] ;
            [alertView show];
        }
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Fabric with:@[[Crashlytics class]]];
#ifdef DEBUG
    id<AFNetworkActivityLoggerProtocol> logger = [AFNetworkActivityLogger sharedLogger].loggers.allObjects[0];
    [logger setLevel:AFLoggerLevelDebug];
    [[AFNetworkActivityLogger sharedLogger] startLogging];
#endif
    
    self.launchOptions = launchOptions;
    //用户登陆通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin) name:NOTIFICATION_NAME_DID_LOG_IN object:nil];
    //用户退出登陆通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogout) name:NOTIFICATION_NAME_DID_LOG_OUT object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateAllTipsCount)
                                                 name:NOTIFICATION_NAME_CHANGE_TIPS_COUNT
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestQydToken)
                                                 name:NOTIFICATION_NAME_ACCESS_TOKEN_FAILED
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(logoutAndCleanView)
                                                 name:NOTIFICATION_NAME_LOGIN_ENCODE_ERROR
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangeCity)
                                                 name:NOTIFICATION_NAME_DID_CHANGE_CITY
                                               object:nil];
    

    [self checkServerAddressChange];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    }

    //在info.plist文件里面 属性:View controller-based status bar appearance
    [application setStatusBarStyle:UIStatusBarStyleLightContent];//黑体白字
    
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:SINA_KEY];
    
    [WXApi registerApp:WEIXIN_APP_ID];
    
    [MobClick startWithAppkey:UMENG_KEY reportPolicy:BATCH channelId:UMENG_CHANNEL_ID];
    [MobClick setAppVersion:[UIUtils getAppVersion]];
    //弃用友盟在线参数
//    [MobClick updateOnlineConfig];
    
    //必须保证初始化融云SDK成功
    [[RCIM sharedRCIM] initWithAppKey:[ConfigData defaultAppKey]];
    
    //设置用户信息源
    [[RCIM sharedRCIM] setUserInfoDataSource:SportDataSource];
    [[RCIM sharedRCIM] setReceiveMessageDelegate:self];
    [[RCIM sharedRCIM] setConnectionStatusDelegate:self];
    [[RCIM sharedRCIM] setGlobalNavigationBarTintColor:[SportColor titleColor]];
    // 圆形头像
    [RCIM sharedRCIM].globalConversationAvatarStyle = RC_USER_AVATAR_CYCLE;
    if (iPhone6Plus) {
        [RCIM sharedRCIM].globalConversationPortraitSize = CGSizeMake(56, 56);
    } else {
        // NSLog(@"iPhone6 %d", iPhone6);
        [RCIM sharedRCIM].globalConversationPortraitSize = CGSizeMake(46, 46);
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds] ;
    UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if (storyBoard) {
        self.window.rootViewController = [storyBoard instantiateInitialViewController];
        [self.window makeKeyAndVisible];
        
        self.tabBarController = (UITabBarController *)self.window.rootViewController;
        self.tabBarController.delegate = self;
        
        //设置第一个controller

        self.mainNavigationController = (SportNavigationController *)[_tabBarController.viewControllers objectAtIndex:0];
        MainController *clc = [[MainController alloc] init];

        self.mainNavigationController.viewControllers = @[clc];
        
        //设置第二个controller
        self.discoverNavigationController = (SportNavigationController *)[_tabBarController.viewControllers objectAtIndex:1];
        DiscoverHomeController *dhc = [[DiscoverHomeController alloc] init];
        self.discoverNavigationController.viewControllers = @[dhc];
        
        //设置第三个controller
        self.myNavigationController = (SportNavigationController *)[_tabBarController.viewControllers objectAtIndex:2];
        OtherController *oc = [[OtherController alloc] init];
        self.myNavigationController.viewControllers = @[oc];
        
        if ([self.mainNavigationController.tabBarItem respondsToSelector:@selector(setSelectedImage:)]  &&
            [[SportImage tabBar1SelectedImage] respondsToSelector:@selector(imageWithRenderingMode:)]
            ) {
            
            //tabbar 阴影线
            //[[UITabBar appearance] setShadowImage:[UIImage imageNamed:@"lineImage"]];
            
            [self.mainNavigationController.tabBarItem setImage:[[UIImage imageNamed:@"tabbarMain"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            [self.forumNavigationController.tabBarItem setImage:[[UIImage imageNamed:@"tabbarDiscover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            [self.myNavigationController.tabBarItem setImage:[[UIImage imageNamed:@"tabbarPersonal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            
            [self.mainNavigationController.tabBarItem setSelectedImage:[[UIImage imageNamed:@"tabbarMainSelect"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            [self.forumNavigationController.tabBarItem setSelectedImage:[[UIImage imageNamed:@"TabbarDiscoverSelect"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            [self.myNavigationController.tabBarItem setSelectedImage:[[UIImage imageNamed:@"TabbarPersonalSelect"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        }
        //颜色
        [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           [SportColor tabbarWordTextColor], NSForegroundColorAttributeName,
                                                           nil] forState:UIControlStateNormal];
        [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           [SportColor defaultBlueColor], NSForegroundColorAttributeName,
                                                           nil] forState:UIControlStateSelected];
        
        [_tabBarController.tabBar setBackgroundColor:[UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1]];
        
//        if (launchOptions && [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {//判断程序是点击推送通知来启动的
//            NSDictionary *pushNotificationKey = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//            [self openWithRemoteNotification:pushNotificationKey];
//        }
        
    } else {
        HDLog(@"ERROR! Could not locate the initialViewController!");
    }
    
    [self showBootPage];
    
    [self showSignInGuideBelowBootPage];
    
    [self showStartImage];
    
    [AMapSearchServices sharedServices].apiKey = GAODE_APP_KEY;
    
//    [self updateTabBarRedPoint];
    
    return YES;
}

-(void) requestAccessTokenWithTimerInterval:(int)interval {
    if(self.accessTokenTimer){
        [self.accessTokenTimer invalidate];
        self.accessTokenTimer = nil;
    }
    
    self.accessTokenTimer = [HWWeakTimer scheduledTimerWithTimeInterval:interval block:^(id userInfo){
        [self requestQydToken];
    } userInfo:nil repeats:YES];
}
int retryQydCount = 0;

-(void) requestQydToken {
    
    if([[[UserManager defaultManager] readCurrentUser].userId length] > 0 && [UserManager readLoginEncode].length == 0) {
        // 异常情况，退出登录
        [self logoutAndCleanView];
        return;
    }
    
    __weak __typeof(self) weakSelf = self;

    [[BaseService defaultService] getQydTokenWithDevice:[SportUUID uuid] userId:[[UserManager defaultManager] readCurrentUser].userId loginEncode:[UserManager readLoginEncode] complete:^(NSString *status,NSString *msg,int expireTime) {
        [weakSelf didGetQydToken:status msg:msg expire:expireTime];
    }];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestQydToken) object:nil];

}

-(void) didGetQydToken:(NSString *)status msg:(NSString *)msg expire:(int)expireTime {
    // STATUS_LOGIN_ENCODE_ERROR也会收到一个可用的token
    if ([status isEqualToString:STATUS_SUCCESS] || [status isEqualToString:STATUS_LOGIN_ENCODE_ERROR]){
        retryQydCount = 0;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self initAppData];
        });
        
        if ([status isEqualToString:STATUS_LOGIN_ENCODE_ERROR]){
            //发通知执行退出登录操作,如果回到主线程才执行，在收到非登录token之后，仍然会使用user_id请求接口
            //[self loginEncodeFailedLogout];
        }
        
        int interval = REAL_EXPIRE_TIME(expireTime);
        [self requestAccessTokenWithTimerInterval:interval];
    } else {
         //放到子线程重试，这样在重试过程中可以一直不让其他请求进来
//        if(retryQydCount < 200) {
//            retryQydCount++;
//            //失败就重试
//            [self performSelector:@selector(requestQydToken) withObject:nil afterDelay:2];
//        }
    }
}

// loginEncode失败，重新登录
#define TAG_LOGIN_ENCODE_ERROR  20160518
-(void) logoutAndCleanView {
    
    //返回encode错误时后台会返回一个已退出登录的token

    SportNavigationController *navController = _tabBarController.selectedViewController;
    
    //login Encode失败，退出登录
    [UserManager didLogOut];
    
    //首页不提示重新登录的信息
    dispatch_async(dispatch_get_main_queue(), ^{
        
    if (navController != nil && (navController != self.mainNavigationController || [navController.viewControllers count] > 1)){
        
        //关闭所有alertView
        SportApplicationContext *context = [SportApplicationContext sharedContext];
        [context dismissAllAlertViews];
        [context dismissAllActionSheets];
        
        //remove 所有subView
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        if ([[UIApplication sharedApplication].keyWindow isMemberOfClass:[UIWindow class]]) {
            for (UIView *view in keyWindow.subviews) {
                if(![view isKindOfClass:[UIView class]]) {
                    continue;
                }
                
                NSUInteger index = [keyWindow.subviews indexOfObject:view];
                if (index == 0) {
                    continue;
                }
                
                [view removeFromSuperview];
            }
        }
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"登录过期" message:@"请重新登录" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        alert.tag = TAG_LOGIN_ENCODE_ERROR;
        [alert show];
    }
    });
}

#pragma mark-所有需要获取在App启动之后调用的网络请求都在这里写！
-(void) initAppData{
    
    //验证登录，由于刚刚获取到一个新的qyd_token，这里验证登录状态很可能成功
    //[self verifyLoginStatus];
    
    //调整App时间放在get_qyd_token上面
    //[[BaseService defaultService] getNowTime];
    
    [[BaseService defaultService] queryStaticData:self]; //请求配置数据
    
    //需要返回新的电话信息
    [self performSelector:@selector(queryUserInfo) withObject:self afterDelay:0.5];
    
    [self performSelector:@selector(queryForumSearchData) withObject:self afterDelay:3];
    
    //已经已登陆且有融云ID，马上连接服务器
    User *user = [[UserManager defaultManager] readCurrentUser];
    if (user != nil) {
        [[RongService defaultService] connectRongIM];
    }
    
    // 极光推送Required
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    } else {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                          UIRemoteNotificationTypeSound |
                                                          UIRemoteNotificationTypeAlert)
                                              categories:nil];
    }
    
    // 极光推送初始化
    [JPUSHService setupWithOption:self.launchOptions appKey:JPUSH_APP_KEY channel:JPUSH_CHANNEL apsForProduction:YES];
    [JPUSHService crashLogON];
#ifdef DEBUG

    [JPUSHService setDebugMode];
#endif
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    // 极光推送注册登录成功通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkDidLogin:) name:kJPFNetworkDidLoginNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(didReceiveMessageNotification:)
     name:RCKitDispatchMessageNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_ACCESS_TOKEN_SUCESS object:nil];
}

//极光推送登录成功之后的回调
- (void)networkDidLogin:(NSNotification *)notification {
    HDLog(@"...............DidLogin: %@",[JPUSHService registrationID]);
    [[JPushManager defaultManager] setIsLoginToJpush:YES];
    [self updateJPushToken];
    [self setJPushTags];
}

//向服务器更新token
- (void)updateJPushToken {
    [GSJPushService updatePushToken:self
                           userId:[[UserManager defaultManager] readCurrentUser].userId
                     iosPushToken:[UserManager readPushToken]
                   registrationId:[JPUSHService registrationID]
                         deviceId:[SportUUID uuid]];
}

// 向服务器推送更新token之后的回调
- (void)didUpdatePushTokenWithStatus:(NSString *)status msg:(NSString *)msg {
    if ([status isEqualToString:STATUS_SUCCESS]) {
        self.failCount = 0;
    }else{
        self.failCount += 1;
        
        if (self.failCount < 10) {
            [self performSelector:@selector(updateJPushToken) withObject:nil afterDelay:2];
            
        }
    }
}

//极光推送设置标签
- (void)setJPushTags {
    [[JPushManager defaultManager] setJPushTags];
}

- (void)didLogin {
    [self updateJPushToken];
    [self setJPushTags];

    // 记录用户信息
    [self logUser];
}

- (void)didLogout {
    [self updateJPushToken];
    [self setJPushTags];
    
}

- (void) logUser {
    // TODO: Use the current user's information
    // You can call any combination of these three methods
    User *user = [[UserManager defaultManager] readCurrentUser];
    if (user) {
        [CrashlyticsKit setUserIdentifier:user.userId];
        [CrashlyticsKit setUserName:user.nickname];
    } else {
        [CrashlyticsKit setUserIdentifier:nil];
        [CrashlyticsKit setUserName:nil];
    }
}


- (void)queryForumSearchData
{
    [ForumService searchStaticData:nil];
}

- (void)queryUserInfo
{
    if([[[UserManager defaultManager] readCurrentUser].userId length] >0){
        [UserService queryUserProfileInfo:self
                               userId:[[UserManager defaultManager] readCurrentUser].userId];
    }
}


- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    //如果没有static数据，重新读取
    if (![BaseConfigManager defaultManager].hasGetConfig) {
        [[BaseService defaultService] queryStaticData:self];
    }
    
    if (_mainNavigationController == viewController) {
        [MobClickUtils event:umeng_event_click_tab_bar_coach];
    } else if (_forumNavigationController == viewController) {
        [MobClickUtils event:umeng_event_click_tab_bar_forum];
    }
}

- (void)updateAllTipsCount
{
    if ([BaseConfigManager currentVersionIsInReView]) { //在审核版本
        return;
    }
    
    TipNumberManager *manager = [TipNumberManager defaultManager];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 包括客服消息，系统消息，特惠促销消息，IM消息会更新到第一个Tab红点
        NSUInteger homeCount = manager.customerServiceMessageCount + manager.systemMessageCount + manager.salesMessageCount + manager.forumMessageCount + manager.imReceiveMessageCount;
        if (homeCount > 0) {
            if (homeCount > 99) {
                homeCount = 99;
            }
            
            self.mainNavigationController.tabBarItem.badgeValue = [[NSString alloc]initWithFormat:@"%lu",(unsigned long)homeCount];
        }else {
            self.mainNavigationController.tabBarItem.badgeValue = nil;
        }
    
        //显示在我的页面，包括旧聊天记录，用户消息，未支付订单数，代金券数，新增会员卡
        NSUInteger myCount = manager.chatMessageCount + manager.userMessageCount + manager.needPayOrderCount + manager.voucherCount + manager.newCardCount;
        
        if (myCount > 0) {
            if (myCount > 99) {
                myCount = 99;
            }
            self.myNavigationController.tabBarItem.badgeValue = [@(myCount) stringValue];
            [self.tabBarController hideRedPointWithIndex:3];
        } else {
            self.myNavigationController.tabBarItem.badgeValue = nil;
            BOOL isShowSurvey = manager.isShowSurveyTips; //是否已经点击过问卷调查
            if (isShowSurvey) {
                [self.tabBarController showRedPointWithIndex:3];
            } else {
                [self.tabBarController hideRedPointWithIndex:3];
            }
        }
        
        NSUInteger totalCount = myCount + homeCount;

        //外面APP的红点
        [UIApplication sharedApplication].applicationIconBadgeNumber = totalCount;
        [JPUSHService setBadge:totalCount];

    });
}

- (void)openWithRemoteNotification:(NSDictionary *)userInfo
{ 
//    int type = [[[userInfo objectForKey:@"aps"] objectForKey:@"type"] intValue];
    int type = [[userInfo objectForKey:@"type"] intValue];
    
    UITabBarController *tabBarController =  (UITabBarController *)self.window.rootViewController;
    SportNavigationController *currentShowNavigationController = (SportNavigationController *)tabBarController.selectedViewController;
    
    if (type == 1 || type == 14) {
//        NSString *urlString = [[[userInfo objectForKey:@"aps"] objectForKey:@"d"] objectForKey:@"u"];
//        NSString *title = [[[userInfo objectForKey:@"aps"] objectForKey:@"d"] objectForKey:@"t"];
        NSString *urlString = [[userInfo objectForKey:@"d"] objectForKey:@"u"];
        NSString *title = [[userInfo objectForKey:@"d"] objectForKey:@"t"];
        
        SportWebController *controller = [[SportWebController alloc] initWithUrlString:urlString title:title] ;
        [currentShowNavigationController pushViewController:controller animated:YES];
        
    } else if (type == 2) {
//        NSString *bid = [[[userInfo objectForKey:@"aps"] objectForKey:@"d"] objectForKey:@"bid"];
//        NSString *cid = [[[userInfo objectForKey:@"aps"] objectForKey:@"d"] objectForKey:@"cid"];
        NSString *bid = [[userInfo objectForKey:@"d"] objectForKey:@"bid"];
        NSString *cid = [[userInfo objectForKey:@"d"] objectForKey:@"cid"];
        
        BusinessDetailController *contorller = [[BusinessDetailController alloc] initWithBusinessId:bid categoryId:cid] ;
        [currentShowNavigationController pushViewController:contorller animated:YES];
    }
    else if (type == 3) {
        if ([self isLoginAndShowLoginIfNot]) {
            MyVouchersController *contorller = [[MyVouchersController alloc] init] ;
            [currentShowNavigationController pushViewController:contorller animated:YES];
        }
    } else if (type == 5) {
        if ([self isLoginAndShowLoginIfNot]) {
            OrderListController  *contorller = [[OrderListController alloc] init] ;
            [currentShowNavigationController pushViewController:contorller animated:YES];
        }
    }
    else if (type == 6) {
        if ([self isLoginAndShowLoginIfNot]) {
            PrizeShareController *controller = [[PrizeShareController alloc] init] ;
         
            [currentShowNavigationController pushViewController:controller animated:YES];
        }
    }
    else if (type == 7) {
        if ([self isLoginAndShowLoginIfNot]) {
            CommentMessageListController *controller = [[CommentMessageListController alloc] init] ;
            [currentShowNavigationController pushViewController:controller animated:YES];
        }
    }else if (type == 15) {
        Post *post = [[Post alloc]init];
//        post.postId = [[[userInfo objectForKey:@"aps"] objectForKey:@"d"] objectForKey:@"pid"];
        post.postId = [[userInfo objectForKey:@"d"] objectForKey:@"pid"];
        
        PostDetailController *controller = [[PostDetailController alloc] initWithPost:post isShowTitle:YES] ;
        [currentShowNavigationController pushViewController:controller animated:YES];
    }
}

- (BOOL)isLoginAndShowLoginIfNot
{
    if ([UserManager isLogin]) {
        return YES;
    } else {
        UITabBarController *tabBarController =  (UITabBarController *)self.window.rootViewController;
        SportNavigationController *currentShowNavigationController = (SportNavigationController *)tabBarController.selectedViewController;
        LoginController *controller = [[LoginController alloc] init] ;
        [currentShowNavigationController pushViewController:controller animated:YES];
        return NO;
    }
}

- (void)didQueryStaticData:(NSString *)status resultDictionary:(NSDictionary *)resultDictionary
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [self checkAppVersion];
    }
    [self downLoadStartImageData];
}

#define START_IMAGE_NAME @"start_image"
- (NSString *)startImageFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [paths objectAtIndex:0];
    HDLog(@"document path:%@", documentDir);
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentDir, START_IMAGE_NAME];
    return filePath;
}

- (void)downLoadStartImageData
{
    NSString *urlString = [BaseConfigManager defaultManager].startupImageUrl;
    
    if ([urlString length] > 0) {
        
        NSString *downloadedStartupImageUrl = [BaseConfigManager readDownloadedStartupImageUrl];
        
        if (downloadedStartupImageUrl && [downloadedStartupImageUrl isEqualToString:urlString]) {
            //如果已下载此url的图片，则不需再下载
            return;
        }
        
        NSURL *url = [NSURL URLWithString:urlString];
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:url options:0 progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            if (finished && data) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSString *filePath = [self startImageFilePath];
                    BOOL succ = [data writeToFile:filePath atomically:YES];
                    if (succ) {
                        [BaseConfigManager saveDownloadedStartupImageUrl:urlString];
                    }
                });
            }
        }];
        
    } else {
        if ([BaseConfigManager defaultManager].hasGetConfig) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *path = [self startImageFilePath];
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            });
        }
    }
}

- (void)showStartImage
{
    UIImage *image = [UIImage imageWithContentsOfFile:[self startImageFilePath]];
    if (image) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        imageView.clipsToBounds = YES;
        [imageView setImage:image];
        
        self.startView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [_startView setBackgroundColor:[UIColor whiteColor]];
        [_startView addSubview:imageView];
        [[UIApplication sharedApplication].keyWindow addSubview:_startView];
        [self performSelector:@selector(removeStartImage) withObject:nil afterDelay:3];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_FINISH_SHOW_START_PAGE object:nil userInfo:nil];
    }
}

- (void)removeStartImage
{
    [UIView animateWithDuration:0.5 animations:^{
        [self.startView updateOriginX:0-[UIScreen mainScreen].bounds.size.width];
        self.startView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.startView removeFromSuperview];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_FINISH_SHOW_START_PAGE object:nil userInfo:nil];
    }];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    HDLog(@"deviceToken: %@", deviceToken);
    NSString *sourceToken = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    NSString *token = [sourceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *savedToken = [UserManager readPushToken];
    
    //如果token不一样，则上传到服务器保存
    if (![savedToken isEqualToString:token]) {
        
        [UserManager savePushToken:token];
        User *user = [[UserManager defaultManager] readCurrentUser];
        [GSJPushService updatePushToken:self
                              userId:user.userId
                           iosPushToken:token
                       registrationId:[JPUSHService registrationID]
                            deviceId:[SportUUID uuid]];
    }
    
    [[RongService defaultService] setDeviceToken:token];
    
    HDLog(@"token:%@",token);
    
    // 向极光服务器上报Device Token
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)didUpdatePushToken:(NSString *)status
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        if ([UserManager readHasUploadPushToken] == NO) {
            [UserManager saveHasUploadPushToken:YES];
        }
        
        if ([UserManager readHasUploadDeviceId] == NO) {
            [UserManager saveHasUploadDeviceId:YES];
        }
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    HDLog(@"Failed to get token, error: %@", error);
    
    if ([UserManager readHasUploadDeviceId] == NO) {
        User *user = [[UserManager defaultManager] readCurrentUser];
        [GSJPushService updatePushToken:self
                              userId:user.userId
                           iosPushToken:nil
                       registrationId:[JPUSHService registrationID]
                             deviceId:[SportUUID uuid]];
    }
}

//极光推送Required : 当注册了Backgroud Modes -> Remote notifications 后，notification 处理函数一律切换到下面函数，后台推送代码也在此函数中调用。
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if (application.applicationState == UIApplicationStateActive)// app was already in the foreground
    {
        User *user = [[UserManager defaultManager] readCurrentUser];
        if ([user.userId length] > 0) {
            [UserService getMessageCountList:nil userId:user.userId deviceId:[SportUUID uuid]];
        }
    } else {
        [self openWithRemoteNotification:userInfo];
    }
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [JPUSHService setBadge:0];
    
    // IOS 7 Support Required
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)showBootPage
{
    NSString *key = [NSString stringWithFormat:@"has_show_boot_page_%@", [UIUtils getAppVersion]];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL hasShowBootPage =  [userDefaults boolForKey:key];
    if (hasShowBootPage == NO) {
        [userDefaults setBool:YES forKey:key];
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
        {
            BootPageView *view = [BootPageView createBootPageView];
            [view show];
        }
    }
}

- (void)showSignInGuideBelowBootPage {
    NSString *currentVersion = [UIUtils getAppVersion];
    NSString *userDefaultKey = [NSString stringWithFormat:@"%@%@", KEY_IS_SHOW_SIGN_IN_GUIDE, currentVersion];
    BOOL isShowSignInGuide = [[NSUserDefaults standardUserDefaults] boolForKey:userDefaultKey];
    if (!isShowSignInGuide) {
        MainHomeSignInGuideView *signInGuideView = [MainHomeSignInGuideView createView];
        [signInGuideView updateWidth:[[UIScreen mainScreen] bounds].size.width];
        [signInGuideView updateHeight:[[UIScreen mainScreen] bounds].size.height];
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        UIView *bootPageView;
        for (UIView *subview in keyWindow.subviews) {
            if ([subview isKindOfClass:[BootPageView class]]) {
                bootPageView = subview;
            }
        }
        if (bootPageView != nil) {
            [keyWindow insertSubview:signInGuideView belowSubview:bootPageView];
        } else {
            [keyWindow addSubview:signInGuideView];
        }
    }
}

#define KEY_LAST_CANCEL_UPDATE_TIME @"KEY_LAST_CANCEL_UPDATE_TIME"
#define TAG_SHOW_UPDATE_ALERT_VIEW  2013100101
- (void)checkAppVersion
{
    if ([ConfigData isCheckNewVersion] == NO) {
        return;
    }
    
    BaseConfigManager *bcManager = [BaseConfigManager defaultManager];
    NSString *onLineVersion = [bcManager onLineAppVersion];
    NSString *currentVersion = [UIUtils getAppVersion];
    
    BOOL canUpate = [UIUtils checkHasNewVersionWithlocalVersion:currentVersion onlineVersion:onLineVersion];
    
    if (canUpate) {
        
        NSString *message = [bcManager updateAppMessage];
        if (message == nil || [message length] == 0) {
            message = @"检测到有新版本，是否更新？";
        }
        
        if ([bcManager isMustUpdateApp] && [UIUtils checkHasNewVersionWithlocalVersion:currentVersion onlineVersion:[bcManager mustUpdateAppVersion]] && _isShowingUpdateAlertView == NO) {
            self.isShowingUpdateAlertView = YES;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"升级提示" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            alertView.tag = TAG_SHOW_UPDATE_ALERT_VIEW;
            [alertView show];
            return;
        }
        
        NSInteger lastCancelUpdateTime = [[NSUserDefaults standardUserDefaults] integerForKey:KEY_LAST_CANCEL_UPDATE_TIME];
        int nowTime = [[NSDate correctDate] timeIntervalSince1970];
        
        BOOL isEnoughThreeDay = (nowTime - lastCancelUpdateTime > 60 * 60 * 24 * 3); //离上次点击取消按钮是否超过3天
        
        if (isEnoughThreeDay && _isShowingUpdateAlertView == NO) {
            self.isShowingUpdateAlertView = YES;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"升级提示" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alertView.tag = TAG_SHOW_UPDATE_ALERT_VIEW;
            [alertView show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_SHOW_UPDATE_ALERT_VIEW) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:[[NSDate correctDate] timeIntervalSince1970] forKey:KEY_LAST_CANCEL_UPDATE_TIME];
            [defaults synchronize];
            return;
        } else {
            [UIUtils openApp:APP_ID];
        }
        
        self.isShowingUpdateAlertView = NO;
    } else if (alertView.tag == TAG_LOGIN_ENCODE_ERROR) {
        
        SportNavigationController *navController = _tabBarController.selectedViewController;
        [navController dismissViewControllerAnimated:NO completion:nil];
        [navController popToRootViewControllerAnimated:NO];
        [self isLoginAndShowLoginIfNot];
        
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    HDLog(@"applicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    HDLog(@"applicationDidEnterBackground");
    
    [self updateAllTipsCount];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    HDLog(@"applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    HDLog(@"applicationDidBecomeActive");
    
    [self checkAppVersion];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [JPUSHService setBadge:0];
    [self requestQydToken];
    
    //第一次打开如果没有qydToken，则不调用接口。
    if([[AppGlobalDataManager defaultManager].qydToken length] > 0){
        //如果没有static数据，重新读取
        if (![BaseConfigManager defaultManager].hasGetConfig) {
            [[BaseService defaultService] queryStaticData:self];
        }
        
        //[SportProgressView dismiss]; //2014-12-13 注释掉，因为支付完成之后要显示loading刷新订单
        
        User *user = [[UserManager defaultManager] readCurrentUser];
        [UserService getMessageCountList:nil userId:user.userId deviceId:nil];
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    HDLog(@"applicationWillTerminate");
}

- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url
{
    HDLog(@"url absoluteString:%@",[url absoluteString]);
    
    if ([[url absoluteString] hasPrefix:[NSString stringWithFormat:@"wb%@", SINA_KEY]]){
        return [WeiboSDK handleOpenURL:url delegate:self];
    }
    else if ([[url absoluteString] hasPrefix:WEIXIN_APP_ID]){
        return [WXApi handleOpenURL:url delegate:self];
    }
    else if ([[url absoluteString] hasPrefix:@"tencent"]) {
        return [TencentOAuth HandleOpenURL:url];
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    HDLog(@"<application:openURL:sourceApplication:annotation> url=%@", url.absoluteString);
    HDLog(@"url absoluteString:%@",[url absoluteString]);
    if ([[url absoluteString] hasPrefix:@"alipay"]){
        [AliPayManager parseURL:url];
        return YES;
    }
    else if ([[url absoluteString] hasPrefix:[NSString stringWithFormat:@"wb%@", SINA_KEY]]){
        return [WeiboSDK handleOpenURL:url delegate:self];
    }
    else if ([[url absoluteString] hasPrefix:WEIXIN_APP_ID]){
        return [WXApi handleOpenURL:url delegate:self];
    }
    else if ([[url absoluteString] hasPrefix:@"tencent"]) {
        return [TencentOAuth HandleOpenURL:url];
    }
    else if ([[url absoluteString] hasPrefix:UPPAY_PAIED_URL_TYPES]) {
        [UnionPayManager handleUPPayResultWithUrl:url];
    }
    return YES;
}

#pragma mark - WeiboSDKDelegate
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    HDLog(@"didReceiveWeiboRequest:");
    if ([request isKindOfClass:WBProvideMessageForWeiboRequest.class])
    {
    }
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    HDLog(@"didReceiveWeiboResponse:");
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        
    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        [SNSManager defaultManager].sinaUserId = [(WBAuthorizeResponse *)response userID];
        [SNSManager saveSinaAccessToken:[(WBAuthorizeResponse *)response accessToken]];
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:[NSNumber numberWithInt:response.statusCode] forKey:SINA_WEIBO_AUTHORIZE_CALLBACK_RESULT];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SINA_WEIBO_AUTHORIZE_CALLBACK
                                                            object:self
                                                          userInfo:dic];
    }
}

#pragma mark - WXApiDelegate
/*! @brief 收到一个来自微信的请求，第三方应用程序处理完后调用sendResp向微信发送结果
 *
 * 收到一个来自微信的请求，异步处理完成后必须调用sendResp发送处理结果给微信。
 * 可能收到的请求有GetMessageFromWXReq、ShowMessageFromWXReq等。
 * @param req 具体请求内容，是自动释放的
 */
- (void)onReq:(BaseReq*)req
{
    
}

/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp具体的回应内容，是自动释放的
 */
- (void)onResp:(BaseResp*)resp
{
    if ([resp isKindOfClass:[PayResp class]]) {
        
        HDLog(@"微信支付返回");
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:[NSString stringWithFormat:@"%d", resp.errCode] forKey:@"error_code"];
        [dic setValue:resp.errStr forKey:@"error_message"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_FINISH_WECHAT_PAY object:nil userInfo:dic];
    } else if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *authResp = (SendAuthResp *)resp;
        HDLog(@"authResp.code:%@", authResp.code);
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:[NSString stringWithFormat:@"%d", resp.errCode] forKey:@"error_code"];
        [dic setValue:resp.errStr forKey:@"error_message"];
        [dic setValue:authResp.code forKey:@"code"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_FINISH_WECHAT_AUTH object:nil userInfo:dic];
    } else if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        if (resp.errCode == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_FINISH_SHARE_TO_WECHAT object:nil userInfo:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_SHARE_TO_WECHAT_FAIL object:nil userInfo:nil];
        }
    }
}

#pragma mark - RCIMConnectionStatusDelegate

/**
 *  网络状态变化。
 *
 *  @param status 网络状态。
 */
- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status {
    switch (status) {
        case ConnectionStatus_UNKNOWN:
        case ConnectionStatus_Unconnected:
        case ConnectionStatus_DISCONN_EXCEPTION:
            [[RongService defaultService] connectRongIM];
            break;
        default:
            break;
    }
}

-(void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left
{
}

- (void)didReceiveMessageNotification:(NSNotification *)notification {
    
    if ([BaseConfigManager currentVersionIsInReView]) { //在审核版本
        return;
    }
    
    int unreadMsgCount = [[RCIMClient sharedRCIMClient] getUnreadCount:@[@(ConversationType_PRIVATE)]];
    
    if ([[RongService defaultService] checkRongReady]) {
        [[TipNumberManager defaultManager] setImReceiveMessageCount:unreadMsgCount];
    } else {
        [[TipNumberManager defaultManager] setImReceiveMessageCount:0];
    }
}

- (void)didQueryUserProfileInfo:(User *)user
                         status:(NSString *)status
                            msg:(NSString *)msg {
    if (![status isEqualToString:STATUS_SUCCESS]) {
        
        User *me = [[UserManager defaultManager] readCurrentUser];
        //如果phoneEncode一直为空
        if (me && [me.phoneEncode length] == 0) {
            //必须保证这个接口能够返回phone_encode
            [self performSelector:@selector(queryUserInfo) withObject:self afterDelay:2];
        }
    }
}

//改变城市
- (void)didChangeCity {
    [[BaseService defaultService] queryStaticData:nil];
    [self setJPushTags];
}

@end
