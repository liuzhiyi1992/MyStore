//
//  CategoryView.m
//  Sport
//
//  Created by xiaoyang on 16/5/13.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "CategoryView.h"
#import "UIView+Utils.h"
#import "BusinessCategory.h"
#import "LayoutConstraintUtil.h"

@interface CategoryView()
@property (strong, nonatomic) NSArray *categoryList;
@property (weak, nonatomic) IBOutlet UIScrollView *categoryScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *categoryControl;
@property (assign, nonatomic) id<CategoryViewDelegate> delegate;

@end

@implementation CategoryView

+ (CategoryView *)createCategoryViewWithDelegate:(id<CategoryViewDelegate>)delegate
                                fatherHolderView:(UIView *)fatherHolderView{
    
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CategoryView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    CategoryView *view = (CategoryView *)[topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    view.categoryScrollView.scrollsToTop = NO;
    [LayoutConstraintUtil view:view addConstraintsWithSuperView:fatherHolderView];
    return view;
}

- (void)updateViewWithCategoryList:(NSArray *)categoryList{
    
    self.categoryList = categoryList;
    [self reloadCategory];
}

#define LINE_COUNT_IN_ONE_PAGE      2 //line_count_in_one_page 每页2行

#define CATEGORY_COUNT_IN_ONE_LINE  4 //category_count_in_one_line 每行4个

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
    [self updateHeight:height + 10];
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
        [self.categoryControl updateCenterX:self.center.x];
    }
}

#pragma mark - CategoryMenuViewDelegate
- (void)didClickCategoryButton:(BusinessCategory *)category
{
    [MobClickUtils event:umeng_event_home_page_click_category label:category.name];
    
    if ([_delegate respondsToSelector:@selector(didClickCategoryViewCategory:)]) {
        [_delegate didClickCategoryViewCategory:category];
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

@end
