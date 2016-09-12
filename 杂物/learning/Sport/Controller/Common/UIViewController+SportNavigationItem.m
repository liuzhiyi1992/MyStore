//
//  UIViewController+SportNavigationItem.m
//  Sport
//
//  Created by qiuhaodong on 15/5/26.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "UIViewController+SportNavigationItem.h"
#import "UIView+Utils.h"
#import "DeviceDetection.h"

@implementation UIViewController (SportNavigationItem)

#define WIDTH_COUNT_BUTTON  16
//创建一个数字提示
- (UIButton *)createNavigationBarTipsCountButtonWithX:(CGFloat)x
{
    UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(x, 3, WIDTH_COUNT_BUTTON, WIDTH_COUNT_BUTTON)] ;
    [button setBackgroundImage:[SportImage countBackgroundRedImage] forState:UIControlStateNormal];
    [button setUserInteractionEnabled:NO];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:10]];
    button.hidden = YES;
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    return button;
}

#define WIDTH_RED_POINT     6
//创建一个红点提示
- (UIImageView *)createNavigationBarRedPointImageViewWithX:(CGFloat)x
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 6, WIDTH_RED_POINT, WIDTH_RED_POINT)] ;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [imageView setImage:[SportImage countBackgroundRedImage]];
    imageView.hidden = YES;
    return imageView;
}

#define WIDTH_RIGHT_BUTTON  50
#define HEIGHT_RIGHT_BUTTON 44
#define SIZE_FOUT           14
//创建一个基本的按钮
- (UIButton *)createNavigationBarBaseButton
{
    CGFloat width = WIDTH_RIGHT_BUTTON;
    CGFloat height = HEIGHT_RIGHT_BUTTON;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    button.titleLabel.font = [UIFont systemFontOfSize:SIZE_FOUT];
    [button setTitleColor:[SportColor titleColor] forState:UIControlStateNormal];
    [button setTitleColor:[SportColor inputTextFieldColor] forState:UIControlStateDisabled];
    [button setTitleColor:[UIColor colorWithRed:109.0/255.0 green:109.0/255.0 blue:109.0/255.0 alpha:1] forState:UIControlStateHighlighted];
    return button;
}

#define RIGHT_TOP_TIPS_COUNT_BUTTON      2015052603
#define RIGHT_TOP_RED_POINT_IMAGE_VIEW   2015052604
//创建右上角公共按钮
- (UIButton *)createNavigationBarRightButton
{
    //设置按钮
    UIButton *button = [self createNavigationBarBaseButton];
    [button addTarget:self action:@selector(clickRightTopButton:) forControlEvents:UIControlEventTouchUpInside];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    
    //设置红色背景的数字
    UIButton *rightTopTipsCountButton = [self createNavigationBarTipsCountButtonWithX:button.frame.size.width - 4];
    rightTopTipsCountButton.tag = RIGHT_TOP_TIPS_COUNT_BUTTON;
    [button addSubview:rightTopTipsCountButton];
    
    //设置红点
    UIImageView *rightTopRedPointImageView = [self createNavigationBarRedPointImageViewWithX:button.frame.size.width - 4];
    rightTopRedPointImageView.tag = RIGHT_TOP_RED_POINT_IMAGE_VIEW;
    [button addSubview:rightTopRedPointImageView];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button] ;
    self.navigationItem.rightBarButtonItem = buttonItem;
    
    return button;
}

//创建右上角按钮
- (void)createRightTopButton:(NSString *)buttonTitle
{
    UIButton *button = [self createNavigationBarRightButton];
    [button setTitle:buttonTitle forState:UIControlStateNormal];
    CGSize size = [button sizeThatFits:button.frame.size];
    [button updateWidth:MAX(size.width, WIDTH_RIGHT_BUTTON)];
}

//创建右上角图片按钮
- (void)createRightTopImageButton:(UIImage *)buttonImage
{
    UIButton *button = [self createNavigationBarRightButton];
    [button setImage:buttonImage forState:UIControlStateNormal];
}

//点击右上角按钮
- (void)clickRightTopButton:(id)sender
{
    HDLog(@"clickRightTopButton");
}

//清除右上角按钮
- (void)cleanRightTopButton
{
    self.navigationItem.rightBarButtonItem = nil;
}

#define LEFT_TOP_TIPS_COUNT_BUTTON      2015052601
#define LEFT_TOP_RED_POINT_IMAGE_VIEW   2015052602
//创建左上角公共按钮
- (UIButton *)createNavigationBarLeftButton
{
    //设置按钮
    UIButton *button = [self createNavigationBarBaseButton];
    [button addTarget:self action:@selector(clickLeftTopButton:) forControlEvents:UIControlEventTouchUpInside];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    //设置红色背景的数字
    UIButton *leftTopTipsCountButton = [self createNavigationBarTipsCountButtonWithX:button.frame.size.width - 4];
    leftTopTipsCountButton.tag = LEFT_TOP_TIPS_COUNT_BUTTON;
    [button addSubview:leftTopTipsCountButton];
    
    //设置红点
    UIImageView *leftTopRedPointImageView = [self createNavigationBarRedPointImageViewWithX:button.frame.size.width - 4];
    leftTopRedPointImageView.tag = LEFT_TOP_RED_POINT_IMAGE_VIEW;
    [button addSubview:leftTopRedPointImageView];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button] ;
    self.navigationItem.leftBarButtonItem = buttonItem;
    
    return button;
}

//创建左上角按钮
- (void)createLeftTopButton:(NSString *)buttonTitle
{
    UIButton *button = [self createNavigationBarLeftButton];
    [button setTitle:buttonTitle forState:UIControlStateNormal];
    CGSize size = [button sizeThatFits:button.frame.size];
    [button updateWidth:size.width];
}

//创建左上角图片按钮
- (void)createLeftTopImageButton:(UIImage *)buttonImage
{
    UIButton *button = [self createNavigationBarLeftButton];
    [button setImage:buttonImage forState:UIControlStateNormal];
}

//点击左上角
-(void)clickLeftTopButton:(id)sender
{
    HDLog(@"clickLeftTopButton");
}

//清除左上角
- (void)cleanLeftTopButton
{
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)showRightTopTipsCount:(NSUInteger)count
{
    if (count > 99) {
        count = 99;
    }
    
    UIButton *button = (UIButton *)[self.navigationItem.rightBarButtonItem.customView viewWithTag:RIGHT_TOP_TIPS_COUNT_BUTTON];
    button.hidden = NO;
    [button setTitle:[@(count) stringValue] forState:UIControlStateNormal];
}

- (void)hideRightTopTipsCount
{
    [self.navigationItem.rightBarButtonItem.customView viewWithTag:RIGHT_TOP_TIPS_COUNT_BUTTON].hidden = YES;
}

- (void)showRightTopRedPoint
{
    [self.navigationItem.rightBarButtonItem.customView viewWithTag:RIGHT_TOP_RED_POINT_IMAGE_VIEW].hidden = NO;
}

- (void)hideRightTopRedPoint
{
    [self.navigationItem.rightBarButtonItem.customView viewWithTag:RIGHT_TOP_RED_POINT_IMAGE_VIEW].hidden = YES;
}

- (void)showLeftTopTipsCount:(NSUInteger)count
{
    if (count > 99) {
        count = 99;
    }
    
    UIButton *button = (UIButton *)[self.navigationItem.rightBarButtonItem.customView viewWithTag:LEFT_TOP_TIPS_COUNT_BUTTON];
    button.hidden = NO;
    [button setTitle:[@(count) stringValue] forState:UIControlStateNormal];
}

- (void)hideLeftTopTipsCount
{
    [self.navigationItem.rightBarButtonItem.customView viewWithTag:LEFT_TOP_TIPS_COUNT_BUTTON].hidden = YES;
}

- (void)showLeftTopRedPoint
{
    [self.navigationItem.rightBarButtonItem.customView viewWithTag:LEFT_TOP_RED_POINT_IMAGE_VIEW].hidden = NO;
}

- (void)hideLeftTopRedPoint
{
    [self.navigationItem.rightBarButtonItem.customView viewWithTag:LEFT_TOP_RED_POINT_IMAGE_VIEW].hidden = YES;
}


- (UIButton *)createTitleButton
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 75, 30)] ;
    [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [button setTitleColor:[SportColor defaultColor] forState:UIControlStateNormal];
    return button;
}

#define TAG_LEFT_TITLE_BUTTON 1001
#define TAG_RIGHT_TITLE_BUTTON 1002
#define LEFT_TITLE_TIPS_COUNT_BUTTON 1003
#define RIGHT_TITLE_TIPS_COUNT_BUTTON 1004
//创建头部切换的tab
- (void)createTitleViewWithleftButtonTitle:(NSString *)leftButtonTitle
              rightButtonTitle:(NSString *)rightButtonTitle
{
    self.leftTitleButton = [self createTitleButton];
    self.leftTitleButton.tag = TAG_LEFT_TITLE_BUTTON;
    [self.leftTitleButton updateOriginX:0];
    
    [self.leftTitleButton roundSide:CornerSideLeft size:15 borderColor:[SportColor defaultColor].CGColor borderWidth:2.0];

    [self.leftTitleButton setBackgroundImage:[SportColor createImageWithColor:[SportColor defaultColor]] forState:UIControlStateSelected];
//    [self.leftTitleButton setBackgroundImage:[SportImage whiteFrameLeftButtonImage] forState:UIControlStateNormal];
//    [self.leftTitleButton setBackgroundImage:[SportImage tabLeftButtonFrame] forState:UIControlStateSelected];
    [self.leftTitleButton setTitle:leftButtonTitle forState:UIControlStateNormal];
    [self.leftTitleButton addTarget:self action:@selector(clickLeftTitleButton:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.rightTitleButton = [self createTitleButton];
    self.rightTitleButton.tag = TAG_RIGHT_TITLE_BUTTON;
    [self.rightTitleButton updateOriginX:75];
    [self.rightTitleButton roundSide:CornerSideRight size:15 borderColor:[SportColor defaultColor].CGColor borderWidth:2.0];

    
    [self.rightTitleButton setBackgroundImage:[SportColor createImageWithColor:[SportColor defaultColor]] forState:UIControlStateSelected];
//    [self.rightTitleButton setBackgroundImage:[SportImage whiteFrameRightButtonImage] forState:UIControlStateNormal];
//    [self.rightTitleButton setBackgroundImage:[SportImage tabRightButtonFrame] forState:UIControlStateSelected];
    [self.rightTitleButton setTitle:rightButtonTitle forState:UIControlStateNormal];
    [self.rightTitleButton addTarget:self action:@selector(clickRightTitleButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 29)] ;
    [titleView setBackgroundColor:[UIColor clearColor]];
    [titleView addSubview:self.leftTitleButton];
    [titleView addSubview:self.rightTitleButton];
    
    //设置红色背景的数字
    UIButton *leftTopTipsCountButton = [self createNavigationBarTipsCountButtonWithX:1];
    leftTopTipsCountButton.tag = LEFT_TITLE_TIPS_COUNT_BUTTON;
    [leftTopTipsCountButton updateOriginY:0];
    [titleView addSubview:leftTopTipsCountButton];

    //设置红色背景的数字
    UIButton *rightTopTipsCountButton = [self createNavigationBarTipsCountButtonWithX:titleView.frame.size.width - 10];
    rightTopTipsCountButton.tag = RIGHT_TITLE_TIPS_COUNT_BUTTON;
    [rightTopTipsCountButton updateOriginY:0];
    [titleView addSubview:rightTopTipsCountButton];
    
    self.navigationItem.titleView = titleView;
}

- (void)showLeftTitleTipsCount:(NSUInteger)count
{
    if (count > 99) {
        count = 99;
    }
    
    UIButton *button = (UIButton *)[self.navigationItem.titleView viewWithTag:LEFT_TITLE_TIPS_COUNT_BUTTON];
    button.hidden = NO;

    [button setTitle:[@(count) stringValue] forState:UIControlStateNormal];
}

- (void)showRightTitleTipsCount:(NSUInteger)count
{
    if (count > 99) {
        count = 99;
    }
    
    UIButton *button = (UIButton *)[self.navigationItem.titleView viewWithTag:RIGHT_TITLE_TIPS_COUNT_BUTTON];
    button.hidden = NO;
    [button setTitle:[@(count) stringValue] forState:UIControlStateNormal];
}

- (void)hideLeftTitleTipsCount
{
    [self.navigationItem.titleView viewWithTag:LEFT_TITLE_TIPS_COUNT_BUTTON].hidden = YES;
}

- (void)hideRightTitleTipsCount
{
    [self.navigationItem.titleView viewWithTag:RIGHT_TITLE_TIPS_COUNT_BUTTON].hidden = YES;
}

- (void)selectedLeftButton
{
    self.leftTitleButton.selected = YES;
    self.rightTitleButton.selected = NO;
    
    //重写此方法时必须调用super
}

- (void)selectedRightButton
{

    self.leftTitleButton.selected = NO;
    self.rightTitleButton.selected = YES;
    
    //重写此方法时必须调用super
}

- (void)clickLeftTitleButton:(id)sender
{
    [self selectedLeftButton];
}

- (void)clickRightTitleButton:(id)sender
{
    [self selectedRightButton];
}

- (void)createTitleView
{
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
    //根据屏幕宽度调整title宽度
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width/2, 44)] ;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = [SportColor titleColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:18];
    self.navigationItem.titleView = self.titleLabel;
}

//左上角返回按钮
- (void)createBackButton
{
    if ([[self.navigationController childViewControllers] count] > 1) {
        CGFloat buttonWith = 44;
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWith, 44)] ;
        if (DeviceSystemMajorVersion() >= 7) {
            [button setImageEdgeInsets:UIEdgeInsetsMake(0, -24, 0, 0)];
        }
        [button setImage:[SportImage backButtonImage] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button] ;
        self.navigationItem.leftBarButtonItem = buttonItem;
    }
}

- (void)clickBackButton:(id)sender
{
    if ([self.navigationController.childViewControllers count] <= 1) {
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
