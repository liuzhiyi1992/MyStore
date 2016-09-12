//
//  PayTypeCell.m
//  Sport
//
//  Created by haodong  on 15/3/23.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "PayTypeCell.h"
#import "BaseConfigManager.h"
#import "UIView+Utils.h"
@implementation PayTypeCell


+ (NSString *)getCellIdentifier
{
    return @"PayTypeCell";
}

+ (CGFloat)getCellHeight
{
    return 47;
}

+ (id)createCell
{
    PayTypeCell *cell = [super createCell];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)updateCellWithPayMethod:(PayMethod *)method
                   isSelected:(BOOL)isSelected
                    indexPath:(NSIndexPath *)indexPath
                       isLast:(BOOL)isLast
{
    UIImage *bgImage = nil;
    if (indexPath.row == 0 && isLast ) {
        bgImage = [SportImage otherCellBackground4Image];
    } else if (indexPath.row == 0) {
        bgImage = [SportImage otherCellBackground1Image];
    } else if (isLast) {
        bgImage = [SportImage otherCellBackground3Image];
    } else {
        bgImage = [SportImage otherCellBackground2Image];
    }
    UIImageView *bv = [[UIImageView alloc] initWithImage:bgImage] ;
    [self setBackgroundView:bv];
    
    NSString *type = method.payKey;
    if ([type isEqualToString:PAY_METHOD_ALIPAY_CLIENT]) {
        self.iconImageView.image = [SportImage alipayImage];
        //只显示支付宝  2016-05-18
        self.nameLabel.text = @"支付宝";
    } else if ([type isEqualToString:PAY_METHOD_ALIPAY_WAP]) {
        self.iconImageView.image = [SportImage alipayImage];
        self.nameLabel.text = @"支付宝网页支付";
    } else if ([type isEqualToString:PAY_METHOD_WEIXIN]) {
        self.iconImageView.image = [SportImage wechatpayImage];
        self.nameLabel.text = @"微信支付";
    } else if ([type isEqualToString:PAY_METHOD_UNION_CLIENT]) {
        self.iconImageView.image = [SportImage unionpayImage];
        self.nameLabel.text = @"银联支付";
    } else if ([type isEqualToString:PAY_METHOD_APPLE_PAY]) {
        self.iconImageView.image = [SportImage applePayImage];
        self.nameLabel.text = @"Apple Pay";
        [self configureApplePayFollowIcon];
    } else {
        self.iconImageView.image = nil;
        self.nameLabel.text = nil;
    }
    
    UIImage *image = nil;
    if (isSelected) {
         image = [SportImage radioButtonSelectedImage];
    } else {
        image = [SportImage radioButtonUnselectedImage];
    }
    self.radioImageView.image = image;
    
    self.payRecommendImageView.hidden = !method.isRecommend;
}

- (void)configureApplePayFollowIcon {
    UIImageView *quickPassImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unionPay_quickPass"]];
    UIImageView *unionIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unionPay_applePay_follow"]];
    [quickPassImageView setContentMode:UIViewContentModeScaleAspectFit];
    [unionIconImageView setContentMode:UIViewContentModeScaleAspectFit];
    
    NSDictionary *views = @{@"quickPass":quickPassImageView, @"unionIcon":unionIconImageView, @"advertHolderView":_advertHolderView};
    [quickPassImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [unionIconImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.advertHolderView addSubview:quickPassImageView];
    [self.advertHolderView addSubview:unionIconImageView];
    [self.advertHolderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[quickPass]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    [self.advertHolderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[unionIcon]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    
    [self.advertHolderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[unionIcon(39)]-5-[quickPass(39)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
}

@end
