//
//  SportController.m
//  Sport
//
//  Created by haodong  on 13-6-4.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SportController.h"
#import "SportProgressView.h"
#import "UIView+Utils.h"
#import "UserManager.h"
#import "LoginController.h"
#import "EditUserInfoController.h"
#import "UserInfoController.h"

@interface SportController ()
@property (strong, nonatomic) UILabel *titleLabel;
@end

@implementation SportController


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createBackButton];
    self.view.backgroundColor = [SportColor defaultPageBackgroundColor];
    
    //设置状态栏字体颜色为黑色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    
    //有导航栏时自动向下偏移
    self.navigationController.navigationBar.translucent = NO;
}

//页面名字，用于友盟统计
- (NSString *)pageName
{
    NSString *className = NSStringFromClass(self.class);
    
    //有title
    if (self.title) {
        
        //有title但是title会有多个值的
        if ([className isEqualToString:@"ForumDetailController"]) {
            return @"圈子详情";
        } else if ([className isEqualToString:@"WriteReviewController"]) {
            return @"发表评价";
        } else if ([className isEqualToString:@"BusinessListController"]) {
            return @"场馆列表";
        }
        
        //返回title
        else {
            return self.title;
        }
    }
    
    //没有title
    else {
        if ([className isEqualToString:@"HomeController"]) {
            return @"首页";
        } else if ([className isEqualToString:@"MapBusinessesController"]) {
            return @"地图";
        } else if ([className isEqualToString:@"ForumHomeController"]) {
            return @"发现";
        } else if ([className isEqualToString:@"ForumSearchController"]) {
            return @"圈子搜索";
        } else if ([className isEqualToString:@"BusinessListController"]) {
            return @"场馆列表";
        } else if ([className isEqualToString:@"SearchBusinessController"]) {
            return @"场馆搜索";
        } else if ([className isEqualToString:@"WriteReviewController"]) {
            return @"发表评价";
        } else {
            return className;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClickUtils beginLogPageView:[self pageName]];
    //NSLog(@"class是%@", self.class);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClickUtils endLogPageView:[self pageName]];
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    if (_titleLabel == nil) {
        [self createTitleView];
    }
    self.titleLabel.text = title;
}

- (BOOL)handleGestureNavigate
{
    return YES;
}

- (void)showNoDataViewWithType:(NoDataType)type
                          tips:(NSString *)tips
{
    [_noDataView removeFromSuperview];
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44);
    self.noDataView = [NoDataView createNoDataViewWithFrame:frame
                                                       type:type
                                                       tips:tips];
    self.noDataView.delegate = self;
    [self.view addSubview:_noDataView];
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
    [self.view addSubview:_noDataView];
}

- (void)removeNoDataView
{
    [_noDataView removeFromSuperview];
}

//子类继承该方法响应网络错误时的刷新按钮
- (void)didClickNoDataViewRefreshButton
{
    
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)deregsiterKeyboardNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (UIToolbar *)getNumberToolbar
{
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.translucent = YES;
    
    [numberToolbar setBarTintColor:[UIColor colorWithRed:206.0/255.0 green:211.0/255.0 blue:215.0/255.0 alpha:1]];
    
    
    //numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStyleBordered target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    
    return numberToolbar;
}

-(void)cancelNumberPad{
}

-(void)doneWithNumberPad{
}

- (void) keyboardWasShown:(NSNotification *) notif{
}

- (void)keyboardWasHidden:(NSNotification *) notif{
}

- (BOOL)isLoginAndShowLoginIfNot
{
    if ([UserManager isLogin]) {
        return YES;
    } else {
        LoginController *controller = [[LoginController alloc] init];
        
        [self.navigationController pushViewController:controller animated:YES];
        return NO;
    }
}

-(void) showUserDetailControllerWithUserId:(NSString *)userId {
    if([userId length] == 0) {
        return;
    }
    UIViewController *controller = nil;

    controller = [[UserInfoController alloc] initWithUserId:userId];
    [self.navigationController pushViewController:controller animated:YES];
}

- (BOOL)previousControllerIsCertainController:(NSString *)controllerClassName
{
    NSUInteger count = [self.navigationController.viewControllers count];
    if (count > 2) {
        if ([[self.navigationController.viewControllers objectAtIndex:count - 2] isKindOfClass:NSClassFromString(controllerClassName)]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

@end
