//
//  CoachFilterController.h
//  Sport
//
//  Created by liuzhiyi on 15/9/6.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SportController.h"

#define TITLE_GENDER_NO_LIMIT   @"不限"
#define TITLE_GENDER_MALE       @"男"
#define TITLE_GENDER_FEMALE     @"女"

#define TITLE_SORT_DISTANCE  @"离我最近"
#define TITLE_SORT_RATING    @"评价最高"
#define TITLE_SORT_POPULAR   @"人气优先"

@protocol CoachFilterControllerDelegate <NSObject>

- (void)didSelectedItem:(NSString *)item gender:(NSString *)gender;

@end

@interface CoachFilterController : SportController

@property (weak, nonatomic) IBOutlet UIView *itemHolderView;

@property (weak, nonatomic) IBOutlet UIView *sexHolderView;

@property (weak, nonatomic) IBOutlet UIButton *allSexButton;

@property (weak, nonatomic) IBOutlet UIView *categoryHolderView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *categoryHolderViewHeightConstraint;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *verticalCellLines;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightVerticalLineBottomSpaceConstraint;

@property (weak, nonatomic) id<CoachFilterControllerDelegate> delegate;

@property (assign, nonatomic) NSString *item;
@property (assign, nonatomic) NSString *gender;
@property (strong, nonatomic) NSArray *categoryList;

- (instancetype)initWithCategoryList:(NSArray *)categoryList;

- (instancetype)initWithItem:(NSString *)item gender:(NSString *)gender categoryList:(NSArray *)categoryList;

@end
