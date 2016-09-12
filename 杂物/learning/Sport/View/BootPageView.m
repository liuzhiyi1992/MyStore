//
//  BootPageView.m
//  Sport
//
//  Created by haodong  on 14-5-7.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "BootPageView.h"
#import "UIView+Utils.h"
#import "AppGlobalDataManager.h"
#import "BootSingleView.h"

@interface BootPageView()
@property (assign, nonatomic) BOOL isRemoved;

@property (assign, nonatomic) int page;
@end

@implementation BootPageView

+ (BootPageView *)createBootPageView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"BootPageView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    
    BootPageView *view = (BootPageView *)[topLevelObjects objectAtIndex:0];
    [view addImage];
    [view addRecognizer];
    return view;
}

- (void)show
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [self setFrame:CGRectMake(0, 0, keyWindow.frame.size.width, keyWindow.frame.size.height)];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    [[AppGlobalDataManager defaultManager] setIsShowingBootPage:YES];
}

#define TOTAL_PAGE_COUNT 3
- (void)addImage
{
    CGFloat x;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    for (int i = 0 ; i < TOTAL_PAGE_COUNT; i ++) {
        
        x = i * width;
        BootSingleView *iv = [BootSingleView createBootSingleView];
        
        UIImage *mainImage = [SportImage mainBootPageImage:i];
        UIImage *titleImage = [SportImage titleBootPageImage:i];
        UIImage *subTitleImage = [SportImage subTitleBootPageImage:i];
        
        [iv.mainImageView setImage:mainImage];
        [iv.mainTitleImageView setImage:titleImage];
        [iv.subTitleImageView setImage:subTitleImage];
        
        [iv setBackgroundColor:[SportColor bootpageColor:i]];
        [iv setFrame:CGRectMake(x, 0, width, height)];
        iv.enterButton.hidden = YES;
//        if (i == TOTAL_PAGE_COUNT - 1) {
//            if (height == 480) {
//                iv.buttonYLayoutConstraint.constant = -100;
//            }
//            [iv setButtonStyle];
//            [iv.enterButton addTarget:self action:@selector(clickEnterButton:) forControlEvents:UIControlEventTouchUpInside];
//            iv.enterButton.hidden = YES;
//        }
        
        [self.mainScrollView addSubview:iv];
    }
    
    [self.mainScrollView setContentSize:CGSizeMake(width * TOTAL_PAGE_COUNT, height)];
    self.pageControl.numberOfPages = TOTAL_PAGE_COUNT;
    
}

- (void)addRecognizer
{
    //创建一个点击手势对象，该对象可以调用handelSingleTap：方法
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handelSingleTap:)];
    [self addGestureRecognizer:singleTap];
    [singleTap setNumberOfTouchesRequired:1];//触摸点个数
    [singleTap setNumberOfTapsRequired:1];//点击次数
}

-(void)handelSingleTap:(UITapGestureRecognizer*)gestureRecognizer{
    HDLog(@"handelSingleTap:");
    [self goNextPage];
}

- (void)remove
{
    if (_isRemoved == NO) {
        _isRemoved = YES;
        self.mainScrollView.delegate = nil;
        [UIView animateWithDuration:0.5 animations:^{
            [self updateOriginX:0-[UIScreen mainScreen].bounds.size.width];
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_FINISH_SHOW_BOOT_PAGE object:nil userInfo:nil];
            [[AppGlobalDataManager defaultManager] setIsShowingBootPage:NO];
        }];
    }
}

- (void)goNextPage
{
    CGPoint offset = _mainScrollView.contentOffset;
    int page = offset.x / _mainScrollView.frame.size.width;
    page ++;
    CGFloat x = page * _mainScrollView.frame.size.width;
    [_mainScrollView setContentOffset:CGPointMake(x, 0) animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    _page = offset.x / scrollView.frame.size.width;
    [_pageControl setCurrentPage:_page];
    
    //HDLog(@"scrollViewDidScroll:%f", offset.x);
    if (offset.x > (TOTAL_PAGE_COUNT - 1) * [UIScreen mainScreen].bounds.size.width + 60) {
        [self remove];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    [_pageControl setCurrentPage:offset.x / scrollView.frame.size.width];
    HDLog(@"scrollViewDidEndDecelerating:%f",offset.x);
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    HDLog(@"scrollViewDidZoom");
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_page == 0) {
        self.mainScrollView.bounces = NO;
        //self.backgroundColor = [SportColor defaultColor];
    } else {
        self.mainScrollView.bounces = YES;
        //self.backgroundColor = [UIColor clearColor];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    HDLog(@"scrollViewWillEndDragging");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
//    CGPoint offset = scrollView.contentOffset;
//    HDLog(@"scrollViewDidEndDragging:%f",offset.x);
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    HDLog(@"scrollViewWillBeginDecelerating");
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    HDLog(@"scrollViewDidEndScrollingAnimation");
}

- (void)clickEnterButton:(id)sender {
    [self remove];
}

@end
