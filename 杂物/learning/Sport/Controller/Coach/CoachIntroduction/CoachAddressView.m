//
//  CoachAddressView.m
//  Sport
//
//  Created by qiuhaodong on 15/7/22.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CoachAddressView.h"
#import "Coach.h"
#import "CoachDetailCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "UIView+Utils.h"
#import "BusinessCategory.h"
#import "CoachServiceArea.h"

@interface CoachAddressView() <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) Coach *coach;
@property (strong, nonatomic) NSArray *dataList;
@property (weak, nonatomic) IBOutlet UITableView *dataTableView;

@end

@implementation CoachAddressView


#define TITLE_EXPERIENCE    @"运动经历"
#define TITLE_CATEGORY      @"擅长项目"
#define TITLE_PRICE         @"陪练价格"
#define TITLE_SERVICE_AREA  @"可指定区域"
#define TITLE_OFTEN_AREA    @"常去场地"

+ (CoachAddressView *)createViewWithCoach:(Coach *)coach
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CoachAddressView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    CoachAddressView *view = [topLevelObjects objectAtIndex:0];
    view.coach = coach;
    [view updateWidth:[UIScreen mainScreen].bounds.size.width];
    
    view.dataTableView.fd_debugLogEnabled = NO;
    UINib *cellNib = [UINib nibWithNibName:[CoachDetailCell getCellIdentifier] bundle:nil];
    [view.dataTableView registerNib:cellNib forCellReuseIdentifier:[CoachDetailCell getCellIdentifier]];
    
    [view.dataTableView reloadData];
    
    [view updateHeight:[view height]];
    
    return view;
}

- (CGFloat)height
{
    CGFloat height = 0;
    for (NSUInteger row = 0 ; row < [self.dataList count]; row ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        height += [self.dataTableView fd_heightForCellWithIdentifier:[CoachDetailCell getCellIdentifier] configuration:^(CoachDetailCell *cell) {
            [self configureCell:cell atIndexPath:indexPath];
        }];
    }
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.coach.oftenArea isEqualToString:@""]) {
        self.dataList = @[TITLE_EXPERIENCE, TITLE_CATEGORY, TITLE_PRICE, TITLE_SERVICE_AREA];
    }else {
        self.dataList = @[TITLE_EXPERIENCE, TITLE_CATEGORY, TITLE_PRICE, TITLE_SERVICE_AREA, TITLE_OFTEN_AREA];
    }
    return [_dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [CoachDetailCell getCellIdentifier];
    CoachDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(CoachDetailCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    BOOL isLast = (indexPath.row == [self.dataList count] - 1);
    cell.fd_enforceFrameLayout = NO;
    NSString *title = [self.dataList objectAtIndex:indexPath.row];
    NSString *content = @"";
    UIColor *color = nil;
    if ([title isEqualToString:TITLE_EXPERIENCE]) {
        content = self.coach.introduction;
    }else if ([title isEqualToString:TITLE_CATEGORY]) {
        content = [self categoryString];
    }else if ([title isEqualToString:TITLE_PRICE]) {
        //content = [NSString stringWithFormat:@"￥%.f/小时",self.coach.price];
        content = self.coach.price;
        color = [SportColor defaultOrangeColor];
    }else if ([title isEqualToString:TITLE_SERVICE_AREA]) {
        content = [self serviceString];
    }else if ([title isEqualToString:TITLE_OFTEN_AREA]) {
        content = [self.coach.oftenArea stringByReplacingOccurrencesOfString:@"," withString:@"\n"];
        
    }
    
    [cell updateCellWithTitle:title content:content indexPath:indexPath isLast:isLast contentColor:color];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier:[CoachDetailCell getCellIdentifier] configuration:^(CoachDetailCell *cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)categoryString
{
    NSMutableString *string = [NSMutableString stringWithString:@""];
    for (BusinessCategory *category in self.coach.categoryList) {
        [string appendFormat:@"%@ ", category.name];
    }
    return string;
}

- (NSString *)serviceString
{
    NSMutableString *string = [NSMutableString stringWithString:@""];
    for (CoachServiceArea *area in self.coach.serviceAreaList) {
        [string appendFormat:@"%@ ", area.regionName];
    }
    return string;
}

@end
