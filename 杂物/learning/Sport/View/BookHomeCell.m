//
//  BookHomeCell.m
//  Sport
//
//  Created by haodong  on 14-4-25.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "BookHomeCell.h"
#import "Business.h"
#import "UIImageView+WebCache.h"
#import "UserManager.h"
#import "UIView+Utils.h"
#import "PriceUtil.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+Utils.h"
#import "CLLocation+Util.h"
#import "Order.h"

#define IMAGEVIEWWIDTH  96
#define IMAGEVIEWHEIGHT 72

#define ICON_FIRST_IMAGEVIEW_TAG     20
#define ICON_SECOND_IMAGEVIEW_TAG    30

@interface BookHomeCell()
@property (strong, nonatomic) IBOutlet UIView *detailsView;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *businessImageViewConstraintWidth;
@end

@implementation BookHomeCell

+ (id)createCell
{
    BookHomeCell *cell = [super createCell];

    if (iPhone6Plus) {
        cell.businessImageViewConstraintWidth.constant = cell.businessImageView.bounds.size.width * 1.5;
        
//        [cell.businessImageView updateWidth:cell.businessImageView.bounds.size.width * 1.5];
//        [cell.businessImageView updateHeight:cell.businessImageView.bounds.size.height * 1.5];
//        [cell.detailsView updateOriginX:cell.detailsView.frame.origin.x + IMAGEVIEWWIDTH / 2];
//        [cell.buyButton updateOriginX:cell.buyButton.frame.origin.x - IMAGEVIEWWIDTH / 2];
//        [cell.distanceLabel updateOriginX:cell.distanceLabel.frame.origin.x - IMAGEVIEWWIDTH / 2];
    }
    
//    [cell.buyButton setBackgroundImage:[SportImage orangeFrameButtonImage] forState:UIControlStateNormal];
//    [cell.buyButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateHighlighted];
    
    cell.businessImageView.layer.cornerRadius = 4.0f;
    cell.businessImageView.layer.masksToBounds = YES;
    [cell.detailsView updateCenterY:cell.businessImageView.center.y];
    
    return cell;
}

+ (NSString*)getCellIdentifier
{
    return @"BookHomeCell";
}


+ (CGFloat)getCellHeight
{
    if (iPhone6Plus) {
        return 97.0 + IMAGEVIEWHEIGHT / 2;
    }else{
        return 97.0;
    }
}

- (void)updateCellWithBusiness:(Business *)business
                     indexPath:(NSIndexPath *)indexPath
                        isLast:(BOOL)isLast
{
    self.indexPath = indexPath;
    
    //为保证首页场馆图片有图
    NSString *url = business.smallImageUrl.length > 0?business.smallImageUrl:business.imageUrl;
    [self.businessImageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[SportImage businessDefaultImage] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    }];
    
    self.nameLabel.text = business.name;
    
    if ([business.neighborhood length] > 0) {
        self.neighborhoodLabel.hidden = NO;
        
        self.neighborhoodLabel.text = [NSString stringWithFormat:@"[%@]", business.neighborhood];
        
        CGSize neighborhoodSize = [self.neighborhoodLabel.text sizeWithMyFont:self.neighborhoodLabel.font];
        
        [self.neighborhoodLabel updateWidth:neighborhoodSize.width];
        
    } else {
        self.neighborhoodLabel.hidden = YES;
    }
    
    CLLocation *userLocation = [[UserManager defaultManager] readUserLocation];
    CLLocation *businessLocation = [[CLLocation alloc] initWithLatitude:business.latitude longitude:business.longitude];
    self.distanceLabel.text = [userLocation distanceStringValueFromLocation:businessLocation];

    self.buyButton.hidden = NO;
    BOOL canOrder = [business canOrder];
    if (canOrder && business.orderType == OrderTypeDefault) {
        [self.buyButton setTitle:@"预订" forState:UIControlStateNormal];
    } else {
        [self.buyButton setTitle:@"查看" forState:UIControlStateNormal];
    }
    
    //如果有折后价，则显示折后价和原价
    if (business.promotePrice > 0) {
        _oldPriceHolderView.hidden = NO;
        _priceLabel.hidden = NO;
        
        _priceLabel.text = [NSString stringWithFormat:@"￥%@", [PriceUtil toValidPriceString:business.promotePrice]];
        _oldPriceLabel.text = [NSString stringWithFormat:@"￥%@", [PriceUtil toValidPriceString:business.price]];
        
    } else {
        
        if (business.price > 0) {//如果没有折后价，有原价则只显示原价
            _oldPriceHolderView.hidden = YES;
            _priceLabel.hidden = NO;

            _priceLabel.text = [NSString stringWithFormat:@"￥%@", [PriceUtil toValidPriceString:business.price]];
        } else {//如果没有折后价，没有原价则什么都不显示
            _oldPriceHolderView.hidden = YES;
            _priceLabel.hidden = YES;
        }
    }
    
    
    //设置可退款/常去球馆小图标
    UIView *vflRightView = self.nameLabel;//动态添加的icon的右边的控件
    
    UIImageView *firstImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RefundImage"]];
    UIImageView *secondImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"OftenImage"]];
    NSDictionary *viewDict = NSDictionaryOfVariableBindings(firstImageView, secondImageView, vflRightView);
    [firstImageView setTag:ICON_FIRST_IMAGEVIEW_TAG];
    [secondImageView setTag:ICON_SECOND_IMAGEVIEW_TAG];
    
    if([self.detailsView viewWithTag:ICON_FIRST_IMAGEVIEW_TAG] != nil) {
        [[self.detailsView viewWithTag:ICON_FIRST_IMAGEVIEW_TAG] removeFromSuperview];
    }
    if([self.detailsView viewWithTag:ICON_SECOND_IMAGEVIEW_TAG] != nil) {
        [[self.detailsView viewWithTag:ICON_SECOND_IMAGEVIEW_TAG] removeFromSuperview];
    }
    
    firstImageView.translatesAutoresizingMaskIntoConstraints = NO;
    secondImageView.translatesAutoresizingMaskIntoConstraints = NO;
    vflRightView.translatesAutoresizingMaskIntoConstraints = NO;
    
    if(business.canRefund) {//可退款
        if(business.isOften) {//且常去
            //执行
            [self.detailsView addSubview:firstImageView];
            [self.detailsView addSubview:secondImageView];
            
            [self.detailsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[firstImageView(13)]-5-[secondImageView(13)]-5-[vflRightView]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDict]];
            [self.detailsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[firstImageView(13)]" options:0 metrics:nil views:viewDict]];
            [self.detailsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[secondImageView(13)]" options:0 metrics:nil views:viewDict]];
        }else {//非常去
            //执行
            [self.detailsView addSubview:firstImageView];
            
            [self.detailsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[firstImageView(13)]-5-[vflRightView]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDict]];
            [self.detailsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[firstImageView(13)]" options:0 metrics:nil views:viewDict]];
        }
    }else if(business.isOften) {//只有常去
        //执行
        [self.detailsView addSubview:secondImageView];
        
        [self.detailsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[secondImageView(13)]-5-[vflRightView]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDict]];
        [self.detailsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[secondImageView(13)]" options:0 metrics:nil views:viewDict]];
    }
    
    
    //设置常去图标
//    if(business.isOften) {
//        self.oftenImageView.hidden = NO;
//        if (self.oftenImageView.image == nil) {
//            self.oftenImageView.image = [UIImage imageNamed:@"OftenImage"];
//        }
//        self.labelLeadingConstraint.constant = 18;
//        [self.nameLabel updateOriginX:self.oftenImageView.frame.origin.x + self.oftenImageView.frame.size.width + 5];
//    } else{
//        self.oftenImageView.hidden = YES;
//        self.labelLeadingConstraint.constant = 0;
//        [self.nameLabel updateOriginX:0];
//    }
}

- (IBAction)clickBuyButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickBookHomeCellBuyButton:)]) {
        [_delegate didClickBookHomeCellBuyButton:_indexPath];
    }
}

@end
