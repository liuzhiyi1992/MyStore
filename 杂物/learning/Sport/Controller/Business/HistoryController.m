//
//  HistoryController.m
//  Sport
//
//  Created by haodong  on 13-8-20.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "HistoryController.h"
#import "SportProgressView.h"
#import "HistoryManager.h"
#import "BusinessListCell.h"
#import "BusinessDetailController.h"
#import "Business.h"

@interface HistoryController ()
@property (strong, nonatomic) NSMutableArray *dataList;
@end

@implementation HistoryController

- (void)viewDidUnload {
    [self setDataTableView:nil];
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = DDTF(@"kHistory");
    self.noDataTipsLabel = [self createNoDataTipsLabel];
    self.noDataTipsLabel.text = @"没有最近浏览的场馆";
    [self.dataTableView addSubview:self.noDataTipsLabel];
    self.noDataTipsLabel.hidden = YES;
    
    
    
    [self createRightTopButton:@"清空"];
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.dataList = [NSMutableArray arrayWithArray:[[HistoryManager defaultManager] findAllBusinesses]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadTableViewData];
        });
    });



}

- (void)reloadTableViewData
{
    if ([_dataList count] == 0) {
        self.noDataTipsLabel.hidden = NO;
    } else {
        self.noDataTipsLabel.hidden = YES;
    }
    [self.dataTableView reloadData];
}

- (void)clickRightTopButton:(id)sender
{
    if ([_dataList count] > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"确定清空所有历史?"
                                                           delegate:self
                                                  cancelButtonTitle:DDTF(@"kCancel")
                                                  otherButtonTitles:DDTF(@"kOK"), nil];
        [alertView show];
       // [alertView release];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    } else {
        [[HistoryManager defaultManager] deleteAllBusinesses];
        self.dataList = nil;
        [self reloadTableViewData];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [BusinessListCell getCellIdentifier];
    
    BusinessListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [BusinessListCell createCell];
    }
    
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        cell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
    
    BOOL isLast = (indexPath.row == [_dataList count] - 1);
    Business *business = [_dataList objectAtIndex:indexPath.row];
    [cell updateCell:business indexPath:indexPath isLast:isLast];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [BusinessListCell getCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Business *business = [_dataList objectAtIndex:indexPath.row];
    NSString *defaultCategoryId = business.defaultCategoryId;
    BusinessDetailController *controller = [[BusinessDetailController alloc] initWithBusiness:business categoryId:defaultCategoryId] ;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
