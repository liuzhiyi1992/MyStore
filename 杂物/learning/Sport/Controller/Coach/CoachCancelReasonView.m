//
//  CoachCancelReasonView.m
//  Sport
//
//  Created by 江彦聪 on 15/4/14.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CoachCancelReasonView.h"
#import "CoachCancelReasonCell.h"
#import "PriceUtil.h"
#import "SportProgressView.h"
#import "CoachCancelReason.h"
#import "NoDataView.h"
#import "SportPopupView.h"
#import "UserManager.h"

@interface CoachCancelReasonView ()<NoDataViewDelegate,CoachCancelReasonCellDelegate>
@property (strong, nonatomic) NSMutableArray *dataList;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) CoachCancelReason *selectedReason;
@property (strong, nonatomic) NoDataView *noDataView;

@end

@implementation CoachCancelReasonView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


+ (CoachCancelReasonView *)createCoachCancelReasonView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CoachCancelReasonView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    CoachCancelReasonView *view = [topLevelObjects objectAtIndex:0];
    view.frame = [UIScreen mainScreen].bounds;
    view.tableView.layer.cornerRadius = 5.0;
    view.tableView.layer.masksToBounds = YES;
    view.tableView.delegate = view;
    view.tableView.dataSource = view;
    view.dataList = [NSMutableArray array];
    
    [view queryData];
    return view;
}

-(void)queryData
{
    [SportProgressView showWithStatus:@"加载中"];
    [CoachService getCoachCancelReason:self userId:[[UserManager defaultManager] readCurrentUser].userId];
}

-(void)didGetCoachCancelReason:(NSArray *)causeList status:(NSString *)status msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismiss];
        self.dataList = [NSMutableArray arrayWithArray:causeList];
    } else {
        [SportProgressView dismissWithError:msg];
    }
    
    //无数据时的提示
    if ([causeList count] == 0) {
        CGRect frame = self.tableView.frame;
        if ([status isEqualToString:STATUS_SUCCESS]) {
            [self showNoDataViewWithType:NoDataTypeDefault frame:frame tips:@"没有数据"];
        } else {
            [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:@"网络错误"];
        }
    } else {
        [_noDataView removeFromSuperview];
    }
    
    [self.tableView reloadData];
    self.tableViewHeightConstraint.constant = [CoachCancelReasonCell getCellHeight]* [_dataList count] + self.headerView.frame.size.height + self.footerView.frame.size.height;
}


- (void)showNoDataViewWithType:(NoDataType)type
                         frame:(CGRect)frame
                          tips:(NSString *)tips
{
    [_noDataView removeFromSuperview];
    self.noDataView = [NoDataView createNoDataViewWithFrame:frame
                                                       type:type
                                                       tips:tips];
    [self addSubview:_noDataView];
}

#pragma mark --NoDataViewDelegate
-(void)didClickNoDataViewRefreshButton
{
    [self queryData];
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
    return [CoachCancelReasonCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *identifier = [CoachCancelReasonCell getCellIdentifier];
    CoachCancelReasonCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [CoachCancelReasonCell createCell];
    }
    
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        cell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
    
    CoachCancelReason *reason = [self.dataList objectAtIndex:indexPath.row];
    BOOL isSelected = NO;
    if (self.selectedReason) {
        isSelected = [self.selectedReason.reasonId isEqualToString:reason.reasonId];
    }
    
    [cell updateCellWithTitle:reason.reasonDesc isSelected:isSelected indexPath:indexPath];
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];

}

-(void)didClickButton:(NSIndexPath *)indexPath
{
    CoachCancelReason *reason = [self.dataList objectAtIndex:indexPath.row];
    self.selectedReason = reason;
    
    [self.tableView reloadData];
}

- (IBAction)clickCancelCancelOrderButton:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)clickDoneCancelOrderButton:(id)sender {
    if (self.selectedReason == nil) {
        [SportPopupView popupWithMessage:@"请选择至少一个取消原因"];
        return;
    }
    
    if ([_delegate respondsToSelector:@selector(didClickConfirmCancelButtonWithReasonId:)]) {
        [_delegate didClickConfirmCancelButtonWithReasonId:self.selectedReason.reasonId];
    } else {
        [self removeFromSuperview];
    }
}

- (IBAction)touchDownBackground:(id)sender {
    [self removeFromSuperview];

}

@end
