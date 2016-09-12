//
//  SearchResultCell.m
//  Sport
//
//  Created by 冯俊霖 on 15/9/2.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SearchResultCell.h"
#import "Business.h"
#import "UIView+Utils.h"
#import <CoreLocation/CoreLocation.h>
#import "UserManager.h"
#import "PriceUtil.h"
#import "SmallPromoteView.h"
#import "BusinessCategoryManager.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NSString+Utils.h"
#import "CLLocation+Util.h"

@interface SearchResultCell()
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *clubImageView;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailAddressLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lineHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *detailLabelConstraintTop;

@property (strong, nonatomic) Business *business;

@end

@implementation SearchResultCell

+ (id)createCell
{
    SearchResultCell *cell = [super createCell];
    return cell;
}

+ (NSString*)getCellIdentifier
{
    return @"SearchResultCell";
}

+ (CGFloat)getCellHeight
{
    return 100;
}

//- (void)updateCell:(Business *)business
//         indexPath:(NSIndexPath *)indexPath
//            isLast:(BOOL)isLast
//{
//    self.business = business;
//    [self updateCell:business indexPath:indexPath isLast:isLast isShowCategory:NO];
//}

- (void)updateCell:(Business *)business
         indexPath:(NSIndexPath *)indexPath
            isLast:(BOOL)isLast
    isShowCategory:(BOOL)isShowCategory
        searchText:(NSString *)searchText{
    self.lineHeightConstraint.constant = 0.5f;
    
    self.nameLabel.text = business.name;
    
    //判断场馆是否支持动club
    if (business.isSupportClub == 0) {
        self.clubImageView.hidden = YES;
    }else{
        self.clubImageView.hidden = NO;
    }

    
    CLLocation *userLocation = [[UserManager defaultManager] readUserLocation];
    CLLocation *businessLocation = [[CLLocation alloc] initWithLatitude:business.latitude longitude:business.longitude];
    self.distanceLabel.text = [userLocation distanceStringValueFromLocation:businessLocation];

    
    if (business.neighborhood.length > 0) {
        self.addressLabel.hidden = NO;
        self.addressLabel.text = [NSString stringWithFormat:@"[%@]",business.neighborhood];
        self.detailLabelConstraintTop.constant = 35;
    }else{
        self.addressLabel.hidden = YES;
        self.detailLabelConstraintTop.constant = 10;
    }
    
    self.detailAddressLabel.text = [NSString stringWithFormat:@"地址:%@",business.address];
}

@end
