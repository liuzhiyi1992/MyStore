//
//  OrderSimpleCell.m
//  Sport
//
//  Created by haodong  on 14-7-17.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "OrderSimpleCell.h"
#import "Order.h"
#import "PriceUtil.h"
#import "UIView+Utils.h"
#import "DateUtil.h"
#import "UIImageView+WebCache.h"

@interface OrderSimpleCell()
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIButton *coachOrderActionButton;
@property (weak, nonatomic) IBOutlet UIImageView *courtJoinSignImageView;
@property (weak, nonatomic) IBOutlet UIImageView *nameEndLineImageView;

@end

@implementation OrderSimpleCell
+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"OrderSimpleCell";
   OrderSimpleCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"OrderSimpleCell" owner:nil options:nil][0];
    }
    
    return cell;
}


+ (NSString*)getCellIdentifier
{
    return @"OrderSimpleCell";
}

#define HEIGHT_BASE     157
#define HEIGHT_SPACE    15
#define HEIGHT_BOTTOM   45
+ (CGFloat)getCellHeightWithOrder:(Order *)order
{
    BOOL hasBottomButton = NO;
    
//    if ((order.type == OrderTypeSingle || order.type == OrderTypePackage || order.type == OrderTypeCourse) && order.status != OrderStatusUnpaid) {
//        hasBottomButton = YES;
//    }
    
    if (order.commentStatus == CommentStatusValid &&
        (order.status == OrderStatusUsed || order.status == OrderStatusExpired || order.status == OrderStatusPaid) && order.type != OrderTypeCoach ) {
        hasBottomButton = YES;
    }
    
    if (order.type == OrderTypeCoach) {
        switch (order.coachStatus) {
            case CoachOrderStatusReadyCoach:
            case CoachOrderStatusCoaching:
            case CoachOrderStatusReadyConfirm:
                if(!order.isCoachCanCancel) {
                    hasBottomButton = YES;
                }
                break;
            case CoachOrderStatusFinished:
                switch(order.commentStatus) {
                    case CommentStatusValid:
                        hasBottomButton = YES;
                        break;
                }
        }
    }
    
    if (order.status == OrderStatusUnpaid) {
        hasBottomButton = YES;
    }
    
//    if (order.type == OrderTypeSingle) {
//        hasBottomButton = YES;
//    }
    
    if (hasBottomButton) {
        return HEIGHT_BASE + HEIGHT_SPACE;
    } else {
        return HEIGHT_BASE + HEIGHT_SPACE - HEIGHT_BOTTOM;
    }
}

+ (id)createCell
{
    OrderSimpleCell *cell = (OrderSimpleCell *)[super createCell];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    [cell.cancelButton setBackgroundImage:[SportImage grayFrameButtonImage] forState:UIControlStateNormal];
//    [cell.cancelButton setBackgroundImage:[SportImage grayButtonImage] forState:UIControlStateHighlighted];
    
//    [cell.payButton setBackgroundImage:[SportImage orangeFrameButtonImage] forState:UIControlStateNormal];
//    [cell.payButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateHighlighted];
    
//    [cell.writeReviewButton setTitleColor:[SportColor defaultOrangeColor] forState:UIControlStateNormal];
//    [cell.writeReviewButton setBackgroundImage:[SportImage orangeFrameButtonImage] forState:UIControlStateNormal];
//    [cell.writeReviewButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateHighlighted];
//    
//    [cell.webDetailButton setTitleColor:[SportColor defaultOrangeColor] forState:UIControlStateNormal];
//    [cell.webDetailButton setBackgroundImage:[SportImage orangeFrameButtonImage] forState:UIControlStateNormal];
//    [cell.webDetailButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateHighlighted];
    cell.webDetailButton.hidden = YES;
//    [cell.coachOrderActionButton setTitleColor:[SportColor defaultOrangeColor] forState:UIControlStateNormal];
//    [cell.coachOrderActionButton setBackgroundImage:[SportImage orangeFrameButtonImage] forState:UIControlStateNormal];
//    [cell.coachOrderActionButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateHighlighted];
    cell.coachOrderActionButton.hidden = YES;
    
    UIImage *image = [[SportColor createImageWithColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1]] stretchableImageWithLeftCapWidth:1 topCapHeight:1];
    [cell.backgroundButton setBackgroundImage:image forState:UIControlStateHighlighted];
    
    for (UIView *first in cell.contentView.subviews) {
        if ([first isKindOfClass:[UIImageView class]]) {
            if (first.tag == 100) {
                [(UIImageView *)first setBackgroundColor:[UIColor hexColor:@"f5f5f9"]];
                [(UIImageView *)first updateHeight:0.5f];
            }
            if (first.tag == 101) {
                [(UIImageView *)first setBackgroundColor:[UIColor hexColor:@"f5f5f9"]];
                [(UIImageView *)first updateWidth:0.5f];
            }
        }
        
        for (UIView *second in first.subviews) {
            if (second.tag == 100 && [second isKindOfClass:[UIImageView class]]) {
                [(UIImageView *)second setBackgroundColor:[UIColor hexColor:@"f5f5f9"]];
                [(UIImageView *)second updateHeight:0.5f];
            }
        }
    }
    
    return cell;
}

- (void)updateCellWithOrder:(Order *)order indexPath:(NSIndexPath *)indexPath
{
    self.indexPath = indexPath;
    
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:order.iconURL]];
    
    _businessNameLabel.text = order.title;
    //update width
    CGSize size = [_businessNameLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObject:_businessNameLabel.font forKey:NSFontAttributeName]];
    
    //处理球馆名过长的问题
    if (size.width + _businessNameLabel.frame.origin.x > self.nameEndLineImageView.frame.origin.x) {
        size.width = _nameEndLineImageView.frame.origin.x - _businessNameLabel.frame.origin.x -5;
    }
   
    [_businessNameLabel updateWidth:size.width];
    
    if (order.isCourtJoinParent) {
        _courtJoinSignImageView.hidden = NO;
        if (_businessNameLabel.frame.size.width + _businessNameLabel.frame.origin.x + _courtJoinSignImageView.frame.size.width > self.nameEndLineImageView.frame.origin.x) {
            size.width = _nameEndLineImageView.frame.origin.x - _courtJoinSignImageView.frame.size.width - _businessNameLabel.frame.origin.x - 5;
            [_businessNameLabel updateWidth:size.width];
        }
        
        [_courtJoinSignImageView updateOriginX:CGRectGetMaxX(_businessNameLabel.frame) + 5];
        [_courtJoinSignImageView updateCenterY:_businessNameLabel.center.y];
    } else {
        _courtJoinSignImageView.hidden = YES;

    }

    self.statusLabel.text = [order orderStatusText];
    if ([order.fieldNo length] > 0) {
        self.categoryLabel.text = order.fieldNo;
    } else {
        self.categoryLabel.text = @"-";
    }
    if ([order.consumeCode length] > 0) {
        self.consumeCodeLabel.text = order.consumeCode;
    } else {
        if (order.type == OrderTypeMembershipCard) {
            self.consumeCodeLabel.text = @"会员卡";
        } else if(order.type == OrderTypeCoach || order.type == OrderTypeCourtPool || order.type == OrderTypeCourtJoin) {
            self.consumeCodeLabel.text =@"-";
        }else {
            self.consumeCodeLabel.text = @"暂无";
        }
    }
    
    if (_dateFormatter == nil) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter = dateFormatter;
    }
    
    if (order.type == OrderTypeCoach) {
        [self.dateFormatter setDateFormat:@"MM/dd "];
    } else {
        [self.dateFormatter setDateFormat:@"MM/dd HH:mm"];
    }
        
    //人次不显示时间
    if (order.type == OrderTypeSingle || order.type == OrderTypePackage) {
        self.useDateLabel.text = @"不限";
    } else {
        if (order.type == OrderTypeCoach) {
            self.useDateLabel.text = [NSString stringWithFormat:@"%@%@",[_dateFormatter stringFromDate:order.startTime],[order coachOrderTimeRangeText]];
        } else {
            self.useDateLabel.text = [_dateFormatter stringFromDate:order.startTime];
        }
    }
    
    double displayAmount = order.amount + order.money;
    self.priceLabel.text = [NSString stringWithFormat:@"%@元", [PriceUtil toValidPriceString:displayAmount]];
    
    BOOL hasBottomButton = NO;
    
    if (indexPath.row == 0) {
        HDLog(@"0");
    }
    
    //设置图文详情按钮的显示与否，使用日期的显示与否
    if (order.type == OrderTypeSingle || order.type == OrderTypePackage || (order.type == OrderTypeCourse)) {
        //self.useDateTitleLabel.hidden = YES;
        //self.useDateLabel.hidden = YES;
        
//        if (order.status == OrderStatusUnpaid) {
//            self.webDetailButton.hidden = YES;
//        } else {
//            hasBottomButton = YES;
//            self.webDetailButton.hidden = NO;
//        }
//    } else if (order.type == OrderTypeCourse) {
//        self.categoryLabel.text = order.goodsName;
//        
//        NSString *startTimeString = [DateUtil stringFromDate:order.courseStartTime DateFormat:@"yyyy.MM.dd"];
//
//        self.useDateLabel.text = startTimeString;
//        self.categoryTitleLabel.text = @"课程名称：";
//        self.useDateTitleLabel.text = @"开始日期：";
//        self.useDateTitleLabel.hidden = NO;
//        self.useDateLabel.hidden = NO;
//        
//        if (order.status == OrderStatusUnpaid) {
//            self.webDetailButton.hidden = YES;
//        } else {
//            hasBottomButton = YES;
//            self.webDetailButton.hidden = NO;
//        }
    } else {
        //self.categoryTitleLabel.text = @"预约场号：";
        //self.useDateTitleLabel.text = @"开始时间：";
        self.useDateTitleLabel.hidden = NO;
        self.useDateLabel.hidden = NO;
        
        self.webDetailButton.hidden = YES;
    }
    
    //设置评价按钮的显示与否(约练订单单独处理)
    if (order.commentStatus == CommentStatusValid &&
        (order.status == OrderStatusUsed || order.status == OrderStatusExpired || order.status == OrderStatusPaid) && order.type != OrderTypeCoach) {
        self.writeReviewButton.hidden = NO;
        hasBottomButton = YES;
    } else {
        self.writeReviewButton.hidden = YES;
    }
    
    //设置图文详情的设置
    if (_webDetailButton.hidden == NO && _writeReviewButton.hidden == NO) {
        [self.webDetailButton setCenter:_cancelButton.center];
    } else if (_webDetailButton.hidden == NO && _writeReviewButton.hidden == YES) {
        [self.webDetailButton setCenter:_writeReviewButton.center];
    }
    
    self.coachOrderActionButton.hidden = YES;
    if (order.type == OrderTypeCoach) {
        switch (order.coachStatus) {
            case CoachOrderStatusReadyCoach:
                //待陪练，一天前可取消，当天不可取消
                if(order.isCoachCanCancel) {
                    hasBottomButton = NO;
                    self.coachOrderActionButton.hidden = YES;
                    //[self setCoachOrderActionButtonStyle:ActionButtonTypeCancel];
                } else {
                    hasBottomButton = YES;
                    self.coachOrderActionButton.hidden = NO;
                    [self setCoachOrderActionButtonStyle:ActionButtonTypeConfirm];
                }
                
                break;
            case CoachOrderStatusCoaching:
            case CoachOrderStatusReadyConfirm:
                [self setCoachOrderActionButtonStyle:ActionButtonTypeConfirm];
                self.coachOrderActionButton.hidden = NO;
                hasBottomButton = YES;
                break;
            case CoachOrderStatusFinished:
                switch(order.commentStatus) {
                    case CommentStatusValid:
                        self.writeReviewButton.hidden = NO;
                        hasBottomButton = YES;
                        break;
                    case CommentStatusInvalid:
                    case CommentStatusAlreadyComment:
                    default:
                        self.writeReviewButton.hidden = YES;
                        break;
                }
                
                break;
            case CoachOrderStatusUnPaidCancelled:
            case CoachOrderStatusCancelled:
            case CoachOrderStatusExpired:
            case CoachOrderStatusRefund:
                hasBottomButton = NO;
            default:
                break;
        }
    }
    
    //设置取消、支付按钮的显示与否
    if (order.status == OrderStatusUnpaid) {
        self.cancelButton.hidden = NO;
        self.payButton.hidden = NO;
        hasBottomButton = YES;
    } else {
        self.cancelButton.hidden = YES;
        self.payButton.hidden = YES;
    }
    
//    if (order.type == OrderTypeSingle) {
//        self.writeReviewButton.hidden = NO;
//        hasBottomButton = YES;
//    } else {
//        self.writeReviewButton.hidden = YES;
//    }
    
    if (hasBottomButton) {
        self.buttonHolderView.hidden = NO;
        [self.backgroundImageView updateHeight:HEIGHT_BASE];
        [self.backgroundButton updateHeight:HEIGHT_BASE];
        [self updateHeight:HEIGHT_BASE + HEIGHT_SPACE];
    } else {
        self.buttonHolderView.hidden = YES;
        [self.backgroundImageView updateHeight:HEIGHT_BASE - HEIGHT_BOTTOM];
        [self.backgroundButton updateHeight:HEIGHT_BASE - HEIGHT_BOTTOM];
        [self updateHeight:HEIGHT_BASE + HEIGHT_SPACE - HEIGHT_BOTTOM];
    }
    
    //设置消费验证码、金额的显示与否
    if (order.type == OrderTypeMembershipCard || order.isClubPay) {
        //self.consumeCodeHolderView.hidden = YES;
        //self.priceHolderView.hidden = YES;
        self.priceLabel.text = order.cardAmount > 0?[PriceUtil toValidPriceString:order.cardAmount]:@"-";
    }
//    else {
//        self.consumeCodeHolderView.hidden = NO;
//        if (order.isClubPay == YES) {
//            self.priceHolderView.hidden = YES;
//        } else {
//            self.priceHolderView.hidden = NO;
//        }
//    }
    

}

-(void)setCoachOrderActionButtonStyle:(ActionButtonType)style {
    if (style == ActionButtonTypeCancel) {
//        [self.coachOrderActionButton setBackgroundImage:[SportImage grayFrameButtonImage] forState:UIControlStateNormal];
//        [self.coachOrderActionButton setBackgroundImage:[SportImage grayButtonImage] forState:UIControlStateHighlighted];
        [self.coachOrderActionButton setTitle:@"取消预约" forState:UIControlStateNormal];
        [self.coachOrderActionButton setTitleColor:[SportColor content2Color] forState:UIControlStateNormal];
        self.coachOrderActionButton.layer.borderColor = [SportColor content2Color].CGColor;
    } else {
        self.coachOrderActionButton.layer.borderColor = [SportColor defaultColor].CGColor;
        [self.coachOrderActionButton setTitleColor:[SportColor defaultColor] forState:UIControlStateNormal];
//
//        [self.coachOrderActionButton setBackgroundImage:[SportImage orangeFrameButtonImage] forState:UIControlStateNormal];
//        [self.coachOrderActionButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateHighlighted];
        
        [self.coachOrderActionButton setTitle:@"练完确认" forState:UIControlStateNormal];
    }

}

- (IBAction)clickBackgroundButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickOrderSimpleCellButton:)]) {
        [_delegate didClickOrderSimpleCellButton:_indexPath];
    }
}

- (IBAction)clickCancelButto:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickOrderSimpleCellCancelButton:)]) {
        [_delegate didClickOrderSimpleCellCancelButton:_indexPath];
    }
}

- (IBAction)clickPayButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickOrderSimpleCellPayButton:)]) {
        [_delegate didClickOrderSimpleCellPayButton:_indexPath];
    }
}

- (IBAction)clickWriteReviewButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickOrderSimpleCellWriteReviewButton:)]) {
        [_delegate didClickOrderSimpleCellWriteReviewButton:_indexPath];
    }
}

- (IBAction)clickWebDetailButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickOrderSimpleCellWebDetailButtonButton:)]) {
        [_delegate didClickOrderSimpleCellWebDetailButtonButton:_indexPath];
    }
}

- (IBAction)clickCoachActionButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickOrderSimpleCellCoachActionButton:)]) {
        [_delegate didClickOrderSimpleCellCoachActionButton:_indexPath];
    }
    
}
@end
