//
//  ServiceView.m
//  Sport
//
//  Created by qiuhaodong on 15/6/8.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "ServiceView.h"
#import "ServiceCell.h"
#import "Facility.h"
#import "SportWebController.h"
#import "UIView+Utils.h"
#import "ServiceGroup.h"
#import "Business.h"
#import "ServiceSectionHeaderView.h"
#import "BusinessMapController.h"

@interface ServiceView() <UITableViewDataSource, UITableViewDelegate, ServiceCellDelegate>

@property (weak, nonatomic) IBOutlet UIView *bottomHolderView;
@property (strong, nonatomic) NSArray *serviceList;
@property (strong, nonatomic) UIViewController *controller;
@property (weak, nonatomic) IBOutlet UITableView *dataTableView;
//@property (strong,nonatomic) NSString *title;
@property (strong,nonatomic) NSArray *serviceListTitle;
@property (assign, nonatomic) id<ServiceViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@end

@implementation ServiceView

+ (ServiceView *)createViewWithServiceList:(NSArray *)serviceList
                                controller:(UIViewController *)controller
                                  delegate:(id<ServiceViewDelegate>)delegate
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ServiceView" owner:self options:nil];
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    ServiceView *view = [topLevelObjects objectAtIndex:0];
    [view updateWidth:[UIScreen mainScreen].bounds.size.width];
    view.serviceList = serviceList;
    view.controller = controller;
    view.delegate = delegate;
    
    [view.backgroundImageView setImage:[SportImage whiteBackgroundImage]];

    [view.dataTableView reloadData];
    
    [view close];
    
    return view;
}

#define CLOSE_SHOW_COUNT 2 //默认显示两个组
- (void)close
{
    if ([self.serviceList count] <= CLOSE_SHOW_COUNT) {
        [self open];
    } else {
        
        CGFloat height = [self heightWithCount:CLOSE_SHOW_COUNT];
        
        [self.dataTableView updateHeight:height];
        [self.bottomHolderView updateOriginY:height];
        [self updateHeight:height + self.bottomHolderView.frame.size.height];
        
        self.bottomHolderView.hidden = NO;
    }
}

- (void)open
{
    CGFloat height = [self heightWithCount:[self.serviceList count]];
    [self.dataTableView updateHeight:height];
    [self updateHeight:height];
    
    self.bottomHolderView.hidden = YES;
}


- (CGFloat)heightWithCount:(NSUInteger)count
{
    CGFloat height = 0;
    
    for (int i = 0; i < count ; i ++) {
        ServiceGroup *group = [self.serviceList objectAtIndex:i];
        height += [ServiceSectionHeaderView height]+[self sectionFooterViewHeight];
        
        for (Service *service in group.serviceList) {
            height += [ServiceCell getCellHeightWithService:service];
        }
    }
    return height;
}

- (IBAction)clickBottomButton:(id)sender {
    [MobClickUtils event:umeng_event_click_business_detial_more_info];
    [self open];
    if ([self.delegate respondsToSelector:@selector(didChangeServiceViewHeight:)]) {
        [self.delegate didChangeServiceViewHeight:self.frame.size.height];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.serviceList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    ServiceGroup *serviceGroup = [self.serviceList objectAtIndex:section];
    return [serviceGroup.serviceList count];
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{

    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];

    return  view;
}

-(CGFloat)sectionFooterViewHeight{
    return 14;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return [self sectionFooterViewHeight];
}


- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    ServiceSectionHeaderView *view = [ServiceSectionHeaderView createServiceSectionHeaderView];
  
    ServiceGroup *serviceGroup =[self.serviceList objectAtIndex:section];
    
     view.sectionHeaderViewLabel.text =serviceGroup.title;
    //    return [[self createImage:@"other_cell_background_1"] stretchableImageWithLeftCapWidth:160 topCapHeight:2];
    UIImage *image =nil;
     UIScreen *screen = [UIScreen mainScreen];
    if(section != 0){
        //image =[[UIImage imageNamed:@"cell_line@2x.png"] stretchableImageWithLeftCapWidth:150 topCapHeight:2];
        image =[UIImage imageNamed:@"cell_line"];
        UIImageView *bg2 = [[UIImageView alloc] initWithImage:image];
        bg2.frame=CGRectMake(15, 0, screen.bounds.size.width, 1);
        [view addSubview:bg2];
    }

    return view;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return [ServiceSectionHeaderView height];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [ServiceCell getCellIdentifier];
    ServiceCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [ServiceCell createCell];
        cell.delegate = self;
    }
    
    ServiceGroup *serviceGroup = [self.serviceList objectAtIndex:indexPath.section];
    Service *service = [serviceGroup.serviceList objectAtIndex:indexPath.row];
    
    BOOL isLast = (indexPath.row == [serviceGroup.serviceList count] - 1);
    
    [cell updateCellWithService:service indexPath:indexPath isLast:isLast canClick:NO];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ServiceGroup *serviceGroup = [self.serviceList objectAtIndex:indexPath.section];
    Service *service = [serviceGroup.serviceList objectAtIndex:indexPath.row];
    return [ServiceCell getCellHeightWithService:service];
}

- (void)didClickServiceCellDetailButton:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(didClickServiceViewCell:)]) {
        [self.delegate didClickServiceViewCell:indexPath];
    }
}

@end
