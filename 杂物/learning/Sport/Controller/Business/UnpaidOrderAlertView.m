//
//  UnpaidOrderAlertView.m
//  Sport
//
//  Created by haodong  on 14/10/29.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "UnpaidOrderAlertView.h"
#import "ProductDetailView.h"
#import <QuartzCore/QuartzCore.h>
#import "Order.h"
#import "UIView+Utils.h"
#import "PriceUtil.h"
#import "DateUtil.h"
#import "SportUnpaidAlertViewCell.h"
#import "Product.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "BusinessGoods.h"

@interface UnpaidOrderAlertView()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *detailInfoTableView;
@property (strong, nonatomic) NSMutableArray *titleList;
@property (strong,nonatomic) Order *order;

@end

#define TITLE_DATE @"日期："
#define TITLE_COURT @"场地："
#define TITLE_AMOUNT @"共计："
#define TITLE_SALES @"卖品："
#define TITLE_COURSE_NAME @"课程名称："
#define TITLE_COURSE_TIME @"上课时间："
#define TITLE_PACKAGE_NAME @"套餐："
#define TITLE_PACKAGE_NUMBER @"数量："

@implementation UnpaidOrderAlertView

+ (UnpaidOrderAlertView *)createUnpaidOrderAlertView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"UnpaidOrderAlertView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    UnpaidOrderAlertView *view = [topLevelObjects objectAtIndex:0];
    
    view.frame = [UIScreen mainScreen].bounds;
    view.contentHolderView.layer.cornerRadius = 3;
    view.contentHolderView.layer.masksToBounds = YES;
    
    [(UIImageView *)[view.contentHolderView viewWithTag:100] setImage:[SportImage lineImage]];
    [(UIImageView *)[view.bottomHolderView viewWithTag:100] setImage:[SportImage lineImage]];
    [(UIImageView *)[view.bottomHolderView viewWithTag:200] setImage:[SportImage lineVerticalImage]];
    
    
    view.detailInfoTableView.delegate = view;
    view.detailInfoTableView.dataSource = view;
    view.detailInfoTableView.fd_debugLogEnabled = NO;
    UINib *cellNib = [UINib nibWithNibName:[SportUnpaidAlertViewCell getCellIdentifier] bundle:nil];
    [view.detailInfoTableView registerNib:cellNib forCellReuseIdentifier:[SportUnpaidAlertViewCell getCellIdentifier]];
    
    return view;
}

- (void)updateViewWithOrder:(Order *)order
{
    self.order = order;
    
    NSString *title = order.businessName;
    if ( order.type == OrderTypeCourtJoin) {
        title = [NSString stringWithFormat:@"%@ 球局", order.businessName];
    }
    
    self.businessNameLabel.text = title;
    
    self.titleList = [NSMutableArray arrayWithObject:title];
    
    CGFloat y = 0;
    if (order.type == OrderTypeDefault || order.type == OrderTypeMembershipCard || order.type == OrderTypeCourtJoin) {
        
        [self.titleList addObjectsFromArray:@[TITLE_DATE,TITLE_COURT]];
        if ([order.goodsList count]> 0) {
            [self.titleList addObject:TITLE_SALES];
        }
        
        self.singleHolderView.hidden = YES;
    } else {
        if (order.type == OrderTypeCourse) {
            [self.titleList addObjectsFromArray:@[TITLE_COURSE_NAME,TITLE_COURSE_TIME]];
            //课程
            self.packageNameLabel.text = @"课程名称：";
            self.amountTimeLabel.text = @"上课时间：";
            self.singleGoodsNameLabel.text = order.goodsName;
            NSString *startTimeString = [DateUtil stringFromDate:order.courseStartTime DateFormat:@"yyyy.MM.dd HH:mm"];
            NSString *endTimeString = [DateUtil stringFromDate:order.courseEndTime DateFormat:@"HH:mm"];
            self.singleGoodsCountLabel.text = [NSString stringWithFormat:@"%@-%@",startTimeString,endTimeString];
        } else {
            [self.titleList addObjectsFromArray:@[TITLE_PACKAGE_NAME,TITLE_PACKAGE_NUMBER]];
            //人次
            self.packageNameLabel.text = @"套餐：";
            self.amountTimeLabel.text = @"数量：";
            self.singleGoodsNameLabel.text = order.goodsName;
            self.singleGoodsCountLabel.text = [NSString stringWithFormat:@"%d", order.count];
        }
    }
    
    if (order.type == OrderTypeMembershipCard || order.isClubPay == YES) {
        self.totalPriceHolderView.hidden = YES;
        y = y + 5;
    } else {
        
        [self.titleList addObject:TITLE_AMOUNT];
    }
    
    [self.detailInfoTableView updateHeight:[self getTableViewHeight]];
    y = self.detailInfoTableView.frame.origin.y + self.detailInfoTableView.frame.size.height;
    [self.detailInfoTableView reloadData];
    [self.bottomHolderView updateOriginY:y];
    [self.contentHolderView updateHeight:_bottomHolderView.frame.origin.y + _bottomHolderView.frame.size.height];
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    [self.contentHolderView updateCenterY:screenHeight / 2];
}

#define CELL_HEIGHT [SportUnpaidAlertViewCell getCellHeight]
#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.titleList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [SportUnpaidAlertViewCell getCellIdentifier];
    SportUnpaidAlertViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Use cell delegate
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier:[SportUnpaidAlertViewCell getCellIdentifier] configuration:^(SportUnpaidAlertViewCell *cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}

-(void) configureCell:(SportUnpaidAlertViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.fd_enforceFrameLayout = NO;
    NSString *title = self.titleList[indexPath.row];
    NSString *subValue = @" ";
    if ([title isEqualToString:TITLE_DATE]) {
        
        NSString *dateString = [DateUtil stringFromDate:self.order.useDate DateFormat:@"yyyy-MM-dd"];
        
        NSString *weekString = [DateUtil ChineseWeek2:self.order.useDate];
        
        subValue = [NSString stringWithFormat:@"%@ (%@)", dateString, weekString];
    } else if ([title isEqualToString:TITLE_COURT]){
        NSMutableString *courtTimeStr = [NSMutableString string];
        int index = 0;
        for (Product *product in self.order.productList) {
            [courtTimeStr appendString:[NSString stringWithFormat:@"%@ %@ ", product.courtName, [product startTimeToEndTime]]];
            if ((self.order.type != OrderTypeMembershipCard)) {
                if (self.order.type == OrderTypeCourtJoin) {
                    [courtTimeStr appendString:[PriceUtil toPriceStringWithYuan:product.courtJoinPrice]];
                } else {
                    [courtTimeStr appendString:[PriceUtil toPriceStringWithYuan:product.price]];
                }
            }
            
            if (index < [self.order.productList count] - 1) {
                [courtTimeStr appendString:@"\n"];
            }
            
            index++;
        }
        
        subValue = courtTimeStr;
    } else if ([title isEqualToString:TITLE_SALES]) {
        NSMutableString *goodsStr = [NSMutableString string];
        int index = 0;
        for (BusinessGoods *goods in self.order.goodsList) {
            [goodsStr appendString:[NSString stringWithFormat:@"%@ %@%@", goods.name, [PriceUtil toPriceStringWithYuan:goods.price],goods.totalCount > 1?[NSString stringWithFormat:@"×%d",goods.totalCount]:@""]];
            
            if (index < [self.order.goodsList count] - 1) {
                [goodsStr appendString:@"\n"];
            }
            
            index++;
        }
        
        subValue = goodsStr;
    } else if ([title isEqualToString:TITLE_AMOUNT]) {
        subValue = [PriceUtil toPriceStringWithYuan:self.order.amount];
    } else if ([title isEqualToString:TITLE_COURSE_NAME]) {
        subValue = self.order.goodsName;
    } else if ([title isEqualToString:TITLE_COURSE_TIME]) {
        NSString *startTimeString = [DateUtil stringFromDate:_order.courseStartTime DateFormat:@"yyyy.MM.dd HH:mm"];
        NSString *endTimeString = [DateUtil stringFromDate:_order.courseEndTime DateFormat:@"HH:mm"];
        subValue= [NSString stringWithFormat:@"%@-%@",startTimeString,endTimeString];

    } else if ([title isEqualToString:TITLE_PACKAGE_NAME]) {
        subValue = self.order.goodsName;
    } else if ([title isEqualToString:TITLE_PACKAGE_NUMBER]) {
        subValue = [@(_order.count) stringValue];
    }
    
    [cell updateViewWithTitle:title detail:subValue];
    
}

-(CGFloat) getTableViewHeight {
    
    CGFloat maxHeight = [UIScreen mainScreen].bounds.size.height - 64 - 100;
    CGFloat actualHeight = 0;
    for(int i = 0;i < self.titleList.count;i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        
        actualHeight += [self.detailInfoTableView fd_heightForCellWithIdentifier:[SportUnpaidAlertViewCell getCellIdentifier] configuration:^(SportUnpaidAlertViewCell *cell) {
            [self configureCell:cell atIndexPath:indexPath];
        }];
    }
    
    return actualHeight > maxHeight?maxHeight:actualHeight;
}

- (void)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    self.contentHolderView.alpha = 0;
    self.contentHolderView.transform = CGAffineTransformMakeScale(1.1, 1.1);
    
    [UIView animateWithDuration:0.2 delay:0.06 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.contentHolderView.alpha = 1;
        self.contentHolderView.transform = CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)clickCancelButton:(id)sender {
    [MobClickUtils event:umeng_event_click_affirm_order_cancel_club_order_window];
    if ([_delegate respondsToSelector:@selector(didClickUnpaidOrderAlertViewCancelButton)]) {
        [_delegate didClickUnpaidOrderAlertViewCancelButton];
    }
    [self removeFromSuperview];
}

- (IBAction)clickPayButton:(id)sender {
    [MobClickUtils event:umeng_event_click_affirm_order_config_club_order_window];
    if ([_delegate respondsToSelector:@selector(didClickUnpaidOrderAlertViewPayButton)]) {
        [_delegate didClickUnpaidOrderAlertViewPayButton];
    }
    [self removeFromSuperview];
}

@end
