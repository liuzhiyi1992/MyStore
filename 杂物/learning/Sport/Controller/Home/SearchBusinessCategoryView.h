//
//  SearchBusinessCategoryView.h
//  Sport
//
//  Created by qiuhaodong_macmini on 16/6/11.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryMenuView.h"
#import "MainControllerCategory.h"

@class BusinessCategory;

@protocol SearchBusinessCategoryViewDelegate <NSObject>
@optional
- (void)didClickCategoryViewCategory:(BusinessCategory *)category;
- (void)updateTableViewHeightConstraint:(CGFloat)newHeight;

@end

@interface SearchBusinessCategoryView : UIView<CategoryMenuViewDelegate,UIScrollViewDelegate>
@property (strong, nonatomic) NSArray *categoryList;
@property (weak, nonatomic) IBOutlet UIScrollView *categoryScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *categoryControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *categoryScrollViewHeightConstraint;

@property (assign, nonatomic) id<SearchBusinessCategoryViewDelegate>delegate;
+ (SearchBusinessCategoryView *)createSearchBusinessCategoryViewWithDelegate:(id<SearchBusinessCategoryViewDelegate>)delegate
                                                            fatherHolderView:(UIView *)fatherHolderView;

- (void)updateViewWithCategoryList:(NSArray *)categoryList;

@end
