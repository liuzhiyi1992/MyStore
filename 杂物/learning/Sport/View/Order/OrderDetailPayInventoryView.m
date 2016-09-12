//
//  OrderDetailPayInventoryView.m
//  Sport
//
//  Created by lzy on 16/8/1.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "OrderDetailPayInventoryView.h"
#import "Order.h"
#import "PriceUtil.h"
#import <objc/runtime.h>

#define INVENTORY_ITEM_LINE_SPACING 8
#define INVENTORY_ITEM_MARGIN_SPACING 40
#define INVENTORY_VIEW_TOP_MARGIN 15
#define FONT_SIZE 14
#define FONT_COLOR [UIColor hexColor:@"666666"]
#define STRING_COLOR_LIGHT [UIColor hexColor:@"5b73f2"]

@interface OrderDetailPayInventoryView ()
@property (weak, nonatomic) IBOutlet UIView *mainBriefView;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewDetailsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowDownImageView;
@property (strong, nonatomic) UIView *inventoryView;
@property (strong, nonatomic) NSArray *payInventoryArray;
@property (strong, nonatomic) NSDictionary *payInventoryDict;
@property (strong, nonatomic) Order *order;

@end

@implementation OrderDetailPayInventoryView
+ (OrderDetailPayInventoryView *)createViewWithOrder:(Order *)order {
    OrderDetailPayInventoryView *view = [[NSBundle mainBundle] loadNibNamed:@"OrderDetailPayInventoryView" owner:self options:nil][0];
    view.order = order;
    [view configureView];
    [view configureInventoryData];
    return view;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [touches enumerateObjectsUsingBlock:^(UITouch * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.view == _mainBriefView) {
            [self handleTouchEvent];
        }
    }];
}

- (void)handleTouchEvent {
    if (_order.status != OrderStatusUnpaid) {
        if (nil == _inventoryView) {
            [self configureInventoryView];
        } else if (nil == _inventoryView.superview) {
            [self setupInventoryView];
        } else {
            [UIView animateWithDuration:0.2 animations:^{
                [_arrowDownImageView setTransform:CGAffineTransformMakeRotation(0)];
            }];
            [_inventoryView removeFromSuperview];
        }
    }
}

- (void)configureView {
    _titleLabel.text = (_order.status != OrderStatusUnpaid) ? @"共支付" : @"待支付";
    BOOL detailVisable = (_order.status != OrderStatusUnpaid) ? YES : NO;
    _viewDetailsLabel.hidden = !detailVisable;
    _arrowDownImageView.hidden = !detailVisable;
}

- (void)configureInventoryData {
    NSMutableArray *inventoryArray = [NSMutableArray array];
    if (_order.type != OrderTypeMembershipCard) {//非会员卡订单
        self.amountLabel.text = [NSString stringWithFormat:@"%@", [PriceUtil toPriceStringWithYuan:(_order.amount + _order.money)]];
        //总额
        NSString *totalAmountString = [PriceUtil toPriceStringWithYuan:_order.totalAmount];
        [self valueStringBindingKey:@"总额" valueString:totalAmountString];
        [inventoryArray addObject:totalAmountString];
        //卡券
        if (0 != _order.voucherAmount) {
            NSString *valueString = [NSString stringWithFormat:@"-%@", [PriceUtil toPriceStringWithYuan:_order.voucherAmount]];
            [self valueStringBindingKey:@"卡券" valueString:valueString];
            [inventoryArray addObject:valueString];
        }
        //活动
        if (0 != _order.promotionAmount) {
            NSString *valueString = [NSString stringWithFormat:@"-%@", [PriceUtil toPriceStringWithYuan:_order.promoteAmount]];
            [self valueStringBindingKey:@"活动" valueString:valueString];
            [inventoryArray addObject:valueString];
        }
        //余额支付
        if (0 != _order.money) {
            NSString *valueString = [PriceUtil toPriceStringWithYuan:_order.money];
            [self valueStringBindingKey:@"余额支付" valueString:valueString];
            [self lightedValueString:valueString];
            [inventoryArray addObject:valueString];
        }
        //第三方支付
        if (0 != _order.amount && _order.status == OrderStatusPaid) {
            NSString *valueString = [PriceUtil toPriceStringWithYuan:_order.amount];
            [self valueStringBindingKey:_order.payMethodName valueString:valueString];
            [self lightedValueString:valueString];
            [inventoryArray addObject:valueString];
        }
    } else {//会员卡订单
        _titleLabel.text = @"会员卡订单";
        [_amountLabel removeFromSuperview];
        //会员卡号 应扣金额
        if (0 == _order.cardAmount) {
            //未结算
            NSString *valueString = [NSString stringWithFormat:@"%@", @""];
            [self valueStringBindingKey:_order.cardNumber valueString:valueString];
            [inventoryArray addObject:valueString];
        } else {
            //结算
            NSString *valueString = [NSString stringWithFormat:@"-%@", [PriceUtil toPriceStringWithYuan:_order.cardAmount]];
            [self valueStringBindingKey:_order.cardNumber valueString:valueString];
            [self lightedValueString:valueString];
            [inventoryArray addObject:valueString];
        }
    }
    self.payInventoryArray = [inventoryArray copy];
}

- (void)configureInventoryView {
    self.inventoryView = [[UIView alloc] init];
    [_inventoryView setBackgroundColor:[UIColor whiteColor]];
    if (_payInventoryArray.count == 0) {
        return;
    }
    NSMutableDictionary *layoutViews = [NSMutableDictionary dictionary];
    NSMutableString *vConstraintString = [NSMutableString stringWithFormat:@"V:|"];
    //breakLine
    UIView *lineView = [[UIView alloc] init];
    [lineView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [lineView setBackgroundColor:[UIColor hexColor:@"f5f5f9"]];
    [layoutViews setObject:lineView forKey:@"lineView"];
    [_inventoryView addSubview:lineView];
    [_inventoryView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[lineView]|" options:0 metrics:nil views:layoutViews]];
    [vConstraintString appendString:@"[lineView(0.5)]"];
    //items
    NSInteger numberFlag = 0;
    for (NSString *item in _payInventoryArray) {
        NSString *key = [self getBindingKeyWithValueString:item];
        UILabel *flagLabel = [self configureItemAndReturnFlagWithKey:key content:item];
        NSString *flagString = [NSString stringWithFormat:@"indexView%ld", (long)++numberFlag];
        [layoutViews setObject:flagLabel forKey:flagString];
        [vConstraintString appendFormat:@"-%d-[%@]", INVENTORY_ITEM_LINE_SPACING, flagString];
    }
    [vConstraintString appendFormat:@"-%d-|", INVENTORY_ITEM_LINE_SPACING];
    [_inventoryView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vConstraintString options:0 metrics:nil views:layoutViews]];
    //setup
    [self setupInventoryView];
}

- (void)setupInventoryView {
    [self addSubview:_inventoryView];
    NSMutableDictionary *layoutViews = [NSMutableDictionary dictionary];
    [_mainBriefView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_inventoryView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [layoutViews setObject:_mainBriefView forKey:@"mainBriefView"];
    [layoutViews setObject:_inventoryView forKey:@"inventoryView"];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[mainBriefView][inventoryView]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:layoutViews]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[inventoryView]|" options:0 metrics:nil views:layoutViews]];
    [UIView animateWithDuration:0.2 animations:^{
        [_arrowDownImageView setTransform:CGAffineTransformMakeRotation(M_PI)];
    }];
}

- (UILabel *)configureItemAndReturnFlagWithKey:(NSString *)key content:(NSString *)content {
    UILabel *flagLabel = [[UILabel alloc] init];
    [flagLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    flagLabel.text = key;
    flagLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
    flagLabel.textColor = FONT_COLOR;
    [_inventoryView addSubview:flagLabel];
    
    UILabel *contentLabel = [[UILabel alloc] init];
    [contentLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    //todo attributeString
    if ([self isLightString:content]) {
        NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:content attributes:@{NSForegroundColorAttributeName:STRING_COLOR_LIGHT}];
        contentLabel.attributedText = attributeString;
    } else {
        contentLabel.text = content;
        contentLabel.textColor = FONT_COLOR;
    }
    contentLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
    [_inventoryView addSubview:contentLabel];
    
    //Constraint
    [_inventoryView addConstraint:[NSLayoutConstraint constraintWithItem:flagLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_inventoryView attribute:NSLayoutAttributeLeading multiplier:1.f constant:INVENTORY_ITEM_MARGIN_SPACING]];
    [_inventoryView addConstraint:[NSLayoutConstraint constraintWithItem:_inventoryView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:contentLabel attribute:NSLayoutAttributeTrailing multiplier:1.f constant:INVENTORY_ITEM_MARGIN_SPACING]];
    [_inventoryView addConstraint:[NSLayoutConstraint constraintWithItem:contentLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:flagLabel attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]];
    
    return flagLabel;
}

- (void)lightedValueString:(NSString *)valueString {
    objc_setAssociatedObject(valueString, @selector(isLightString:), @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isLightString:(NSString *)valueString {
    return [objc_getAssociatedObject(valueString, _cmd) boolValue];
}

- (void)valueStringBindingKey:(NSString *)key valueString:(NSString *)valueString {
    objc_setAssociatedObject(valueString, @selector(getBindingKeyWithValueString:), key, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)getBindingKeyWithValueString:(NSString *)valueString {
    return objc_getAssociatedObject(valueString, _cmd);
}

@end
