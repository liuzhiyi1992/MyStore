//
//  HomeHeaderView.m
//  Sport
//
//  Created by qiuhaodong on 15/5/22.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "HomeHeaderView.h"
#import "UIView+Utils.h"
#import "UIImageView+WebCache.h"
#import "BusinessCategory.h"
#import "SportAd.h"
#import <CoreLocation/CoreLocation.h>
#import "UserManager.h"
#import "FastOrderEntrance.h"
#import "Order.h"

@interface HomeHeaderView()

@property (assign, nonatomic) id<HomeHeaderViewDelegate> delegate;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSArray *categoryList;
@property (strong, nonatomic) NSArray *bannerList;

@property (weak, nonatomic) IBOutlet UIView *categoryHolderView;
@property (weak, nonatomic) IBOutlet UIScrollView *categoryScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *categoryControl;
@property (weak, nonatomic) IBOutlet UIView *bannerHolderView;
@property (weak, nonatomic) IBOutlet UIScrollView *bannerScrollView; //弃用，改用sportLazyScrollView
@property (strong, nonatomic) SportLazyScrollView *sportLazyScrollView;
@property (strong, nonatomic) NSMutableArray*    viewControllerArray;
@property (weak, nonatomic) IBOutlet UIPageControl *bannerControl;
@property (weak, nonatomic) IBOutlet UIView *noListDataTipsHolderView;
@property (weak, nonatomic) IBOutlet UILabel *noListDataTipsLabel;
//@property (weak, nonatomic) IBOutlet UIView *filterHolderView;
//@property (weak, nonatomic) IBOutlet UIView *moveLineView;
//@property (weak, nonatomic) IBOutlet UIButton *hotBusinessButton;
//@property (weak, nonatomic) IBOutlet UIButton *historyBusinessButton;
//@property (weak, nonatomic) IBOutlet UIImageView *clubImageView;
@property (weak, nonatomic) IBOutlet UIView *fastOrderEntranceView;
@property (weak, nonatomic) IBOutlet UIImageView *categoryIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *businessNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (strong, nonatomic) FastOrderEntrance *entrance;

@end

@implementation HomeHeaderView


+ (HomeHeaderView *)createHomeHeaderViewWithDelegate:(id<HomeHeaderViewDelegate>)delegate
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"HomeHeaderView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    HomeHeaderView *view = (HomeHeaderView *)[topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    
    view.categoryScrollView.scrollsToTop = NO;
    view.bannerScrollView.scrollsToTop = NO;
//    CGSize labelSize = [view.historyBusinessButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
//    CGFloat x = [UIScreen mainScreen].bounds.size.width * 3/ 4 + labelSize.width/2;
//    [view.clubImageView updateOriginX:x];
    
//    view.hotBusinessButton.selected = YES;
//    view.historyBusinessButton.selected = NO;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    [view updateWidth:screenWidth];
    
    [view initBackgroundImages];
    return view;
}

- (void)initBackgroundImages
{
    for (UIView *first in self.subviews) {
        for (UIView *second in first.subviews) {
            if (second.tag == 200 && [second isKindOfClass:[UIImageView class]]) {
                [(UIImageView *)second setImage:[SportImage whiteBackgroundImage]];
            }
        }
    }
}

- (void)updateViewWithCategoryList:(NSArray *)categoryList
                        bannerList:(NSArray *)bannerList
                        courseList:(NSArray *)courseList
                 fastOrderEntrance:(FastOrderEntrance *)entrance
{
    self.categoryList = categoryList;
    self.bannerList = bannerList;
    self.entrance = entrance;
    
    [self reloadCategory];
    [self reloadAD];
    [self reloadFastOrderEntrance];
    [self updateAllViewSite];
    
//    if (courseList.count == 0) {
//        [self.historyBusinessButton setTitle:@"最近浏览" forState:UIControlStateNormal];
//        [self.clubImageView setHidden:YES];
//    }else{
//        [self.historyBusinessButton setTitle:@"推荐课程" forState:UIControlStateNormal];
//        [self.clubImageView setHidden:NO];
//    }
//    
//    CLLocation  *location = [[UserManager defaultManager] readUserLocation];
//    if (location == nil) {
//        [self.hotBusinessButton setTitle:@"热门球馆" forState:UIControlStateNormal];
//    }else{
//        [self.hotBusinessButton setTitle:@"推荐场馆" forState:UIControlStateNormal];
//    }

}

- (void)updateFastViewWithFastOrderEntrance:(FastOrderEntrance *)entrance
{
    self.entrance = entrance;
    [self updateAllViewSite];
}

#define SPABE_BETWEEN_HOLDERVIEW 15
#define FILTRATEBUTTONVIEWHEIGHT 45 //filtrate_button_view_height
- (void)updateAllViewSite
{
    CGFloat y = self.categoryHolderView.frame.origin.x + self.categoryHolderView.frame.size.height + SPABE_BETWEEN_HOLDERVIEW;

    if ([self.bannerList count] > 0) {
        self.bannerHolderView.hidden = NO;
        [self.bannerHolderView updateOriginY:y];
        y = y + self.bannerHolderView.frame.size.height + SPABE_BETWEEN_HOLDERVIEW;
    } else {
        self.bannerHolderView.hidden = YES;
    }
    
    if (self.entrance) {
        [self reloadFastOrderEntrance];
        self.fastOrderEntranceView.hidden = NO;
        [self.fastOrderEntranceView updateOriginY:y];
        y = y + self.fastOrderEntranceView.frame.size.height + SPABE_BETWEEN_HOLDERVIEW;
    } else {
        self.fastOrderEntranceView.hidden = YES;
    }
    
    [self.noListDataTipsHolderView updateOriginY:y + FILTRATEBUTTONVIEWHEIGHT];
    
    [self updateHeight:y];
}

- (void)showNoListDataTipsWithText:(NSString *)text
{
    self.noListDataTipsHolderView.hidden = NO;
    self.noListDataTipsLabel.text = text;
}

- (void)hideNoListDataTips
{
    self.noListDataTipsHolderView.hidden = YES;
}

#define LINE_COUNT_IN_ONE_PAGE      2 //每页2行

#define CATEGORY_COUNT_IN_ONE_LINE  4 //每行4个

- (void)reloadCategory
{
    //移除
    NSArray *subViewList = [self.categoryScrollView subviews];
    for (UIView *subView in subViewList) {
        if ([subView isKindOfClass:[CategoryMenuView class]]) {
            [subView removeFromSuperview];
        }
    }
    
    //添加
    int index = 0;
    for (id object in _categoryList) {
        
        CategoryMenuView *view = [CategoryMenuView createCategoryMenuView];
        view.delegate = self;
        [view updateView:object index:index];
        
        CGFloat space = ([UIScreen mainScreen].bounds.size.width - CATEGORY_COUNT_IN_ONE_LINE * view.frame.size.width) / (CATEGORY_COUNT_IN_ONE_LINE + 1);
        int page = index / (CATEGORY_COUNT_IN_ONE_LINE * LINE_COUNT_IN_ONE_PAGE);
        int line = (index / CATEGORY_COUNT_IN_ONE_LINE) - (page * LINE_COUNT_IN_ONE_PAGE);
        int site = index % CATEGORY_COUNT_IN_ONE_LINE;
        
        CGFloat x = (page * [UIScreen mainScreen].bounds.size.width) + space + (site * (space + view.frame.size.width));
        CGFloat y = line * view.frame.size.height;
        [view setFrame:CGRectMake(x, y, view.frame.size.width, view.frame.size.height)];
        [self.categoryScrollView addSubview:view];
        index ++;
    }
    
    NSUInteger categoryCount = [_categoryList count];
    NSUInteger onePageCount = CATEGORY_COUNT_IN_ONE_LINE * LINE_COUNT_IN_ONE_PAGE;

    //设置高度
    CGFloat height;
    if (categoryCount > onePageCount) {
        height = [CategoryMenuView defaultSize].height * LINE_COUNT_IN_ONE_PAGE;
    } else {
        NSUInteger line = (categoryCount / CATEGORY_COUNT_IN_ONE_LINE) + ((categoryCount % CATEGORY_COUNT_IN_ONE_LINE) > 0 ? 1 : 0);
        height = line * [CategoryMenuView defaultSize].height;
    }
    [self.categoryHolderView updateHeight:height + 10];
    [self.categoryScrollView updateHeight:height + 10];
    
    //设置内容Frame
    NSUInteger page = (categoryCount/ onePageCount) + (categoryCount % onePageCount > 0 ? 1 : 0);
    [self.categoryScrollView setContentSize:CGSizeMake(page * [UIScreen mainScreen].bounds.size.width, self.categoryScrollView.frame.size.height)];
    
    //设置页显示
    if (page <= 1) {
        self.categoryControl.hidden = YES;
    } else {
        self.categoryControl.hidden = NO;
        self.categoryControl.numberOfPages = page;
//        CGFloat x = [self pageControlXWithCount:page pageControlWidth:_categoryControl.frame.size.width];
//        [self.categoryControl updateOriginX:x];
        [self.categoryControl updateCenterX:self.center.x];
    }
}

-(void) reloadFastOrderEntrance {
    [self.buyButton setBackgroundImage:[SportImage orangeFrameButtonImage] forState:UIControlStateNormal];
    [self.buyButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateHighlighted];
    
    [self.categoryIconImageView sd_setImageWithURL:[NSURL URLWithString:self.entrance.iconUrl]];
    
    self.businessNameLabel.text = self.entrance.businessName;
    self.detailLabel.text = self.entrance.detailTimeString;
    
}

#pragma mark - CategoryMenuViewDelegate
- (void)didClickCategoryButton:(BusinessCategory *)category
{
    [MobClickUtils event:umeng_event_home_page_click_category label:category.name];
    
    if ([_delegate respondsToSelector:@selector(didClickHomeHeaderViewCategory:)]) {
        [_delegate didClickHomeHeaderViewCategory:category];
    }
}

#define TAG_BASE_AD_BUTTON 100
- (void)reloadAD
{
    //移除所有
    for (UIView *one in self.sportLazyScrollView.subviews) {
        if ([one isKindOfClass:[UIView class]]) {
            [one removeFromSuperview];
        }
    }
    
    //添加
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = ( 75.0 / 320.0 ) * width;
    CGFloat backgroundHeight = height + 2.0;

    // PREPARE LAZY VIEW
    CGRect rect = CGRectMake(0, 1, width, height);
    [self.sportLazyScrollView autoPlayPause];
    [self.sportLazyScrollView removeFromSuperview];
    self.sportLazyScrollView = [[SportLazyScrollView alloc] initWithFrame:rect numberOfPages:[self.bannerList count] delegate:self];
    
    [self.bannerHolderView insertSubview:_sportLazyScrollView belowSubview:self.bannerControl];
    [self.bannerHolderView updateHeight:backgroundHeight];
    
    self.bannerControl.numberOfPages = [_bannerList count];
//    CGFloat ax = [self pageControlXWithCount:[_bannerList count] pageControlWidth:_bannerControl.frame.size.width];
//    [self.bannerControl updateOriginX:ax];
    [self.bannerControl updateCenterX:self.center.x];
}

- (CGFloat)pageControlXWithCount:(NSInteger)count pageControlWidth:(CGFloat)pageControlWidth
{
    CGFloat leftSpace = 4;
    CGFloat width = 19 * count;
    CGFloat x = [UIScreen mainScreen].bounds.size.width - pageControlWidth / 2 - width / 2 - leftSpace;
    return x;
}

//弃用，改用sportLazyScrollView
//- (void)changeBanner
//{
//    CGPoint offset = _bannerScrollView.contentOffset;
//    int page = offset.x / _bannerScrollView.frame.size.width;
//    if (page == [_bannerList count] - 1) {
//        page = 0;
//    } else{
//        page ++;
//    }
//    CGFloat x = page * _bannerScrollView.frame.size.width;
//    [_bannerScrollView setContentOffset:CGPointMake(x, 0) animated:YES];
//}

- (void)clickAdButton:(id)sender
{
    [MobClickUtils event:umeng_event_home_page_click_banner];
    
    UIButton *button = (UIButton *)sender;
    NSInteger index = button.tag - TAG_BASE_AD_BUTTON;
    if ([_bannerList count] > index) {
        
        SportAd *ad = [_bannerList objectAtIndex:index];
        
        if ([_delegate respondsToSelector:@selector(didCLickHomeHeaderViewBanner:)]) {
            [_delegate didCLickHomeHeaderViewBanner:ad];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    
    if (scrollView == self.categoryScrollView) {
        [_categoryControl setCurrentPage:offset.x / scrollView.frame.size.width];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    
    if (scrollView == self.categoryScrollView) {
        [_categoryControl setCurrentPage:offset.x / scrollView.frame.size.width];
    }
}

//- (IBAction)clickHotBusinessButton:(id)sender {
//    
//    _hotBusinessButton.selected = YES;
//    _historyBusinessButton.selected = NO;
//    
//    [UIView animateWithDuration:0.15 animations:^{
//        [self.moveLineView updateCenterX:_hotBusinessButton.center.x];
//    }];
//    
//    if ([_delegate respondsToSelector:@selector(didClickHomeHeaderViewHotBusinessButton)]) {
//        [_delegate didClickHomeHeaderViewHotBusinessButton];
//    }
//}

//- (IBAction)clickHistoryBusinessButton:(id)sender {
//    [MobClickUtils event:umeng_event_home_click_history];
//    
//    _hotBusinessButton.selected = NO;
//    _historyBusinessButton.selected = YES;
//    
//    [UIView animateWithDuration:0.15 animations:^{
//        [self.moveLineView updateCenterX:_historyBusinessButton.center.x];
//    }];
//    
//    if ([_delegate respondsToSelector:@selector(didClickHomeHeaderViewHistoryBusinessButton)]) {
//        [_delegate didClickHomeHeaderViewHistoryBusinessButton];
//    }
//}

#pragma mark - SportLazyScrollViewDelegate
- (void)SportLazyScrollViewCurrentPageChanged:(NSInteger)currentPageIndex
{
    [_bannerControl setCurrentPage:currentPageIndex];
}

-(UIView *) SportLazyScrollViewGetSubView:(NSInteger) index
{
    if (index >= [_bannerList count]) {
        return nil;
    }
    
    SportAd *ad = [_bannerList objectAtIndex:index];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = ( 75.0 / 320.0 ) * width;
    CGFloat space = 0;
    CGFloat x = 0;
    CGFloat y = space;
    
    CGRect frame = CGRectMake(x, y, width, height);
    UIView *view = [[UIView alloc]initWithFrame:frame];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame] ;
    [imageView sd_setImageWithURL:[NSURL URLWithString:ad.imageUrl] placeholderImage:[SportImage bannerPlaceholderImage]];
    imageView.contentMode= UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    UIButton *button = [[UIButton alloc] initWithFrame:frame] ;
    [button setBackgroundImage:[[SportColor createImageWithColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.2]] stretchableImageWithLeftCapWidth:1 topCapHeight:1] forState:UIControlStateHighlighted];
    button.tag = TAG_BASE_AD_BUTTON + index;
    [button addTarget:self action:@selector(clickAdButton:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:imageView];
    [view addSubview:button];
    
    return view;
}

-(void)pauseTimer
{
    [self.sportLazyScrollView autoPlayPause];
}

-(void)resumeTimer
{
    [self.sportLazyScrollView autoPlayResume];
}

- (IBAction)clickFastOrderButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickFastOrderButton:)]) {
        [_delegate didClickFastOrderButton:self.entrance];
    }
}

@end
