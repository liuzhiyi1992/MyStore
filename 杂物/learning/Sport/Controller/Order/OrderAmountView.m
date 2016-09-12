//
//  OrderAmountView.m
//  Sport
//
//  Created by 江彦聪 on 15/4/14.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "OrderAmountView.h"
#import "OrderAmountCell.h"
#import "PriceUtil.h"

@interface OrderAmountView ()
@property (strong, nonatomic) NSMutableArray *dataList;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;

@end

@implementation OrderAmountView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


+ (OrderAmountView *)createOrderAmountViewWithOrder:(Order *)order
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"OrderAmountView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    OrderAmountView *view = [topLevelObjects objectAtIndex:0];
    view.frame = [UIScreen mainScreen].bounds;
    view.tableView.layer.cornerRadius = 5.0;
    view.tableView.layer.masksToBounds = YES;
    view.tableView.delegate = view;
    view.tableView.dataSource = view;
    [view updateData:order];
    return view;
}

-(void)updateData:(Order *)order
{
    self.dataList = [NSMutableArray array];
    
    // 1
    [self.dataList addObject:[NSArray arrayWithObjects:OrderAmountTypeString(OrderTotalAmount),[PriceUtil toPriceStringWithYuan:order.totalAmount], nil]];
    
    // 2
    [self.dataList addObject:[NSArray arrayWithObjects:OrderAmountTypeString(OrderPromoteAmount),[PriceUtil toPriceStringWithYuan:order.promoteAmount], nil]];
    
    // 3
    [self.dataList addObject:[NSArray arrayWithObjects:OrderAmountTypeString(OrderMoneyAmount),[PriceUtil toPriceStringWithYuan:order.money], nil]];
    
    // 4
    [self.dataList addObject:[NSArray arrayWithObjects:OrderAmountTypeString(OrderPayAmount),[PriceUtil toPriceStringWithYuan:order.amount], nil]];
    //[self.tableView reloadData];
    
    self.tableViewHeightConstraint.constant = [OrderAmountCell getCellHeight]* [_dataList count];
}

- (void)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    self.tableView.alpha = 0;
    self.tableView.transform = CGAffineTransformMakeScale(1.1, 1.1);
    
    [UIView animateWithDuration:0.2 delay:0.06 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.tableView.alpha = 1;
        self.tableView.transform = CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished) {
    }];
}

#pragma mark -UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [OrderAmountCell getCellHeight];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     NSArray *cellDataArray = [_dataList objectAtIndex:indexPath.row];
    
    NSString *identifier = [OrderAmountCell getCellIdentifier];
    OrderAmountCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [OrderAmountCell createCell];
    }
    
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        cell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
    
    [cell updateCellWithTitle:[cellDataArray objectAtIndex:0] amount:[cellDataArray objectAtIndex:1] indexPath:indexPath];
    
    return cell;
}


- (IBAction)touchDownBackground:(id)sender {
    [self removeFromSuperview];

}

@end
