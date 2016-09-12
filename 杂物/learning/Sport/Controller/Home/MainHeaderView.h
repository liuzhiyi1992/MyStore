//
//  MainHeaderView.h
//  Sport
//
//  Created by xiaoyang on 16/5/11.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchBusinessQuicklyView.h"
#import "SearchBusinessNoExtraConditionView.h"
#import "SearchBusinessCategoryView.h"
#import "BannerView.h"
#import "CategoryView.h"
#import "OftenGoBusinessView.h"
#import "MainControllerCategory.h"
#import "MainHomeSignInView.h"

@class SportAd;

@protocol MainHeaderViewDelegate <NSObject>
@optional
- (void)didCLickMainHeaderViewBanner:(SportAd *)banner;
//点击有额外条件的快速找场
- (void)didClickDatePickerView;
- (void)didClickHourPickerView;
- (void)didClickExtraConditionPickerView;
- (void)didClickSearchBusinessButton;
//点击没有额外条件的快速找场
- (void)clickDatePickerViewNoExtraCondition;
- (void)clickHourPickerViewNoExtraCondition;
- (void)didClickSearchBusinessNoExtraCondition;
//点击banner项目的按钮委托
- (void)clickCategaryButtonWithCategoryName:(NSString *)categoryName categoryId:(NSString *)categoryId;
//点击常去球馆的委托
- (void)clickOftenGoBusinessButtonWithBusinessId:(NSString *)businessId categoryId:(NSString *)categoryId;
//点击全部目录的委托
- (void)clickCategoryViewCategory:(BusinessCategory *)category;
//更新约束的委托
- (void)updateConstraint;
//add快捷找场时返传默认categoryid
- (void)backDefaultCategoryId:(NSString *)categoryId;
//本来项目委托已经有更新tableView的headerview的赋值状态（顺便更新frame），但是add没有额外情况view时，因为延时0.2秒了，所以另外更新一下
- (void)searchBusiessNoExtraConditionUpdateTableViewFrame;

@end

@interface MainHeaderView : UIView<UIScrollViewDelegate,BannerViewDelegate,OftenGoBusinessViewDelegate,SearchBusinessCategoryViewDelegate>
@property (strong, nonatomic) SearchBusinessQuicklyView *searchBusinessQuicklyView;
@property (strong, nonatomic) SearchBusinessNoExtraConditionView *searchBusinessNoExtraConditionView;
@property (strong, nonatomic) SearchBusinessCategoryView *searchBusinessCategoryView;
@property (strong, nonatomic) CategoryView *categoryView;
@property (weak, nonatomic) IBOutlet UIView *oftenGoBusinessHolderView;
@property (weak, nonatomic) IBOutlet MainHomeSignInView *recordHolderView;
@property (weak, nonatomic) IBOutlet UIView *bannerHolderView;
@property (strong, nonatomic) BannerView *bannerView;
@property (strong, nonatomic) OftenGoBusinessView *oftenGoBusinessView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannerViewHeightConstraint;

+ (MainHeaderView *)createMainHeaderViewWithDelegate:(id<MainHeaderViewDelegate>)delegate;

- (void)updateViewWithCategoryList:(NSArray *)categoryList
                            adList:(NSArray *)adList
                         venueList:(NSArray *)venueList
            mainControllerCategory:(MainControllerCategory *)mainControllerCategory;

- (void)updateSearchBusinessQuicklyViewWithCurrentSelectedTimeInterval:(NSInteger)currentSelectedTimeInterval
                                             currentSelectedDateString:(NSString *)currentSelectedDateString
                                             currentSelectedWeekString:(NSString *)currentSelectedWeekString
                                             currentSelectedHourString:(NSString *)currentSelectedHourString
                                               currentSelectedFilterId:(NSString *)currentSelectedFilterId
                                   currentSelectedSoccerSelectedNumber:(NSString *)currentSelectedSoccerSelectedNumber;
@end
