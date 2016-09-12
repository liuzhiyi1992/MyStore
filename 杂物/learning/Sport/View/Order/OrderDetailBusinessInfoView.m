//
//  OrderDetailBusinessInfoView.m
//  Sport
//
//  Created by lzy on 16/8/1.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "OrderDetailBusinessInfoView.h"
#import "UIUtils.h"
#import "SportPopupView.h"
#import "BusinessDetailController.h"
#import "Order.h"
#import "UIView+Utils.h"
#import "UIView+ExtendTouchArea.h"

#define MAIN_FONT_SIZE 14
#define SUB_FONT_SIZE 12
#define MAIN_TEXT_COLOR [UIColor hexColor:@"222222"]
#define SUB_TEXT_COLOR [UIColor hexColor:@"666666"]
#define LABEL_V_MARGIN 9

@interface OrderDetailBusinessInfoView ()
@property (strong, nonatomic) Order *order;
@end

@implementation OrderDetailBusinessInfoView
- (instancetype)initWithOrder:(Order *)order {
    self = [super init];
    if (self) {
        _order = order;
        [self configureUI];
    }
    return self;
}

- (void)configureUI {
    [self setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.textColor = MAIN_TEXT_COLOR;
    nameLabel.font = [UIFont systemFontOfSize:MAIN_FONT_SIZE];
    nameLabel.text = _order.businessName;
    [nameLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
    [nameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:nameLabel];
    
    UILabel *addressLabel = [[UILabel alloc] init];
    addressLabel.textColor = SUB_TEXT_COLOR;
    addressLabel.font = [UIFont systemFontOfSize:SUB_FONT_SIZE];
    addressLabel.text = _order.businessAddress;
    [addressLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [addressLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:addressLabel];
    
    UIImageView *callPhoneImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MyCellPhoneIcon"]];
    [callPhoneImageView setTouchExtendInset:UIEdgeInsetsMake(-20, -20, -20, -20)];
    [callPhoneImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callPhone)]];
    [callPhoneImageView setUserInteractionEnabled:YES];
    [callPhoneImageView setContentCompressionResistancePriority:850 forAxis:UILayoutConstraintAxisHorizontal];
    [callPhoneImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:callPhoneImageView];
    
    UIView *vLineView = [[UIView alloc] init];
    [vLineView setBackgroundColor:[UIColor hexColor:@"f5f5f9"]];
    [vLineView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:vLineView];
    
    //hConstraints
    [self addConstraint:[NSLayoutConstraint constraintWithItem:nameLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.f constant:15.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:addressLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.f constant:15.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:callPhoneImageView attribute:NSLayoutAttributeTrailing multiplier:1.f constant:15.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:callPhoneImageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:vLineView attribute:NSLayoutAttributeTrailing multiplier:1.f constant:15.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:vLineView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.f constant:1.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:vLineView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nameLabel attribute:NSLayoutAttributeTrailing multiplier:1.f constant:15.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:vLineView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:addressLabel attribute:NSLayoutAttributeTrailing multiplier:1.f constant:15.f]];
    
    //vConstraints
    [self addConstraint:[NSLayoutConstraint constraintWithItem:nameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.f constant:LABEL_V_MARGIN]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:addressLabel attribute:NSLayoutAttributeBottom multiplier:1.f constant:LABEL_V_MARGIN]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:callPhoneImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:1.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:vLineView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:1.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:vLineView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.f constant:25.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.f constant:55.f]];
}

- (void)callPhone {
    BOOL result = [UIUtils makePromptCall:_order.businessPhone];
    if (result == NO) {
        [SportPopupView popupWithMessage:@"此设备不支持打电话"];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (touches.count == 1) {
        [MobClickUtils event:umeng_event_order_detail_click_business];
        BusinessDetailController *controller = [[BusinessDetailController alloc] initWithBusinessId:_order.businessId categoryId:_order.categoryId];
        UIViewController *sponsorController;
        [self findControllerWithResultController:&sponsorController];
        if (sponsorController) {
            [sponsorController.navigationController pushViewController:controller animated:YES];
        }
    }
}

@end
