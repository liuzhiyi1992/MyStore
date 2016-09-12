//
//  FacilityView.m
//  Sport
//
//  Created by qiuhaodong on 15/6/8.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "FacilityView.h"
#import "FacilityCell.h"
#import "BusinessPhotoBrowser.h"
#import "Facility.h"
#import "UIView+Utils.h"

@interface FacilityView() <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSArray *facilityList;
@property (copy, nonatomic) NSString *businessId;
@property (copy, nonatomic) NSString *categoryId;
@property (assign, nonatomic) UIViewController *controller;
@property (assign, nonatomic) NSUInteger imageTotalCount;
@property (weak, nonatomic) IBOutlet UITableView *dataTableView;
@end

@implementation FacilityView

+ (FacilityView *)createViewWithFacilityList:(NSArray *)facilityList
                                  businessId:(NSString *)businessId
                                  categoryId:(NSString *)categoryId
                                  controller:(UIViewController *)controller
                             imageTotalCount:(NSUInteger)imageTotalCount
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"FacilityView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    FacilityView *view = [topLevelObjects objectAtIndex:0];
    [view updateWidth:[UIScreen mainScreen].bounds.size.width];
    view.facilityList = facilityList;
    view.businessId = businessId;
    view.categoryId = categoryId;
    view.controller = controller;
    view.imageTotalCount = imageTotalCount;
    
    //更改高度
    CGFloat height = [facilityList count] * [FacilityCell getCellHeight];
    [view.dataTableView updateHeight:height];
    [view.dataTableView reloadData];
    [view updateHeight:height];
    
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_facilityList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [FacilityCell getCellIdentifier];
    FacilityCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [FacilityCell createCell];
    }
    
    Facility *facility = [self.facilityList objectAtIndex:indexPath.row];
    BOOL isLast = (indexPath.row == [self.facilityList count] - 1);
    [cell updateCellWithFacility:facility indexPath:indexPath isLast:isLast];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [FacilityCell getCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *className = NSStringFromClass(self.controller.class);
    if ([className isEqualToString:@"BusinessDetailController"]) {
        [MobClickUtils event:umeng_event_business_detail_click_image_info];
    }
    
    NSUInteger facilityIndex = 0;       //在设施中的第几张
    NSUInteger facilityTotalCount = 0;  //设施总图片张数
    int i;
    for (i = 0; i < [_facilityList count]; i++) {
        Facility *facility = [self.facilityList objectAtIndex:i];
        if (i < indexPath.row) {
            facilityIndex += facility.imageCount;
        }
        facilityTotalCount += facility.imageCount;
    }
    NSUInteger mainImageCount = self.imageTotalCount - facilityTotalCount;  //计算主图张数
    NSUInteger openIndex = mainImageCount + facilityIndex;                  //计算打开第几张
    
    BusinessPhotoBrowser *browser = [[BusinessPhotoBrowser alloc] initWithOpenIndex:openIndex
                                                                         businessId:self.businessId
                                                                         categoryId:self.categoryId
                                                                         totalCount:self.imageTotalCount
                                                                           business:nil];
    
    UINavigationController *modelNavigationController = [[UINavigationController alloc] initWithRootViewController:browser];
    modelNavigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self.controller presentViewController:modelNavigationController animated:YES completion:nil];
    
}

@end
