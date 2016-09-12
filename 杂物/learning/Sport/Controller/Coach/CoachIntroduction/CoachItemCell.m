//
//  CoachItemCell.m
//  Sport
//
//  Created by liuzhiyi on 15/9/30.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "CoachItemCell.h"
#import "UIImage+normalized.h"
#import "CoachOrderController.h"


#define CELL_HEIGHT_DISPLAY 100
#define CELL_HEIGHT_BOOKING 80

#define ROLE_ID_PEILIAN     @"2"
#define ROLE_ID_JIAOLIAN    @"1"

@implementation CoachItemCell

+ (NSString *)getCellIdentifier {
    return @"CoachItemCell";
}

+ (id)createCellWithCellType:(CellType)cellType {
//    UIImage *image = [[UIImage imageNamed:@"orange_radius_hollow"] stretchableImageWithLeftCapWidth:7 topCapHeight:7];
    CoachItemCell *cell = [super createCell];
//    [cell.commitButton setBackgroundImage:[SportImage orangeFrameButtonImage] forState:UIControlStateNormal];
//    [cell.commitButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateHighlighted];
//    [cell.commitButton setBackgroundImage:image forState:UIControlStateNormal];
    
    cell.backgroundView = [[UIImageView alloc] initWithImage:[[SportImage whiteBackgroundWithGrayLineImage] stretchableImageWithLeftCapWidth:3 topCapHeight:3]];
    
    //预约页面使用(高度比例伸缩)
    if(CellTypeBooking == cellType) {
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:cell.contentholderView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeHeight multiplier:0.8f constant:0.0f]];
        cell.commitButton.hidden = YES;
    }
    return cell;
}

+ (CGFloat)getCellHeightWithCellType:(CellType)cellType {
    if(CellTypeDisplay == cellType) {
        return CELL_HEIGHT_DISPLAY;
    }else if (CellTypeBooking == cellType) {
        return CELL_HEIGHT_BOOKING;
    }
    return 100;
}

- (IBAction)clickBookingButton:(id)sender {
    [_delegate coachItemDidBookingWithProject:_project];
}

-(void)showWithSuperView:(UIView *)superView
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSMutableDictionary *viewsDictionary = [[ NSMutableDictionary alloc] initWithDictionary:
                                            @{@"cell":self
                                              }];
    NSMutableArray *constraints = [NSMutableArray array];
    [superView addSubview:self];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[cell]-(0)-|" options:0 metrics:nil views:viewsDictionary]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[cell]-(0)-|" options:0 metrics:nil views:viewsDictionary]];
    [superView addConstraints:constraints];
}

- (void)updateCellWithItem:(CoachProjects *)project {
    self.project = project;
    self.itemTitleLabel.text = project.projectName;
    self.priceLabel.text = [NSString stringWithFormat:@"%d元", project.price];
    self.timeLabel.text = [NSString stringWithFormat:@"时长：%d小时", project.minutes / 60];
    
    if([project.roleId isEqualToString:ROLE_ID_PEILIAN]){
        [self.iconImageView setImage:[UIImage imageNamed:@"icon_peilian"]];
    }else if([project.roleId isEqualToString:ROLE_ID_JIAOLIAN]){
        [self.iconImageView setImage:[UIImage imageNamed:@"icon_jiaolian"]];
    }
}

@end
