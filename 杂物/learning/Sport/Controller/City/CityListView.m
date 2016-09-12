//
//  CityListView.m
//  Sport
//
//  Created by haodong  on 14-4-25.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "CityListView.h"
#import "City.h"
#import "CityManager.h"
#import "Region.h"
#import "SportProgressView.h"
#import "UIView+Utils.h"
#import "AppGlobalDataManager.h"
#import "NoDataView.h"

@interface CityListView()<NoDataViewDelegate>
@property (strong, nonatomic) City *suggestCity;
@property (strong, nonatomic) NSArray *dataList;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet UIView *tipsView;
@property (strong, nonatomic) NoDataView *noDataView;
@end

@implementation CityListView


#define TAG_CITY_LIST_VIEW 2014100601
+ (CityListView *)createCityListView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CityListView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    CityListView *view = [topLevelObjects objectAtIndex:0];
    view.tag = TAG_CITY_LIST_VIEW;
    view.frame = [UIScreen mainScreen].bounds;
    [view.dataTableView updateHeight:view.frame.size.height - 64];
    view.navigationBackgroundImageView.image = [SportImage navigationBarImage];
    view.backgroundColor = [SportColor defaultPageBackgroundColor];
    return view;
}

- (void)show
{
    self.tipsView.hidden = YES;
    if ([[UIApplication sharedApplication].keyWindow viewWithTag:TAG_CITY_LIST_VIEW]) {
        return;
    }
    
    [[AppGlobalDataManager defaultManager] setIsShowingCityListView:YES];
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self updateOriginY:[UIScreen mainScreen].bounds.size.height];
    [UIView animateWithDuration:0.3 animations:^{
        [self updateOriginY:0];
    }];
    
    self.suggestCity = [CityManager defaultManager].suggestCity;
    
    if ([[[CityManager defaultManager] cityList] count] > 0) {
        self.dataList = [[CityManager defaultManager] cityList];
        [self.dataTableView reloadData];
    } else {
        [SportProgressView showWithStatus:DDTF(@"kLoading")];
    }
    [[BaseService defaultService] queryCityList:self];
}

- (IBAction)clickBackButton:(id)sender {
    
    if ([CityManager readRealCurrentCityId] == nil) {
        
        City *city = nil;
        if (_suggestCity) {
            city = _suggestCity;
        } else {
            city = [CityManager readCurrentCity];
        }
        
        [CityManager saveCurrentCity:city];
    }
    
    [[AppGlobalDataManager defaultManager] setIsShowingCityListView:NO];
    
    [self removeFromSuperview];
}

- (void)didQueryCityList:(NSArray *)cityList status:(NSString *)status
{
    [SportProgressView dismiss];
    if ([status isEqualToString:STATUS_SUCCESS]) {
        self.dataList = cityList;
        [self.dataTableView reloadData];
    }
    
    self.tipsView.hidden = YES;
    
    //无数据时的提示
    if ([cityList count] == 0) {
        if ([status isEqualToString:STATUS_SUCCESS]) {
            self.tipsLabel.text = @"抱歉，没有相关信息...";
        } else {
            self.tipsLabel.text = @"网络错误";
        }
        [self.noDataView removeFromSuperview];
        self.noDataView = [NoDataView createNoDataViewWithFrame:self.tipsView.frame
                                                           type:NoDataTypeNetworkError
                                                           tips:self.tipsLabel.text];
        self.noDataView.delegate = self;
        [self addSubview:self.noDataView];
    } else {
        [self.noDataView removeFromSuperview];
    }
}

- (void)didClickNoDataViewRefreshButton{
    [SportProgressView showWithStatus:@"正在加载..."];
    [[BaseService defaultService] queryCityList:self];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_suggestCity) {
        return 2;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_suggestCity) {
        return 30;
    } else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_suggestCity) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)] ;
        label.backgroundColor = [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1];
        label.textColor = [SportColor content2Color];
        label.font = [UIFont systemFontOfSize:12];
        
        if (section == 0) {
            label.text = @"   定位城市";
        } else {
            label.text = @"   所有城市";
        }
        
        return label;
    } else {
        return [[UIView alloc] initWithFrame:CGRectZero] ;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_suggestCity) {
        if (section == 0) {
            return 1;
        } else {
            return [_dataList count];
        }
    } else {
        return [_dataList count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [CityCell getCellIdentifier];
    CityCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [CityCell createCell];
        cell.delegate = self;
    }
    
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        cell.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
    
    City *city = nil;
    BOOL selected = NO;
    BOOL isLast = NO;
    
    if (_suggestCity && indexPath.section == 0) {
        city = _suggestCity;
        isLast = YES;
    } else {
        city = [_dataList objectAtIndex:indexPath.row];
        isLast = (indexPath.row == [_dataList count] - 1);
    }
    
    if ([[CityManager readRealCurrentCityId] isEqualToString:city.cityId]) {
        selected = YES;
    }
    
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
    City *city = nil;
    
    if (_suggestCity && indexPath.section == 0) {
        city = _suggestCity;
    } else {
        city = [_dataList objectAtIndex:indexPath.row];
    }
    
    [CityManager saveCurrentCity:city];
    
    [self.dataTableView reloadData];
    [self clickBackButton:nil];
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

@end
