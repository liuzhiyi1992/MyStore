//
//  CategoryButtonListView.m
//  Sport
//
//  Created by qiuhaodong on 15/6/15.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CategoryButtonListView.h"
#import "BusinessCategory.h"
#import "UIView+Utils.h"
#import "UIView+SportBackground.h"

@interface CategoryButtonListView()

@property (assign, nonatomic) id<CategoryButtonListViewDelegate> delegate;
@property (strong, nonatomic) NSArray *categoryList;
@property (copy, nonatomic) NSString *selectedCategoryId;

@property (weak, nonatomic) IBOutlet UIScrollView *categoryScrollView;
@property (weak, nonatomic) IBOutlet UIView *selectedLineView;

@end

@implementation CategoryButtonListView

+ (CategoryButtonListView *)createViewWithCategoryList:(NSArray *)categoryList
                                    selectedCategoryId:(NSString *)selectedCategoryId
                                              delegate:(id<CategoryButtonListViewDelegate>)delegate
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CategoryButtonListView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    CategoryButtonListView *view = [topLevelObjects objectAtIndex:0];
    [view updateWidth:[UIScreen mainScreen].bounds.size.width];
    [view sportUpdateAllBackground];
    view.categoryList = categoryList;
    view.selectedCategoryId = selectedCategoryId;
    view.delegate = delegate;
    [view.selectedLineView setBackgroundColor:[SportColor defaultColor]];
    [view initCategoryScrollView];
    return view;
}

- (void)initCategoryScrollView
{
    for (id one in self.categoryScrollView.subviews) {
        if ([one isKindOfClass:[UIButton class]]) {
            [(UIButton *)one removeFromSuperview];
        }
    }
    self.selectedLineView.hidden = NO;
    CGFloat x = 0, y = 0, width = 85, height = 40;
    int index = 0;
    for (BusinessCategory *category in self.categoryList) {
        if (index == 0) {
            x = 15;
        }else{
            x = index * width;
        }
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, y, width, height)] ;
        [button setTitle:category.name forState:UIControlStateNormal];
        [button setTitleColor:[SportColor content2Color] forState:UIControlStateNormal];
        [button setTitleColor:[SportColor defaultColor] forState:UIControlStateSelected];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        button.tag = index;
        [button addTarget:self action:@selector(clickCategoryButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.categoryScrollView addSubview:button];
        
        if ([_selectedCategoryId isEqualToString:category.businessCategoryId]) {
            [button setSelected:YES];
            [self.selectedLineView updateCenterX:button.center.x];
        }
        index ++;
    }
    [self.categoryScrollView setContentSize:CGSizeMake(index * width, _categoryScrollView.frame.size.height)];
}

- (void)clickCategoryButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    BusinessCategory *selectedCategory = [self.categoryList objectAtIndex:button.tag];
    if ([selectedCategory.businessCategoryId isEqualToString:_selectedCategoryId]) {
        return;
    }
    self.selectedCategoryId = selectedCategory.businessCategoryId;
    
    if ([_delegate respondsToSelector:@selector(didClickCategoryButtonListView:)]) {
        [_delegate didClickCategoryButtonListView:_selectedCategoryId];
    }
    
    for (id one in self.categoryScrollView.subviews) {
        if ([one isKindOfClass:[UIButton class]]){
            UIButton *oneButton = (UIButton *)one;
            if (oneButton.tag == button.tag) {
                [oneButton setSelected:YES];
                [UIView animateWithDuration:0.2 animations:^{
                    [self.selectedLineView updateCenterX:button.center.x];
                }];
            } else {
                [oneButton setSelected:NO];
            }
        }
    }
}

@end
