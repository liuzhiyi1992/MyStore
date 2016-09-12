//
//  HomeHeaderView.h
//  Sport
//
//  Created by qiuhaodong on 15/5/22.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryMenuView.h"

#import "SportLazyScrollView.h"

@class BusinessCategory;
@class SportAd;
@class FastOrderEntrance;
@protocol HomeHeaderViewDelegate <NSObject>
@optional
- (void)didClickHomeHeaderViewHotBusinessButton;
- (void)didClickHomeHeaderViewHistoryBusinessButton;
- (void)didClickHomeHeaderViewCategory:(BusinessCategory *)category;
- (void)didCLickHomeHeaderViewBanner:(SportAd *)banner;
- (void)didClickFastOrderButton:(FastOrderEntrance *)entrance;
@end

@interface HomeHeaderView : UIView <CategoryMenuViewDelegate,UIScrollViewDelegate,SportLazyScrollViewDelegate>

+ (HomeHeaderView *)createHomeHeaderViewWithDelegate:(id<HomeHeaderViewDelegate>)delegate;

- (void)updateViewWithCategoryList:(NSArray *)categoryList
                        bannerList:(NSArray *)bannerList
                        courseList:(NSArray *)courseList
                 fastOrderEntrance:(FastOrderEntrance *)entrance;

- (void)updateFastViewWithFastOrderEntrance:(FastOrderEntrance *)entrance;

- (void)showNoListDataTipsWithText:(NSString *)text;

- (void)hideNoListDataTips;

-(void)pauseTimer;
-(void)resumeTimer;

@end
