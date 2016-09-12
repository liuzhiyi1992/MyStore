//
//  EidtFavoriteSportsController.m
//  Sport
//
//  Created by haodong  on 13-11-10.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "EidtFavoriteSportsController.h"
#import "UserManager.h"
#import "BusinessCategoryManager.h"
#import "BusinessCategory.h"

@interface EidtFavoriteSportsController ()
@property (strong, nonatomic) NSArray *categoryList;
@property (strong, nonatomic) NSMutableArray *selectedIdList;
@property (assign, nonatomic) BOOL isChange;
@end

@implementation EidtFavoriteSportsController


#define WIDTH_BUTTON 68.0
#define HEIGHT_BUTTON 40.0

#define OFFSET_BUTTON_TAG 100

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = DDTF(@"kFavoriteSports");
    self.view.backgroundColor = [SportColor defaultPageBackgroundColor];
    
    self.categoryList = [[BusinessCategoryManager defaultManager] currentAllCategories];
    self.selectedIdList = [NSMutableArray arrayWithArray:[[UserManager defaultManager] readCurrentUser].favoriteSportIdList];
    
//    int index = 0;
//    int countOneLine = 4;
//    CGFloat space = (self.view.frame.size.width - countOneLine * WIDTH_BUTTON)/ (countOneLine + 1);
//    CGFloat x = space, y = space;
//    for (BusinessCategory *category in _categoryList) {
//        x = space + (space + WIDTH_BUTTON) * (index % countOneLine);
//        y = space  + (space + HEIGHT_BUTTON) * (index / countOneLine);
//        CGPoint origin = CGPointMake(x, y);
//        UIButton *button = [self createButton:origin
//                                        title:[category sportName]
//                                   isSelected:[self isSelectedSport:category.businessCategoryId]];
//        button.tag = OFFSET_BUTTON_TAG + index;
//        [self.view addSubview:button];
//        index ++;
//    }
}

- (BOOL)isSelectedSport:(NSString *)sportId
{
    for (NSString *one in _selectedIdList) {
        if ([one isEqualToString:sportId]) {
            return YES;
        }
    }
    return NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_isChange) {

    }
}

- (UIButton *)createButton:(CGPoint)origin
                     title:(NSString *)title
                isSelected:(BOOL)isSelected
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(origin.x, origin.y, WIDTH_BUTTON, HEIGHT_BUTTON)] ;
    [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:title forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
    
    [button setBackgroundImage:[SportImage favoriteSportButtonImage] forState:UIControlStateNormal];
    [button setBackgroundImage:[SportImage favoriteSportButtonSelectedImage] forState:UIControlStateSelected];
    
    if (isSelected) {
        button.selected = YES;
    }
    
    return button;
}

- (void)clickButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    BusinessCategory *category = [_categoryList objectAtIndex:button.tag - OFFSET_BUTTON_TAG];
    self.isChange = YES;
    if (button.selected) {
        [_selectedIdList addObject:category.businessCategoryId];
    } else {
        [_selectedIdList removeObject:category.businessCategoryId];
    }
}

@end
