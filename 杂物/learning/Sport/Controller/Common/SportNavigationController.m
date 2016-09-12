//
//  SportNavigationController.m
//  Sport
//
//  Created by haodong  on 13-9-22.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SportNavigationController.h"
#import <QuartzCore/QuartzCore.h>
#import "SportProgressView.h"
#import "UIView+Utils.h"
#import "AppDelegate.h"
#import "SportController.h"
#import "DeviceDetection.h"

#define KEY_WINDOW  [[UIApplication sharedApplication] keyWindow]

@interface SportNavigationController ()
@end

@implementation SportNavigationController

- (void)initDefaultSetting
{
    [self.navigationBar setBackgroundImage:[SportImage navigationBarImage] forBarMetrics:UIBarMetricsDefault];
    
    if (DeviceSystemMajorVersion() >= 7) {
        self.navigationBar.clipsToBounds = NO;
    } else {
        self.navigationBar.clipsToBounds = YES;
    }
    
    //IOS导航隐藏下边的线
    //self.navigationBar.shadowImage = [[UIImage alloc] init];
    
    self.navigationBar.translucent = NO; ////解决导航栏遮住view的问题
    
    //统一导航条样式
    NSDictionary *textAttributes = @{
                                     NSForegroundColorAttributeName : [SportColor titleColor]
                                     };
    [[UINavigationBar appearance] setTitleTextAttributes:textAttributes];
    [[UINavigationBar appearance] setTintColor:[SportColor titleColor]];
    [[UINavigationBar appearance]
     setBarTintColor:[UIColor whiteColor]];
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        [self initDefaultSetting];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initDefaultSetting];
    }
    return self;
}

- (void)dealloc
{
    self.interactivePopGestureRecognizer.delegate = nil;
    self.delegate = nil;
    //[super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = self;
        self.delegate = self;
    }
}

//统一处理非root controller
- (void)preProcessPushViewController:(UIViewController *)viewController {
    [SportProgressView dismiss];
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    if (self.viewControllers.count > 0) { // 如果现在push的不是栈底控制器(最先push进来的那个控制器)
        viewController.hidesBottomBarWhenPushed = YES;
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self preProcessPushViewController:viewController];

    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    [SportProgressView dismiss];
    return [super popViewControllerAnimated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [SportProgressView dismiss];
    return [super popToViewController:viewController animated:animated];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    [SportProgressView dismiss];
    return [super popToRootViewControllerAnimated:animated];
}

#pragma mark - UINavigationControllerDelegate
// 优化, root view controller 禁用
- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animate
{
    if ([navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        if ([navigationController.viewControllers count] == 1) {
            navigationController.interactivePopGestureRecognizer.enabled = NO;
        } else {
            // Enable the interactive pop gesture
            navigationController.interactivePopGestureRecognizer.enabled = YES;
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isEqual:self.interactivePopGestureRecognizer]) {
        NSUInteger count = [self.childViewControllers count];
        if (count > 1) {
            SportController *controller = [self.childViewControllers objectAtIndex:count - 1];
            
            if ([controller respondsToSelector:@selector(handleGestureNavigate)]) {
                return [controller handleGestureNavigate];
            }
        }
    }
    
    return YES;
    
}

- (void) pushNewControllerAndClearStackToParent:(UIViewController*)newController animated:(BOOL)animated
{
    NSArray *viewControllers = self.viewControllers;
    NSMutableArray *newViewControllers = [NSMutableArray array];
    
    // preserve the root view controller
    [newViewControllers addObject:[viewControllers firstObject]];
    
    //统一处理非root的controller
    [self preProcessPushViewController:newController];
    
    // add the new view controller
    [newViewControllers addObject:newController];
    
    // animatedly change the navigation stack
    [self setViewControllers:newViewControllers animated:animated];
}

@end
