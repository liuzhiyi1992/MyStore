//
//  MyActivityController.m
//  Sport
//
//  Created by haodong  on 14-3-5.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "MyActivityController.h"
#import "UserManager.h"
#import "Activity.h"
#import "UserManager.h"

@interface MyActivityController ()
@property (strong, nonatomic) Activity *activity;
@property (strong, nonatomic) NSArray *activityList;
@property (assign, nonatomic) ActivityListType selectedType;
@end

@implementation MyActivityController


- (void)viewDidUnload {
    [self setMyPublishButton:nil];
    [self setMyPublishTableView:nil];
    [self setMyPromiseTableView:nil];
    [self setMyPromiseButton:nil];
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"我的活动";
    [_myPublishButton setBackgroundImage:[SportColor createImageWithColor:[UIColor colorWithRed:147/255.0 green:164.0/255.0 blue:1189.0/255.0 alpha:1]] forState:UIControlStateNormal];
    [_myPromiseButton setBackgroundImage:[SportColor createImageWithColor:[UIColor colorWithRed:147/255.0 green:164.0/255.0 blue:1189.0/255.0 alpha:1]] forState:UIControlStateNormal];
    [_myPublishButton setBackgroundImage:[SportColor createImageWithColor:[UIColor colorWithRed:237.0/255.0 green:107.0/255.0 blue:152.0/255.0 alpha:1]] forState:UIControlStateSelected];
    [_myPromiseButton setBackgroundImage:[SportColor createImageWithColor:[UIColor colorWithRed:237.0/255.0 green:107.0/255.0 blue:152.0/255.0 alpha:1]] forState:UIControlStateSelected];
    [self clickMyPublishButton:_myPublishButton];
}

- (IBAction)clickMyPublishButton:(id)sender {
    _myPublishButton.selected = YES;
    _myPromiseButton.selected = NO;
    _selectedType = ActivityListTypeMyCreate;

}

- (IBAction)clickMyPromiseButton:(id)sender {
    _myPublishButton.selected = NO;
    _myPromiseButton.selected = YES;
    _selectedType = ActivityListTypeMyPromise;

}

- (void)queryData
{
//    [[ActivityService defaultService] queryActivityList:self
//                                                   type:_selectedType
//                                                 userId:[[[UserManager defaultManager] readCurrentUser] userId]
//                                         activityStatus:@"0" proId:<#(NSString *)#> actName:<#(NSString *)#> latitude:<#(double)#> longitude:<#(double)#> sort:<#(NSString *)#> page:<#(int)#> count:<#(int)#>];
    
//    [[ActivityService defaultService] queryActivityList:self
//                                                   type:_selectedType
//                                                 userId:[[[UserManager defaultManager] readCurrentUser] userId]
//                                         activityStatus:nil];
}

- (void)didQueryActivityList:(NSArray *)list status:(NSString *)status type:(ActivityListType)type page:(int)page
{
    if (_selectedType == ActivityListTypeMyCreate) {
        if ([status isEqualToString:STATUS_SUCCESS]) {
            if ([list count] > 0) {
                self.activity = [list objectAtIndex:0];
                _myPublishTableView.tableHeaderView.hidden = NO;
            } else {
                self.activity = nil;
                _myPublishTableView.tableHeaderView.hidden = YES;
            }
        }
        self.myPublishTableView.hidden = NO;
        self.myPromiseTableView.hidden = YES;
        [_myPublishTableView reloadData];
    }
    
    if (_selectedType == ActivityListTypeMyPromise) {
        if ([status isEqualToString:STATUS_SUCCESS]) {
            self.activityList = list;
        }
        self.myPublishTableView.hidden = YES;
        self.myPromiseTableView.hidden = NO;
        [_myPromiseTableView reloadData];
    }
    
    if (_activity == nil) {
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

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _myPublishTableView) {
        return [_activity.promiseList count];
    } else {
        return [_activityList count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_selectedType == ActivityListTypeMyCreate) {
        NSString *identifier = [ActivityPeopleCell getCellIdentifier];
        ActivityPeopleCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [ActivityPeopleCell createCell];
            cell.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        ActivityPromise *promise = [_activity.promiseList objectAtIndex:indexPath.row];
        [cell updateCellWithPromise:promise indexPath:indexPath];
        return cell;
    } else {
        NSString *identifier = [ActivityCell getCellIdentifier];
        ActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [ActivityCell createCell];
            cell.delegate = nil;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        Activity *activity = [_activityList objectAtIndex:indexPath.row];
        [cell updateCell:indexPath activity:activity];
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ActivityPeopleCell getCellHeight];
}

- (void)didClickAgreeButton:(NSIndexPath *)indexPath
{
    ActivityPromise *promise = [_activity.promiseList objectAtIndex:indexPath.row];
    ;
    [ActivityService updatePromiseStatus:self
                               promiseId:promise.promiseId
                                  userId:[[[UserManager defaultManager] readCurrentUser] userId]
                                  status:ActivityPromiseStatusAgreed];
}

- (void)didClickRejectButton:(NSIndexPath *)indexPath
{
//    ActivityPromise *promise = [_activity.promiseList objectAtIndex:indexPath.row];
//    ;
//    [[ActivityService defaultService] updatePromiseStatus:self
//                                                promiseId:promise.promiseId
//                                                   userId:[[[UserManager defaultManager] readCurrentUser] userId]
//                                                   status:ActivityPromiseStatusRejected];
}

@end
