//
//  CategoryMenuView.h
//  Sport
//
//  Created by haodong  on 13-6-12.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@class BusinessCategory;

@protocol  CategoryMenuViewDelegate <NSObject>

@optional
- (void)didClickCategoryButton:(BusinessCategory *)category;

@end

@interface CategoryMenuView : UIView

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalCountLable;
@property (weak, nonatomic) IBOutlet UIImageView *normalImageView;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;
@property (weak, nonatomic) IBOutlet UIImageView *clubImageView;

@property (assign, nonatomic) id<CategoryMenuViewDelegate> delegate;

+ (CategoryMenuView *)createCategoryMenuView;

+ (CGSize)defaultSize;

- (void)updateView:(BusinessCategory *)oneCategory index:(int)index;

@end
