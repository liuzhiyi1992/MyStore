//
//  OrderDetailPhoneNumberView.m
//  Sport
//
//  Created by lzy on 16/8/1.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "OrderDetailPhoneNumberView.h"
#import "UIView+Utils.h"

NSString const * PLACEHOLDER_STRING = @"手机号码获取错误，请连续客服";
NSInteger const VERIFICATION_STRING_LENGTH = 4;
#define TIPS_STRING @"凭该手机后四位验证"
#define MAIN_FONT_SIZE 14
#define SUB_FONT_SIZE 12

@interface OrderDetailPhoneNumberView ()
@end


@implementation OrderDetailPhoneNumberView
- (instancetype)initWithPhoneNumber:(NSString *)number {
    self = [super init];
    if (self) {
        [self configureView:number];
    }
    return self;
}

- (void)configureView:(NSString *)number {
    [self setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"手机号:";
    titleLabel.textColor = [UIColor hexColor:@"666666"];
    titleLabel.font = [UIFont systemFontOfSize:MAIN_FONT_SIZE];
    [titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:titleLabel];
    
    if (![self verifyingNumber:number]) {
        titleLabel.text = [NSString stringWithFormat:@"%@", PLACEHOLDER_STRING];
        return;
    }
    
    UILabel *numberLabel = [[UILabel alloc] init];
    NSMutableAttributedString *numberAttrString = [[NSMutableAttributedString alloc] initWithString:number];
    [numberAttrString addAttribute:NSForegroundColorAttributeName value:(id)[UIColor hexColor:@"5b73f2"] range:NSMakeRange(number.length - VERIFICATION_STRING_LENGTH, VERIFICATION_STRING_LENGTH)];
    numberLabel.font = [UIFont systemFontOfSize:MAIN_FONT_SIZE];
    numberLabel.attributedText = numberAttrString;
    [numberLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:numberLabel];
    
    UILabel *tipsLabel = [[UILabel alloc] init];
    tipsLabel.text = TIPS_STRING;
    tipsLabel.font = [UIFont systemFontOfSize:SUB_FONT_SIZE];
    tipsLabel.textColor = [UIColor hexColor:@"666666"];
    [tipsLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:tipsLabel];
    
    //VConstraint
    [self addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:numberLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:tipsLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.f constant:45.f]];
    
    //HConstraint
    [self addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.f constant:15.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:numberLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:titleLabel attribute:NSLayoutAttributeTrailing multiplier:1.f constant:15.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:tipsLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.f constant:-15.f]];
}

- (BOOL)verifyingNumber:(NSString *)number {
    if (number.length >= VERIFICATION_STRING_LENGTH) {
        return YES;
    }
    return NO;
}

@end
