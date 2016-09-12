//
//  orderInfomationCell.m
//  Sport
//
//  Created by 赵梦东 on 15/9/2.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "OrderInformationCell.h"
#import "UIImageView+WebCache.h"
#import "UIView+Utils.h"
#import "UIImage+Extension.h"
@implementation OrderInformationCell

+ (NSString *)getCellIdentifier
{
    return @"OrderInformationCell";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

+ (instancetype)cellWithTableView:(UITableView *)tableView {

    static NSString *ID = @"OrderInformationCell";
    OrderInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [super createCell];
        
        UIImage *img=[UIImage resizedImage:@"OrderInformationCell"];
        
        [cell.backgroundImg setImage:img];
//        cell.backgroundImg.layer.cornerRadius=3;
//        cell.backgroundImg.layer.masksToBounds=YES;
        
     // [cell.lineImg updateHeight:0.25];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

+ (float)height
{
    return 105;
}

- (void)setTodayOrder:(TodayOrderInfo *)todayOrder{
    NSArray *array = [todayOrder.name componentsSeparatedByString:@"-"];
    
    if (array) {
        self.placeLabel.text=array[0];
    }
    //courtJoinSign
    CGSize size = [_placeLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObject:_placeLabel.font forKey:NSFontAttributeName]];
    CGFloat marign = 5.f;
    CGFloat labelMaxWidth = [UIScreen mainScreen].bounds.size.width - CGRectGetMaxX(_imgView.frame) - _courtJoinSignImageView.frame.size.width - 6 * marign;
//    labelMaxWidth = self.frame.size.width - _placeLabel.frame.origin.x - _courtJoinSignImageView.frame.size.width - 15;
    if (size.width > labelMaxWidth) {
        size.width = labelMaxWidth;
    }
    [_placeLabel updateWidth:size.width];
    if (todayOrder.isCourtJoinParent) {
        _courtJoinSignImageView.hidden = NO;
        [_courtJoinSignImageView updateOriginX:CGRectGetMaxX(_placeLabel.frame) + 5];
        [_courtJoinSignImageView updateCenterY:_placeLabel.center.y];
    } else {
        _courtJoinSignImageView.hidden = YES;
    }
    
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:todayOrder.icon]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd HH:mm"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[todayOrder.startTime integerValue]];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];

    self.startTimeLabel.text= [NSString stringWithFormat:@"%@",confromTimespStr] ;
    
    if ([todayOrder.verificationCode length] > 0 && todayOrder.type != OrderTypeCoach) {
        self.checkNumberLabel.text=todayOrder.verificationCode;
    } else if (todayOrder.type == OrderTypeMembershipCard) {
        self.checkNumberLabel.text = @"会员卡";
    } else {
        self.checkNumberLabel.text=@"-";
    }
}

@end
