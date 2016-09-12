//
//  CoachBookingInfoHolderView.m
//  Sport
//
//  Created by liuzhiyi on 15/10/8.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "CoachBookingInfoHolderView.h"
#import "UIView+Utils.h"

@interface CoachBookingInfoHolderView ()

@property (strong, nonatomic) UIButton *selectedButton;
@property (strong, nonatomic) NSArray *itemList;
@end


@implementation CoachBookingInfoHolderView

+ (CoachBookingInfoHolderView *)creatCoachBookingInfoHolderViewWithProjectList:(NSArray *)projectList {
    
    CoachBookingInfoHolderView *view = [[NSBundle mainBundle] loadNibNamed:@"CoachBookingInfoHolderView" owner:self options:nil][0];
    view.coachProjectList = projectList;
    [view initStatus];
    return view;
}

- (IBAction)clickHeaderButton:(id)sender {
    
    if([sender isEqual:_leftHeaderButton]) {
        self.itemTableViewHeightConstraint.constant = [CoachItemCell getCellHeightWithCellType:CellTypeDisplay] * _coachProjectList.count;
        
        _itemTabelView.hidden = NO;
        _drawerHolderView.hidden = YES;
        _leftHeaderButton.selected = YES;
        _rightHeaderButton.selected = NO;
        
        self.slideBarleadingConstraint.constant = 0.5 * (self.leftHeaderButton.frame.size.width - self.slideBar.frame.size.width);
        [UIView animateWithDuration:0.2 animations:^{
            [_slideBar updateCenterX:_leftHeaderButton.center.x];
        }];
        
        self.selectedButton = _leftHeaderButton;
    }else {
        self.itemTableViewHeightConstraint.constant = self.drawerHeightConstraint.constant;
        
        _itemTabelView.hidden = YES;
        _drawerHolderView.hidden = NO;
        _leftHeaderButton.selected = NO;
        _rightHeaderButton.selected = YES;
        
        self.slideBarleadingConstraint.constant = 0.5 * (self.leftHeaderButton.frame.size.width - self.slideBar.frame.size.width) + self.leftHeaderButton.frame.size.width;
        [UIView animateWithDuration:0.2 animations:^{
            [_slideBar updateCenterX:_rightHeaderButton.center.x];
        }];
        
        self.selectedButton = _rightHeaderButton;
    }
}

- (void)initStatus {
    self.itemTabelView.delegate = self;
    self.itemTabelView.dataSource = self;
    self.itemTabelView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self clickHeaderButton:_leftHeaderButton];
    _itemTabelView.alwaysBounceVertical = NO;
}

#pragma mark - delegate,dateSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.coachProjectList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [CoachItemCell getCellHeightWithCellType:CellTypeDisplay];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = [CoachItemCell getCellIdentifier];
    
    CoachItemCell *cell = [_itemTabelView dequeueReusableCellWithIdentifier:identifier];
    
    if(nil == cell) {
        cell = [CoachItemCell createCellWithCellType:CellTypeDisplay];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self.superViewController;
    [cell updateCellWithItem:self.coachProjectList[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
