//
//  OrderConfirmPriceDetailView.m
//  Sport
//
//  Created by 江彦聪 on 8/16/16.
//  Copyright © 2016 haodong . All rights reserved.
//

#import "OrderConfirmPriceDetailView.h"
#import "BusinessPriceDetailCell.h"
@interface OrderConfirmPriceDetailView()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) NSArray *priceDetailArray;
@property (weak, nonatomic) IBOutlet UITableView *priceDetailTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeight;
@property (weak, nonatomic) IBOutlet UIControl *backgroundView;

@end
@implementation OrderConfirmPriceDetailView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (OrderConfirmPriceDetailView *)createOrderConfirmPriceDetailView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"OrderConfirmPriceDetailView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    
    OrderConfirmPriceDetailView *view = [topLevelObjects objectAtIndex:0];
    
    UINib *cellNib = [UINib nibWithNibName:[BusinessPriceDetailCell getCellIdentifier] bundle:nil];
    [view.priceDetailTableView registerNib:cellNib forCellReuseIdentifier:[BusinessPriceDetailCell getCellIdentifier]];
    view.priceDetailTableView.delegate = view;
    view.priceDetailTableView.dataSource = view;
    return view;
}

- (IBAction)touchBackground:(id)sender {
    [self removeFromSuperview];
}

-(void) updateDataList:(NSArray *)dataList bottomViewHeight:(CGFloat) bottomHeight{
    self.priceDetailArray = dataList;
    [self.priceDetailTableView reloadData];
    
    CGFloat maxHeight = [UIScreen mainScreen].bounds.size.height - bottomHeight - 64;
    CGFloat tableViewHeight = [self.priceDetailArray count] * [BusinessPriceDetailCell getCellHeight] < maxHeight?[self.priceDetailArray count] * [BusinessPriceDetailCell getCellHeight]:maxHeight;
    
    self.tableViewHeight.constant =  tableViewHeight;
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.priceDetailArray count];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [BusinessPriceDetailCell getCellIdentifier];
    BusinessPriceDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    [cell updateWithNameContendArray:self.priceDetailArray[indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [BusinessPriceDetailCell getCellHeight];
}


@end
