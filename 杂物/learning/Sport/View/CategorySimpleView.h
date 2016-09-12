//
//  CategorySimpleView.h
//  Sport
//
//  Created by haodong  on 13-6-26.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@class BusinessCategory;
@class CategorySimpleView;

@protocol CategorySimpleViewDelegate <NSObject>

@optional
- (void)didClickCategoryButton:(int)index;

@end


@interface CategorySimpleView : UIView
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *smallImageView;
@property (assign, nonatomic) id<CategorySimpleViewDelegate> delegate;

+ (CategorySimpleView *)createCategorySimpleView;

+ (CGSize)defaultSize;

- (void)updateText:(BusinessCategory *)oneCategory index:(int)index;
- (void)updateSelected:(BOOL)isSelected;

@end
