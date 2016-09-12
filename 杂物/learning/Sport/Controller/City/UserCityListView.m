//
//  UserCityListView.m
//  Sport
//
//  Created by haodong  on 14-5-5.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "UserCityListView.h"
#import "CityManager.h"
#import "Region.h"
#import "SportProgressView.h"
#import "UIView+Utils.h"
#import "UserManager.h"
#import "Province.h"
#import "NoDataView.h"

@interface UserCityListView()<NoDataViewDelegate>
@property (strong, nonatomic) NSArray *dataList;

@property (strong, nonatomic) NoDataView *noDataView;
@end

@implementation UserCityListView


+ (UserCityListView *)createUserCityListView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"UserCityListView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    UserCityListView *view = [topLevelObjects objectAtIndex:0];
    view.frame = [UIScreen mainScreen].bounds;
    [view.dataTableView updateHeight:view.frame.size.height - 64];
    view.navigationBackgroundImageView.image = [SportImage navigationBarImage];
    return view;
}

- (void)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self updateOriginY:[UIScreen mainScreen].bounds.size.height];
    [UIView animateWithDuration:0.3 animations:^{
        [self updateOriginY:0];
    }];
    
    if ([[[CityManager defaultManager] provinceList] count] > 0) {
        self.dataList = [[CityManager defaultManager] provinceList];
        [self.dataTableView reloadData];
    } else {
        [SportProgressView showWithStatus:DDTF(@"kLoading")];
        
        [[BaseService defaultService] queryUserProvinceList:self];
    }
}

- (IBAction)clickBackButton:(id)sender {
    [self removeFromSuperview];
}

- (void)didQueryUserProvinceList:(NSArray *)provinceList status:(NSString *)status
{
    [SportProgressView dismiss];
    if ([status isEqualToString:STATUS_SUCCESS]) {
        self.dataList = provinceList;
        [self.dataTableView reloadData];
    }
    
    //无数据时的提示
    if ([provinceList count] == 0) {

        [self.noDataView removeFromSuperview];
        if ([status isEqualToString:STATUS_SUCCESS]) {
            self.noDataView = [NoDataView createNoDataViewWithFrame:self.tipsBackgroundImageView.frame
                                                           type:NoDataTypeDefault
                                                           tips:@"没有相关数据"];
        } else {
            self.noDataView = [NoDataView createNoDataViewWithFrame:self.tipsBackgroundImageView.frame
                                                               type:NoDataTypeNetworkError
                                                               tips:@"网络错误"];
        }
        
        self.noDataView.delegate = self;
        [self addSubview:self.noDataView];
    } else {
        [self.noDataView removeFromSuperview];
    }
}

- (void)didClickNoDataViewRefreshButton {
        [[BaseService defaultService] queryUserProvinceList:self];

}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([_dataList count] == 0) {
        return 1;
    }
    return [_dataList count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([_dataList count] == 0) {
        return nil;
    }
    Province *province = [_dataList objectAtIndex:section];
    return province.provinceName;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_dataList count] == 0) {
        return 0;
    }
    Province *province = [_dataList objectAtIndex:section];
    return [province.cityList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [CityCell getCellIdentifier];
    CityCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [CityCell createCell];
        cell.delegate = self;
    }
    
    Province *province = [_dataList objectAtIndex:indexPath.section];
    City *city = [province.cityList objectAtIndex:indexPath.row];
    BOOL selected = NO;
    if ([[[UserManager defaultManager] readCurrentUser].cityId isEqualToString:city.cityId]) {
        selected = YES;
    }
    BOOL isLast = (indexPath.row == [province.cityList count] - 1 ? YES : NO);
    
//    HDLog(@"name:%@,row:%d", city.cityName, indexPath.row);
//    
//    if ([city.cityName isEqualToString:@"玉树"]) {
//        HDLog(@"name:%@,row:%d", city.cityName, indexPath.row);
//    }
    
    [cell updateCell:city.cityName
           indexPath:indexPath
          isSelected:selected
              isLast:isLast];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [CityCell getCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Province *province = [_dataList objectAtIndex:indexPath.section];
    City *city = [province.cityList objectAtIndex:indexPath.row];
    
    if ([_delegate respondsToSelector:@selector(didSelectUserCity:)]) {
        [_delegate didSelectUserCity:city];
    }
    
    [self.dataTableView reloadData];
    [self clickBackButton:nil];
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

@end
