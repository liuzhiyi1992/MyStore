//
//  SportDropDownMenuView.h
//  test
//
//  Created by 冯俊霖 on 15/9/23.
//  Copyright © 2015年 冯俊霖. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropDownDataManager.h"

@class SportDropDownMenuView;

#pragma mark - Delegate
@protocol SportDropDownMenuViewDelegate <NSObject>

- (void)didSelectedSportDropDownMenuViewWithCategoryId:(NSString *)categoryId
                                              regionId:(NSString *)regionId
                                              filterId:(NSString *)filterId
                                                sortId:(NSString *)sortId;

@end

@interface SportDropDownMenuView : UIView<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *leftTableView;
@property (nonatomic, strong) UITableView *rightTableView;
@property (nonatomic, strong) UIView *transformView;

@property (nonatomic, weak) id <SportDropDownMenuViewDelegate> delegate;

- (instancetype)initWithOrigin:(CGPoint)origin
                        height:(CGFloat)height
                    categoryId:(NSString *)categoryId
                      regionId:(NSString *)regionId
                      filterId:(NSString *)filterId
                        sortId:(NSString *)sortId;

- (void)menuTapped;

@end
