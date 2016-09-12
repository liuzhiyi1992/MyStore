//
//  TodayOrderCell.m
//  Sport
//
//  Created by qiuhaodong on 15/9/13.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "TodayOrderCell.h"
#import "OrderInformationCell.h"
#import "TodayOrderInfo.h"
#import "UIView+Utils.h"

@interface TodayOrderCell() <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *orderTableView;
@property (strong, nonatomic) NSArray *todayOrderList;

@end

#define MAX_COUNT   5  //显示的订单最多条数
#define Y_TABLEVIEW 35

@implementation TodayOrderCell

+ (NSString *)getCellIdentifier
{
    return @"TodayOrderCell";
}

+ (CGFloat)heightWithOrderCount:(NSUInteger)orderCount {
    NSUInteger onceShowCount = MIN(orderCount, MAX_COUNT);
    return Y_TABLEVIEW + (onceShowCount * [OrderInformationCell height]);
}


+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"TodayOrderCell";
    TodayOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [TodayOrderCell createCell];
    }
    
    return cell;
}

- (void)updateCellWithTodayOrderList:(NSArray *)todayOrderList {
    
    self.todayOrderList = todayOrderList;
    
    CGFloat height = [TodayOrderCell heightWithOrderCount:[todayOrderList count]];

    [self updateHeight:height];
    
    [self.orderTableView reloadData];
    
    //若订单数超过MAX_COUNT,都不能滚动
//    if ([todayOrderList count] > MAX_COUNT) {
//        self.orderTableView.scrollEnabled = YES;
//    } else {
//        self.orderTableView.scrollEnabled = NO;
//    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.todayOrderList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderInformationCell *cell=[OrderInformationCell cellWithTableView:tableView];
    cell.todayOrder = self.todayOrderList[indexPath.row];
     return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    return [OrderInformationCell height];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(didClickTodayOrderCell:)]) {
        TodayOrderInfo *order = [self.todayOrderList objectAtIndex:indexPath.row];
        [self.delegate didClickTodayOrderCell:order];
    }
}

@end
