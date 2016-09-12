//
//  CategoryButtonListView.h
//  Sport
//
//  Created by qiuhaodong on 15/6/15.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CategoryButtonListViewDelegate <NSObject>
- (void)didClickCategoryButtonListView:(NSString *)categoryId;
@end

@interface CategoryButtonListView : UIView

+ (CategoryButtonListView *)createViewWithCategoryList:(NSArray *)categoryList
                                    selectedCategoryId:(NSString *)selectedCategoryId
                                              delegate:(id<CategoryButtonListViewDelegate>)delegate;

@end
