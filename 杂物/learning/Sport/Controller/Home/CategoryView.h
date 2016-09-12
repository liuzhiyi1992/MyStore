//
//  CategoryView.h
//  Sport
//
//  Created by xiaoyang on 16/5/13.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryMenuView.h"


@class BusinessCategory;

@protocol CategoryViewDelegate <NSObject>
@optional

- (void)didClickCategoryViewCategory:(BusinessCategory *)category;

@end

@interface CategoryView : UIView<CategoryMenuViewDelegate,UIScrollViewDelegate>

+ (CategoryView *)createCategoryViewWithDelegate:(id<CategoryViewDelegate>)delegate
                                fatherHolderView:(UIView *)fatherHolderView;
- (void)updateViewWithCategoryList:(NSArray *)categoryList;

@end
