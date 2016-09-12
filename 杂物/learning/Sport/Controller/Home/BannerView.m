//
//  BannerView.m
//  Sport
//
//  Created by xiaoyang on 16/5/13.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "BannerView.h"
#import "SportAd.h"
#import "UIImageView+WebCache.h"
#import "GoSportUrlAnalysis.h"
#import "SportWebController.h"
#import "UIView+Utils.h"
#import "BannerView.h"
#import "LayoutConstraintUtil.h"
#import "BusinessCategory.h"

@interface BannerView()<BannerViewDelegate>
@property (strong, nonatomic) SportLazyScrollView *sportLazyScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *bannerScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *bannerControl;
@property (strong, nonatomic) NSArray *bannerList;
@property (strong, nonatomic) UIView *fatherHolderView;
@property (assign, nonatomic) CGFloat categaryButtonWidth;
@property (assign, nonatomic) CGFloat bottomImageViewOriginLeftConstraint;
@property (strong, nonatomic) MainControllerCategory *mainControllerCategory;
@property (assign, nonatomic) BOOL currentCategoryIsDefaultSelect;

@end

@implementation BannerView

+ (BannerView *)createBannerViewWithDelegate:(id<BannerViewDelegate>)delegate
                            fatherHolderView:(UIView *)fatherHolderView;
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"BannerView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    BannerView *view = (BannerView *)[topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    view.bannerScrollView.scrollsToTop = NO;
    view.fatherHolderView = fatherHolderView;
    [LayoutConstraintUtil view:view addConstraintsWithSuperView:fatherHolderView];
    
    //代码拉伸图
    view.categaryBottomImageView.image = [[UIImage imageNamed:@"categorySelectImage"] stretchableImageWithLeftCapWidth:28 topCapHeight:0];
    view.categaryBackgroundImageView.image = [[UIImage imageNamed:@"bannerCategoryBackgroundImage"] stretchableImageWithLeftCapWidth:7 topCapHeight:4.5];
    
    //一开始就不让点
    view.bannerControl.enabled = NO;

    //一开始记录下原始默认的底View的左约束大小，防止后面的叠加
    view.bottomImageViewOriginLeftConstraint = view.BottomImageViewLeadingConstraint.constant;
    
    //计算有约束条件的项目按钮的宽放到创建View的最后，防止干扰，导致获取值不准
    CGFloat width =[UIScreen mainScreen].bounds.size.width - ( view.categaryHolderViewLeadingConstraint.constant + view.categaryRelateSuperViewLeftConstraint.constant) *2;
    view.categaryButtonWidth = width / 5;
    view.currentCategoryIsDefaultSelect = YES;
    return view;
}

- (void)updateViewWithBannerList:(NSArray *)bannerList
                    mainControllerCategory:(MainControllerCategory *)mainControllerCategory
{
    self.bannerList = bannerList;
    self.mainControllerCategory = mainControllerCategory;
    //目录按钮
    [self updateCategoryButton];
    [self reloadAD];
    [self defaultCategorySelect];

}

- (void)defaultCategorySelect {
    if ([_delegate respondsToSelector:@selector(defaultCategorySelect:currentCategoryIsDefaultSelect:defaultCategoryId:)]) {
        [_delegate defaultCategorySelect:self.mainControllerCategory.currentSelectedCategoryName currentCategoryIsDefaultSelect:self.currentCategoryIsDefaultSelect defaultCategoryId:self.mainControllerCategory.currentSelectedCategoryId];
    }
}

#define banner_view_height [UIScreen mainScreen].bounds.size.width * ( 184.0 / 375.0 )
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
//    CGFloat height = ( 75.0 / 320.0 ) * width;
//    CGFloat backgroundHeight = height + 2.0;
    CGFloat height = banner_view_height;
    CGFloat backgroundHeight = height;
    
    // PREPARE LAZY VIEW
    CGRect rect = CGRectMake(0, 1, width, height);
    [self.sportLazyScrollView autoPlayPause];
    [self.sportLazyScrollView removeFromSuperview];
    self.sportLazyScrollView = [[SportLazyScrollView alloc] initWithFrame:rect numberOfPages:[self.bannerList count] delegate:self];
    
    //6秒滚动一次banner
    self.sportLazyScrollView.autoPlayTime = 6;
    
    [LayoutConstraintUtil view:self.sportLazyScrollView addConstraintsWithSuperView:self];
    [self bringSubviewToFront:self.categaryHolderView];
    [self bringSubviewToFront:self.bannerControl];    
    [self updateHeight:backgroundHeight];
    
    self.bannerControl.numberOfPages = [_bannerList count];
    self.bannerControl.hidesForSinglePage = YES;
    //    CGFloat ax = [self pageControlXWithCount:[_bannerList count] pageControlWidth:_bannerControl.frame.size.width];
    //    [self.bannerControl updateOriginX:ax];
    [self.bannerControl updateCenterX:self.center.x];
}

//第一个button tag的初始值
#define CATEGORY_BUTTON_TAG_START 300

- (void)updateAllCategoryButtonEnable:(BOOL)enable {
    for (int i = 0; i < 5; i ++) {
        NSUInteger tag = CATEGORY_BUTTON_TAG_START + i;
        UIButton *button = [self.categaryHolderView viewWithTag:tag];
        [button setEnabled:enable];
    }
}

#pragma mark - clickCategaryButton
- (IBAction)clickCategaryButton:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    //不让重复点
    if (button.selected) {
        return;
    }
    //暂时默认是5个按钮
    for (int i = 0; i < 5; i ++) {
        NSUInteger tag = CATEGORY_BUTTON_TAG_START + i;
        UIButton *tempButton = [self.categaryHolderView viewWithTag:tag];
        NSUInteger index = button.tag - CATEGORY_BUTTON_TAG_START;
        
        //取选中的按钮categoryId
        NSString *clickButtonCategoryId = nil;
        if (button.tag == tag) {
            
            for (BusinessCategory *bc in _mainControllerCategory.willShowCategoryList) {
                if ([tempButton.currentTitle isEqualToString:bc.name]) {
                    clickButtonCategoryId = bc.businessCategoryId;
                }else if ([tempButton.currentTitle isEqualToString:@"全部"]) {
                    clickButtonCategoryId = @"-1";
                }
            }
            if ([_delegate respondsToSelector:@selector(didClickCategaryButton:categoryId:)]){
                [_delegate didClickCategaryButton:tempButton.currentTitle categoryId:clickButtonCategoryId];
                
            }
            //底imageView的左约束大小（原约束加相差多少个按钮的宽）
            CGFloat constant =  _bottomImageViewOriginLeftConstraint + _categaryButtonWidth * index;
            [tempButton setTitleColor:[UIColor hexColor:@"222222"] forState:UIControlStateNormal];
            //按钮偏移动画效果
            //动画开始时按钮就失效了，防止由于快速点击按钮，使得动画延误导致按钮状态残留
            [self updateAllCategoryButtonEnable:NO];
            [UIView animateWithDuration:0.1 animations:^{

                [self bottomImageViewLeadingConstraintWithConstant:constant];
                //同步约束
                [self layoutIfNeeded];
                
                
            } completion:^(BOOL finished) {
                //设置选择判断主要为了调按钮文字的颜色
                [tempButton setSelected:YES];
                [self updateAllCategoryButtonEnable:YES];

            }];
            
        } else {
               [tempButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
               [tempButton setSelected:NO];
        }
    }
}

//赋值给按钮
- (void)updateCategoryButton
{
    NSUInteger count = MIN([_mainControllerCategory.willShowCategoryList count], 4);
    [self updateCategoryButtonText:count];
}

#define MAX_COUNT_CATEGORY_BUTTON 5
- (void)updateCategoryButtonText:(NSUInteger)willShowCagtegoryNumber
{
    UIButton *tempButton = nil;
    NSUInteger tag = 0;
    for (int i = 0; i < MAX_COUNT_CATEGORY_BUTTON; i ++) {
        tag = CATEGORY_BUTTON_TAG_START + i;
        tempButton = [self.categaryHolderView viewWithTag:tag];
        if (i < willShowCagtegoryNumber) {
            BusinessCategory *businessCategory = [_mainControllerCategory.willShowCategoryList objectAtIndex:i];
            [tempButton setTitle:businessCategory.name forState:UIControlStateNormal];
            tempButton.hidden = NO;
        } else if (i == willShowCagtegoryNumber) {
            //赋个“全部”的值给它
            tempButton = [self.categaryHolderView viewWithTag:tag];
            [tempButton setTitle:@"全部" forState:UIControlStateNormal];
            tempButton.hidden = NO;
        } else {
            tempButton.hidden = YES;
        
        }
    }
}

- (void)bottomImageViewLeadingConstraintWithConstant:(CGFloat)constant{
    
    self.BottomImageViewLeadingConstraint.constant = constant;
    
}

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
//    if (index > [_bannerList count]) {
//        return nil;
//    }
//    
    SportAd *ad = [_bannerList objectAtIndex:index];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
//    CGFloat height = ( 75.0 / 320.0 ) * width;
    CGFloat height = banner_view_height;
    CGFloat space = 0;
    CGFloat x = 0;
    CGFloat y = space;
    
    CGRect frame = CGRectMake(x, y, width, height);
    UIView *view = [[UIView alloc]initWithFrame:frame];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame] ;
    // to do
//    if ([_bannerList count] ==0) {
//        imageView.image = [[UIImage imageNamed:@"bannerCategoryBackgroundImage"] stretchableImageWithLeftCapWidth:7 topCapHeight:4.5];
//    }else {
//        [imageView sd_setImageWithURL:[NSURL URLWithString:ad.imageUrl] placeholderImage:[SportImage bannerDefaultImage]];
//    }
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

- (void)clickAdButton:(id)sender
{
    [MobClickUtils event:umeng_event_home_page_click_banner];
    
    UIButton *button = (UIButton *)sender;
    NSInteger index = button.tag - TAG_BASE_AD_BUTTON;
    if ([_bannerList count] > index) {
        
        SportAd *ad = [_bannerList objectAtIndex:index];
        
        if ([_delegate respondsToSelector:@selector(didCLickBannerViewBanner:)]) {
            [_delegate didCLickBannerViewBanner:ad];
        }
    }
}

-(void)pauseTimer
{
    [self.sportLazyScrollView autoPlayPause];
}

-(void)resumeTimer
{
    [self.sportLazyScrollView autoPlayResume];
}

@end
