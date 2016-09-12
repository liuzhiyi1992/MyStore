//
//  OrderDetailViewSingle.m
//  Sport
//
//  Created by lzy on 16/8/1.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "OrderDetailViewSingle.h"
#import "SportWebController.h"
#import "UIView+Utils.h"
#import "PriceUtil.h"

@interface OrderDetailViewSingle ()
@property (copy, nonatomic) NSString *detailUrlString;
@end
@implementation OrderDetailViewSingle
- (instancetype)initWithGoodsName:(NSString *)goodsName
                       goodsPrice:(double)goodPrice
                            count:(int)count
                        detailUrl:(NSString *)detailUrl {
    self = [super init];
    if (self) {
        _detailUrlString = detailUrl;
        //title
        NSString *countString = (count > 1) ? [NSString stringWithFormat:@"x%d", count] : @"";
        NSString *titleString = [NSString stringWithFormat:@"%@ %@%@", goodsName, [PriceUtil toPriceStringWithYuan:goodPrice], countString];
        [self configureUIWithTitleString:titleString];
    }
    return self;
}

- (void)configureUIWithTitleString:(NSString *)titleString {
    [self setBackgroundColor:[UIColor whiteColor]];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"套餐:";
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = [UIColor hexColor:@"666666"];
    [titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:titleLabel];
    
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.text = titleString;
    contentLabel.font = [UIFont systemFontOfSize:14];
    contentLabel.textColor = [UIColor hexColor:@"222222"];
    [contentLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:contentLabel];
    
    UIImageView *rightImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right"]];
    [rightImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [rightImageView setContentCompressionResistancePriority:850 forAxis:UILayoutConstraintAxisHorizontal];
    [self addSubview:rightImageView];
    
    UIView *hLineView = [[UIView alloc] init];
    [hLineView setBackgroundColor:[UIColor hexColor:@"f5f5f9"]];
    [hLineView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:hLineView];
    
    //Constraints
    NSDictionary *layoutViews = NSDictionaryOfVariableBindings(titleLabel, contentLabel, rightImageView, hLineView);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[titleLabel]-15-[contentLabel]->=15-[rightImageView]-15-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:layoutViews]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[hLineView]|" options:NSLayoutFormatAlignAllBottom metrics:nil views:layoutViews]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.f constant:45.f]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[hLineView(0.5)]|" options:NSLayoutFormatAlignAllBottom metrics:nil views:layoutViews]];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (touches.count == 1) {
        [self handleTouch];
    }
}

- (void)handleTouch {
    SportWebController *controller = [[SportWebController alloc] initWithUrlString:_detailUrlString title:@"套餐详情"];
    UIViewController *sponsorController;
    [self findControllerWithResultController:&sponsorController];
    if (sponsorController) {
        [sponsorController.navigationController pushViewController:controller animated:YES];
    }
    
}

@end
