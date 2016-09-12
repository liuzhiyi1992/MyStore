//
//  MyPointController.m
//  Sport
//
//  Created by haodong  on 14/11/12.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "MyPointController.h"
#import "MyPointCell.h"
#import "SportProgressView.h"
#import "User.h"
#import "UserManager.h"
#import "PointGoodsDetailController.h"
#import "PointRecordController.h"
#import "LuckyDrawController.h"
#import "PointGoods.h"
#import "SportWebController.h"
#import "UIView+Utils.h"

@interface MyPointController ()
@property (strong, nonatomic) NSArray *dataList;
@property (copy, nonatomic) NSString *pointRuleUrl;
@end

@implementation MyPointController


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"积分商城";
    
    [self.dataTableView updateHeight:[UIScreen mainScreen].bounds.size.height - 20 - 44 - _dataTableView.frame.origin.y];
    self.dataTableView.separatorStyle = NO;
    
    for (UIView *firstView in self.view.subviews) {
        for (UIView *secondView in firstView.subviews) {
            for (UIView *thirView in secondView.subviews) {
                if (thirView.tag == 100 && [thirView isKindOfClass:[UIImageView class]]) {
                    [(UIImageView *)thirView setImage:[SportImage lineImage]];
                }
            }
        }
    }
    [self.lineVerticalImageView updateWidth:0.5];
    [self.topLineView updateHeight:0.5];
    
    self.dataTableView.hidden = YES;
    self.topHolderView.hidden = YES;
    [self.activityIndicatorView startAnimating];
    [self queryData];
    
    [MobClickUtils event:umeng_event_enter_my_point];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateMyPoint];
}

- (void)updateMyPoint
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    self.myPointCountLabel.text = [NSString stringWithFormat:@"%d", user.point];
}

- (void)queryData
{
    User *user = [[UserManager defaultManager] readCurrentUser];
    [SportProgressView showWithStatus:@"加载中..."];
    [PointService queryPointGoodsList:self userId:user.userId type:@"0"];
}

- (void)didQueryPointGoodsList:(NSArray *)list
                        status:(NSString *)status
                           msg:(NSString *)msg
                       myPoint:(int)myPoint
                      onceUsePoint:(int)onceUsePoint
                  pointRuleUrl:(NSString *)pointRuleUrl
                   drawRuleUrl:(NSString *)drawRuleUrl
{
    [self.activityIndicatorView stopAnimating];
    self.dataTableView.hidden = NO;
    self.topHolderView.hidden = NO;
    
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismiss];
        
        self.dataList = list;
        
        self.pointRuleUrl = pointRuleUrl;
        
        [self updateMyPoint];
        
        [self.dataTableView reloadData];
    } else {
        if (msg) {
            [SportProgressView dismissWithError:msg];
        } else {
            [SportProgressView dismissWithError:@"网络问题"];
        }
    }
    
    //无数据时的提示
    if ([list count] == 0) {
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44);
        if ([status isEqualToString:STATUS_SUCCESS]) {
            [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"没有相关数据"];
        } else {
            [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:@"网络错误"];
        }
    } else {
        [self removeNoDataView];
    }
}

- (void)didClickNoDataViewRefreshButton
{
    [self queryData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [MyPointCell getCellIdentifier];
    MyPointCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [MyPointCell createCell];
    }
    PointGoods *goods = [_dataList objectAtIndex:indexPath.row];
    
    BOOL isLast = (indexPath.row == [_dataList count]);
    
    [cell updateCellWithPointGoods:goods indexPath:indexPath isLast:isLast];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [MyPointCell getCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PointGoods *goods = [_dataList objectAtIndex:indexPath.row];
    
    if (goods.type == PointGoodsTypeDraw) {
        LuckyDrawController *controller = [[LuckyDrawController alloc] init] ;
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        PointGoodsDetailController *controller = [[PointGoodsDetailController alloc] initWithPointGoods:goods] ;
        [self.navigationController pushViewController: controller animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

- (IBAction)clickMyPointButton:(id)sender {
    PointRecordController *controller = [[PointRecordController alloc] init] ;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)clickPointHelpButton:(id)sender {
    SportWebController *controller = [[SportWebController alloc] initWithUrlString:_pointRuleUrl title:@"积分规则"];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
