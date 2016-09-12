//
//  UserCityListView.h
//  Sport
//
//  Created by haodong  on 14-5-5.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CityCell.h"
#import "BaseService.h"
#import "City.h"

@protocol UserCityListViewDelegate <NSObject>
@optional
- (void)didSelectUserCity:(City *)city;
@end

@interface UserCityListView : UIView<UITableViewDataSource, UITableViewDelegate, CityCellDelegate, BaseServiceDelegate>

@property (weak, nonatomic) IBOutlet UITableView *dataTableView;
@property (assign, nonatomic) id<UserCityListViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *navigationBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *tipsBackgroundImageView;


+ (UserCityListView *)createUserCityListView;

- (void)show;

@end
