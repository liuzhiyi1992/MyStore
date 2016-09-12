//
//  TodayOrderCell.h
//  Sport
//
//  Created by qiuhaodong on 15/9/13.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@class TodayOrderInfo;

@protocol TodayOrderCellDelegate <NSObject>

@optional
- (void)didClickTodayOrderCell:(TodayOrderInfo *)todayOrderInfo;

@end

@interface TodayOrderCell : DDTableViewCell

@property (weak, nonatomic) id<TodayOrderCellDelegate> delegate;

+ (CGFloat)heightWithOrderCount:(NSUInteger)orderCoun;

- (void)updateCellWithTodayOrderList:(NSArray *)todayOrderList;
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
