//
//  MainHeaderView.m
//  Sport
//
//  Created by xiaoyang on 16/5/11.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "MainHeaderView.h"
#import "UIView+Utils.h"
#import "SportAd.h"
#import "UIImageView+WebCache.h"
#import "NSDictionary+JsonValidValue.h"
#import "BusinessPickerData.h"
#import "PickerViewDataList.h"
#import "SignIn.h"
#import "MainController.h"
#import "MainHomeSignInView.h"
#import "BusinessCategory.h"

@interface MainHeaderView()<SearchBusinessQuicklyViewDelegate,SearchBusinessNoExtraConditionViewDelegate,CategoryViewDelegate>
@property (assign, nonatomic) id<MainHeaderViewDelegate> delegate;
@property (strong, nonatomic) NSArray *bannerList;
@property (strong, nonatomic) SportLazyScrollView *sportLazyScrollView;
@property (weak, nonatomic) IBOutlet UIView *searchBusinessQuicklyHolderView;
@property (strong, nonatomic) UIView * superHolderView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchViewConstraint;
@property (strong, nonatomic) MainControllerCategory *mainControllerCategory;
@property (strong, nonatomic) NSString *selectCategoryName;
@property (strong, nonatomic) SignIn *signIn;
@property (copy, nonatomic) NSString *defaultCategoryId;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oftenGoBusinessHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oftenGoBusinessAndSearchBusinessDistanceConstraint;

@property (assign, nonatomic) BOOL IsALLCategory;
@property (strong, nonatomic) NSArray *categoryList;
@property (strong, nonatomic) NSArray *venueList;
@property (assign, nonatomic) BOOL allCategoryIsFirstData;
@property (assign, nonatomic) CGFloat oftenGoBusinessHolderViewHeight;

//快捷找场
@property (assign, nonatomic) NSInteger currentSelectedTimeInterval;
@property (copy, nonatomic) NSString *currentSelectedDateString;
@property (copy, nonatomic) NSString *currentSelectedWeekString;
@property (copy, nonatomic) NSString *currentSelectedHourString;
@property (copy, nonatomic) NSString *currentSelectedEndHourString;
@property (copy, nonatomic) NSString *currentSelectedFilterId;
@property (copy, nonatomic) NSString *currentSelectedSoccerSelectedNumber;
@property (assign, nonatomic) double searchBusinessAddSubViewHeight;
@end

@implementation MainHeaderView

+ (MainHeaderView *)createMainHeaderViewWithDelegate:(id<MainHeaderViewDelegate>)delegate
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MainHeaderView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    MainHeaderView *view = (MainHeaderView *)[topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    if ([delegate isKindOfClass:[MainController class]]) {
        view.recordHolderView.signIn = ((MainController *)delegate).signIn;
    }
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    [view updateWidth:screenWidth];
    //holderView add 子View的时候，记得把holderView的纵向的约束优先级调低，为得就是子view能够撑大holderview
    //bannerView
    view.bannerView = [BannerView createBannerViewWithDelegate:view fatherHolderView:view.bannerHolderView ];
    //常去球馆
    view.oftenGoBusinessView = [OftenGoBusinessView createOftenGoBusinessViewWithDelegate:view fatherHolderView:view.oftenGoBusinessHolderView ];
    [view.bannerHolderView updateHeight:[UIScreen mainScreen].bounds.size.width * (184.0 / 375.0) ];
    view.IsALLCategory = NO;
    view.categoryList = nil;
    view.allCategoryIsFirstData = YES;
    //常去球馆的默认高度
    view.oftenGoBusinessHolderViewHeight = 175;
    return view;
}

- (void)updateAllViewSite
{
    CGFloat y = self.recordHolderView.frame.origin.x + self.recordHolderView.frame.size.height;
    
        [self.bannerHolderView updateOriginY:y];
        y = y + self.bannerHolderView.frame.size.height;

        [self.searchBusinessQuicklyHolderView updateOriginY:y];
    
        double h = [self updateSearchBusinessQuicklyHolderViewHeight:self.searchBusinessQuicklyHolderView.frame.size.height];
    
        y = y + h;

    if ([_venueList count] == 0){
        self.oftenGoBusinessHolderView.hidden = YES;
        
    }else {
        self.oftenGoBusinessHolderView.hidden = NO;
        [self.oftenGoBusinessHolderView updateOriginY:y + 15];
        [self.oftenGoBusinessHolderView updateHeight:_oftenGoBusinessHolderViewHeight];
        y = y + self.oftenGoBusinessHolderView.frame.size.height + 15;
    }

    [self updateHeight:y];
}
- (double)updateSearchBusinessQuicklyHolderViewHeight:(double)height{
    
    [self.searchBusinessQuicklyHolderView updateHeight:height];
    return self.searchBusinessQuicklyHolderView.frame.size.height;
}

- (void)updateViewWithCategoryList:(NSArray *)categoryList
                            adList:(NSArray *)adList
                         venueList:(NSArray *)venueList
            mainControllerCategory:(MainControllerCategory *)mainControllerCategory{
    
    self.venueList = venueList;
    self.categoryList = categoryList;
    //更新bannerView 数据
    [self.bannerView updateViewWithBannerList:adList mainControllerCategory:mainControllerCategory];
    //更新SearchBusinessCategoryView 数据
    if (self.searchBusinessCategoryView != nil) {
        [self.searchBusinessCategoryView updateViewWithCategoryList:categoryList];
    }
    //更新推荐场馆 数据
    [self.oftenGoBusinessView updateOftenGoBusinessViewWithVenueList:venueList];
    [self updateAllViewSite];
    
}

- (void)updateSearchBusinessQuicklyViewWithCurrentSelectedTimeInterval:(NSInteger)currentSelectedTimeInterval
                                             currentSelectedDateString:(NSString *)currentSelectedDateString
                                             currentSelectedWeekString:(NSString *)currentSelectedWeekString
                                             currentSelectedHourString:(NSString *)currentSelectedHourString
                                               currentSelectedFilterId:(NSString *)currentSelectedFilterId
                                   currentSelectedSoccerSelectedNumber:(NSString *)currentSelectedSoccerSelectedNumber{
    self.currentSelectedDateString = currentSelectedDateString;
    self.currentSelectedWeekString = currentSelectedWeekString;
    
    self.currentSelectedHourString = currentSelectedHourString;
    
    self.currentSelectedEndHourString = [NSString stringWithFormat:@"%ld",[currentSelectedHourString integerValue] + currentSelectedTimeInterval];
    self.currentSelectedTimeInterval = currentSelectedTimeInterval;
    
    self.currentSelectedSoccerSelectedNumber = currentSelectedSoccerSelectedNumber;
    self.currentSelectedFilterId = currentSelectedFilterId;
    
    //数据更新快捷找场
    [self searchBusinessQuicklyViewGetData];
}

- (void)searchBusinessQuicklyViewGetData {
    
    self.searchBusinessQuicklyView.dateLabel.text = _currentSelectedDateString;
    self.searchBusinessQuicklyView.weekendLabel.text = _currentSelectedWeekString;
    self.searchBusinessNoExtraConditionView.dateLabel.text = _currentSelectedDateString;
    self.searchBusinessNoExtraConditionView.weekLabel.text = _currentSelectedWeekString;
    
    self.searchBusinessQuicklyView.hourLabelOne.text = [NSString stringWithFormat:@"%@:00",_currentSelectedHourString];
    self.searchBusinessQuicklyView.hourLabelThree.text = [NSString stringWithFormat:@"%@:00",_currentSelectedEndHourString];
    self.searchBusinessQuicklyView.hourLabelFour.text = [NSString stringWithFormat:@"%ld小时",(long)_currentSelectedTimeInterval];
    self.searchBusinessNoExtraConditionView.hourLabelOne.text = [NSString stringWithFormat:@"%@:00",_currentSelectedHourString];
    self.searchBusinessNoExtraConditionView.hourLabelThree.text = [NSString stringWithFormat:@"%@:00",_currentSelectedEndHourString];
    self.searchBusinessNoExtraConditionView.hourLabelFour.text = [NSString stringWithFormat:@"%ld小时",(long)_currentSelectedTimeInterval];
    
    //默认额外选项，除了足球是没有场地人数的
    if ( [self.selectCategoryName isEqualToString:@"足球"] == NO) {
        //为什么用text等于nil，而不用self.currentSelectedSoccerSelectedNumber等于nil；因label里面多了“人场 /",要一并除去
        self.searchBusinessQuicklyView.playerNumberLabel.text = nil;
        
    }else {
        if ([_currentSelectedSoccerSelectedNumber isEqualToString:@""]) {
            
            self.searchBusinessQuicklyView.playerNumberLabel.text = [NSString stringWithFormat:@"场地人数 /"];
            
        }else {
            self.searchBusinessQuicklyView.playerNumberLabel.text = [NSString stringWithFormat:@"%@人场 /",_currentSelectedSoccerSelectedNumber];
        }
    }

    if ([_currentSelectedFilterId isEqualToString:@""]) {
        
        self.searchBusinessQuicklyView.outOrIndoorLabel.text = [NSString stringWithFormat:@"室内/室外"];
        
    }else {
        if ([_currentSelectedFilterId isEqualToString:@"3"]) {
            self.searchBusinessQuicklyView.outOrIndoorLabel.text = @"室内";
        }else if ([_currentSelectedFilterId isEqualToString:@"4"]) {
            self.searchBusinessQuicklyView.outOrIndoorLabel.text = @"室外";
        }
    }
}

//add没有额外情况的快速找场
- (void)addSearchBusinessNoExtraConditionViewWithCategoryName:(NSString *)categoryName
{
    //清除子view，方便add新子view
    for (UIView *subview in self.searchBusinessQuicklyHolderView.subviews){
        [subview removeFromSuperview];
    }
    self.searchBusinessNoExtraConditionView = [SearchBusinessNoExtraConditionView createSearchBusinessQuicklyViewWithDelegate:self fatherHolderView:self.searchBusinessQuicklyHolderView];
    //更新快捷找场数据
    [self searchBusinessQuicklyViewGetData];
}

//add有额外情况的快速找场View
- (void)addSearchBusinessQuicklyViewWithCategoryName:(NSString *)categoryName{
    
    //清除子view，方便add新子view
    for (UIView *subview in self.searchBusinessQuicklyHolderView.subviews){
        [subview removeFromSuperview];
    }
    self.searchBusinessQuicklyView = [SearchBusinessQuicklyView createSearchBusinessQuicklyViewWithDelegate:self fatherHolderView:self.searchBusinessQuicklyHolderView];
    //更新快捷找场数据
    [self searchBusinessQuicklyViewGetData];
    

    [self updateSearchBusinessQuicklyHolderViewHeight:self.searchBusinessQuicklyView.frame.size.height];
    [self updateAllViewSite];


}

//add全部的目录情况
- (void)addSearchBusinessAllCategary:(NSString *)categoryName{

    //清除子view，方便add新子view
    for (UIView *subview in self.searchBusinessQuicklyHolderView.subviews){
        [subview removeFromSuperview];
    }
    self.searchBusinessCategoryView = [SearchBusinessCategoryView createSearchBusinessCategoryViewWithDelegate:self fatherHolderView:self.searchBusinessQuicklyHolderView];
    if (self.allCategoryIsFirstData){
        [self.searchBusinessCategoryView.activityIndicator startAnimating];
    }
    [self performSelector:@selector(searchBusinessCategoryUpdateViewWithCategoryList) withObject:nil afterDelay:0.1f];
}
- (void)searchBusinessCategoryUpdateViewWithCategoryList {
    [self.searchBusinessCategoryView updateViewWithCategoryList:_categoryList];
    [self.searchBusinessCategoryView.activityIndicator stopAnimating];
}
- (void)allCategoryViewChangeMainHeaderViewSite {
    [self updateSearchBusinessQuicklyHolderViewHeight:self.searchBusinessCategoryView.frame.size.height];
    [self updateAllViewSite];
}

#pragma mark - categoryDelegate
- (void)didClickCategoryViewCategory:(BusinessCategory *)category{
    if ([_delegate respondsToSelector:@selector(clickCategoryViewCategory:)]) {
        [_delegate clickCategoryViewCategory:category];
    }
}

#pragma mark - OftenGoBusinessDelegate
- (void)didClickOftenGoBusinessButtonWithBusinessId:(NSString *)businessId categoryId:(NSString *)categoryId{
    if ([_delegate respondsToSelector:@selector(clickOftenGoBusinessButtonWithBusinessId:categoryId:)]) {
        [_delegate clickOftenGoBusinessButtonWithBusinessId:businessId categoryId:categoryId];
    }
}

- (void)updateSecondOftenGoBusinessHeight:(CGFloat)height{
    
    self.oftenGoBusinessHolderViewHeight = height;
}

#pragma mark - BannerViewDelegate
- (void) didCLickBannerViewBanner:(SportAd *)banner{
    if ([_delegate respondsToSelector:@selector(didCLickMainHeaderViewBanner:)]){
        [_delegate didCLickMainHeaderViewBanner:banner];
    }
}
//同步约束
- (void)updateTableViewHeightConstraint:(CGFloat)newHeight{

    if (self.IsALLCategory) {
        [self updateSearchBusinessQuicklyHolderViewHeight:newHeight];
        [self updateAllViewSite];
    }
}
//banner项目默认选择委托
- (void)defaultCategorySelect:(NSString *)categoryName currentCategoryIsDefaultSelect:(BOOL)currentCategoryIsDefaultSelect defaultCategoryId:(NSString *)defaultCategoryId{
    self.defaultCategoryId = defaultCategoryId;
    //更新快捷找场时，根据第一个按钮的category，add上相应的View
    if (categoryName != nil) {
        //        BusinessCategory *bc = [[BusinessCategory alloc] init];
        [self judgeCategoryNoAnimationWithCategoryName:categoryName];
    } else {
        [self judgeCategoryNoAnimationWithCategoryName:@"全部"];
    }
}

//banner项目按钮的委托
- (void)didClickCategaryButton:(NSString *)categoryName categoryId:(NSString *)categoryId{
    
    //取name值主要为了默认不是足球的时候，不显示场地人数
    self.selectCategoryName = categoryName;
    
    if ([categoryName isEqualToString:@"足球"] || [categoryName isEqualToString:@"篮球"] || [categoryName isEqualToString:@"网球"]) {
        
        self.IsALLCategory = NO;

        [UIView animateWithDuration:0.2 animations:^{
            [self addSearchBusinessQuicklyViewWithCategoryName:categoryName];
            
        }];
        [self searchBusinessViewAnimation];
        
    } else if ([categoryName isEqualToString:@"全部"] || [categoryName isEqualToString:@""]) {
        
        self.IsALLCategory = YES;
        self.allCategoryIsFirstData = YES;
        
        [self addSearchBusinessAllCategary:categoryName];
        [UIView animateWithDuration:0.2 animations:^{
        
            [self allCategoryViewChangeMainHeaderViewSite];
        }];
        [self searchBusinessViewAnimation];
    }else {
        self.IsALLCategory = NO;

        [UIView animateWithDuration:0.2 animations:^{
            [self addSearchBusinessNoExtraConditionViewWithCategoryName:categoryName];

        }];
        [self searchBusinessViewAnimation];
        [self performSelector:@selector(searchBusinessViewChangeMainHeaderViewSite) withObject:nil afterDelay:0.2f];
    }
    if ([_delegate respondsToSelector:@selector(clickCategaryButtonWithCategoryName:categoryId:)]){
        
        [_delegate clickCategaryButtonWithCategoryName:categoryName categoryId:categoryId];
    }
}

- (void)searchBusinessViewChangeMainHeaderViewSite{
    [self updateSearchBusinessQuicklyHolderViewHeight:self.searchBusinessNoExtraConditionView.frame.size.height];
    [self updateAllViewSite];
    if ([_delegate respondsToSelector:@selector(searchBusiessNoExtraConditionUpdateTableViewFrame)]){
        
        [_delegate searchBusiessNoExtraConditionUpdateTableViewFrame];
    }
}

- (void)judgeCategoryNoAnimationWithCategoryName:(NSString *)categoryName {
    if ([categoryName isEqualToString:@"足球"] || [categoryName isEqualToString:@"篮球"] || [categoryName isEqualToString:@"网球"]) {
        
        self.IsALLCategory = NO;
        
        [self addSearchBusinessQuicklyViewWithCategoryName:categoryName];
        
    } else if ([categoryName isEqualToString:@"全部"] || [categoryName isEqualToString:@""]) {
        self.IsALLCategory = YES;
        self.allCategoryIsFirstData = NO;
    
        [self addSearchBusinessAllCategary:categoryName];
        [self allCategoryViewChangeMainHeaderViewSite];
        
    }else {
        self.IsALLCategory = NO;
        
        [self addSearchBusinessNoExtraConditionViewWithCategoryName:categoryName];
        [self searchBusinessViewChangeMainHeaderViewSite];
        
    }
    if ([_delegate respondsToSelector:@selector(backDefaultCategoryId:)]){
        [_delegate backDefaultCategoryId:self.defaultCategoryId];
    }
}

//找场动画
- (void)searchBusinessViewAnimation{
    CATransition *animation = [CATransition animation];
    animation.type = @"push";
    animation.subtype = kCATransitionFromRight;
    animation.duration = 0.2;
    [self.searchBusinessQuicklyHolderView.layer addAnimation:animation forKey:nil];
}

#pragma mark - SearchBusinessQuicklyViewDelegate
- (void)showDatePickView{
    if ([_delegate respondsToSelector:@selector(didClickDatePickerView)]){
        [_delegate didClickDatePickerView];
    }
}

- (void)showHourPickView{
    if ([_delegate respondsToSelector:@selector(didClickHourPickerView)]){
        [_delegate didClickHourPickerView];
    }
    
}

- (void)showExtraConditionPickView{
    if ([_delegate respondsToSelector:@selector(didClickExtraConditionPickerView)]){
        [_delegate didClickExtraConditionPickerView];
    }
}

- (void)clickSearchBusinessButton{
    if ([_delegate respondsToSelector:@selector(didClickSearchBusinessButton)]) {
        [_delegate didClickSearchBusinessButton];
    }
}

#pragma mark - SearchBusinessNoExtraConditionViewDelegate

- (void)didClickDatePickerViewNoExtraCondition {
    if ([_delegate respondsToSelector:@selector(clickDatePickerViewNoExtraCondition)]) {
        [_delegate clickDatePickerViewNoExtraCondition];
    }
}

- (void)didClickHourPickerViewNoExtraCondition {
    if ([_delegate respondsToSelector:@selector(clickHourPickerViewNoExtraCondition)]) {
        [_delegate clickHourPickerViewNoExtraCondition];
    }
}

- (void)clickSearchBusinessNoExtraCondition{
    if ([_delegate respondsToSelector:@selector(didClickSearchBusinessNoExtraCondition)]) {
        [_delegate didClickSearchBusinessNoExtraCondition];
    }
    
}

@end
