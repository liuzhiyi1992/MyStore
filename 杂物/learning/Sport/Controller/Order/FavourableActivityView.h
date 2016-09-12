//
//  FavourableActivityView.h
//  Sport
//
//  Created by haodong  on 14/11/7.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavourableActivityCell.h"
#import "OrderService.h"

@class FavourableActivity;

@protocol FavourableActivityViewDelegate <NSObject>
@optional
- (void)didSelectFavourableActivityView:(FavourableActivity *)favourableActivity inviteCode:(NSString *)inviteCode;
@end

@interface FavourableActivityView : UIView<UITableViewDataSource, UITableViewDelegate, FavourableActivityCellDelegate, OrderServiceDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentHolderView;
@property (weak, nonatomic) IBOutlet UITableView *dataTableView;

@property (assign, nonatomic) id<FavourableActivityViewDelegate> delegate;

+ (FavourableActivityView *)createViewWithActivityList:(NSArray *)activityList
                                    selectedActivityId:(NSString *)selectedActivityId;

- (void)show;

@end
