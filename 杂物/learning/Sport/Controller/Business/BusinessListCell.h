//
//  BusinessListCell.h
//  Sport
//
//  Created by haodong  on 13-6-20.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@class Business;

@interface BusinessListCell : DDTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *oftenImageView;
@property (weak, nonatomic) IBOutlet UIImageView *refundImageView;
@property (strong, nonatomic) IBOutlet UIImageView *clubImageView;

@property (weak, nonatomic) IBOutlet UIView *priceHolderView;
@property (weak, nonatomic) IBOutlet UILabel *latestPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *oldPriceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *oldPriceLineImageView;

@property (weak, nonatomic) IBOutlet UILabel *neighborhoodLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

- (void)updateCell:(Business *)business
         indexPath:(NSIndexPath *)indexPath
            isLast:(BOOL)isLast;

- (void)updateCell:(Business *)business
         indexPath:(NSIndexPath *)indexPath
            isLast:(BOOL)isLast
    isShowCategory:(BOOL)isShowCategory;

+ (CGFloat)getCellHeightWithBusiness:(Business *)business;

@end
