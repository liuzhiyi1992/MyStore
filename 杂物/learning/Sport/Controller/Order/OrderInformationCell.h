//
//  orderInfomationCell.h
//  Sport
//
//  Created by 赵梦东 on 15/9/2.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TodayOrderInfo.h"
#import "Order.h"
#import "DDTableViewCell.h"

@interface OrderInformationCell : DDTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkNumberLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImg;
@property (weak, nonatomic) IBOutlet UIImageView *lineImg;

@property (strong, nonatomic) TodayOrderInfo *todayOrder;
@property (weak, nonatomic) IBOutlet UIImageView *courtJoinSignImageView;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

+ (float)height;

@end
