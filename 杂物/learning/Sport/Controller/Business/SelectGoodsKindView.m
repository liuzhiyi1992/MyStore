//
//  SelectGoodsKindView.m
//  Sport
//
//  Created by haodong  on 14-8-16.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "SelectGoodsKindView.h"
#import "UIView+Utils.h"
#import "SelectGoodsCell.h"
#import "Goods.h"
#import <QuartzCore/QuartzCore.h>

@interface SelectGoodsKindView()
@property (strong, nonatomic) NSArray *dataList;
@property (assign, nonatomic) NSInteger selectedRow;
@end

@implementation SelectGoodsKindView


+ (SelectGoodsKindView *)createSelectGoodsKindView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SelectGoodsKindView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    SelectGoodsKindView *view = [topLevelObjects objectAtIndex:0];

    view.tableHolderView.layer.cornerRadius = 3;
    view.tableHolderView.layer.masksToBounds = YES;
    
//    view.dataTableView.layer.cornerRadius = 8;
//    view.dataTableView.layer.masksToBounds = YES;
    
    return view;
}

- (void)showInView:(UIView *)view dataList:(NSArray *)dataList selectedRow:(NSInteger)selectedRow
{
    self.dataList = dataList;
    self.selectedRow = selectedRow;
    
    [view addSubview:self];
    
    [self.dataTableView reloadData];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [SelectGoodsCell getCellIdentifier];
    SelectGoodsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [SelectGoodsCell createCell];
    }
    
    Goods *goods = [_dataList objectAtIndex:indexPath.row];
    
    BOOL isSelected = (_selectedRow == indexPath.row);

    [cell updateCellWithValue:[NSString stringWithFormat:@"%@  %d元/张", goods.name, (int)goods.price] isSelected:isSelected];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [SelectGoodsCell getCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Goods *goods = [_dataList objectAtIndex:indexPath.row];
    if ([_delegate respondsToSelector:@selector(didSelectedGoods:row:)]) {
        [_delegate didSelectedGoods:goods row:indexPath.row];
    }
    
    [self hide];
}

- (IBAction)touchDownBackground:(id)sender {
    [self hide];
}

- (void)hide
{
    [self removeFromSuperview];
}

@end
