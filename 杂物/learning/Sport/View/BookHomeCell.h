//
//  BookHomeCell.h
//  Sport
//
//  Created by haodong  on 14-4-25.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@protocol BookHomeCellDelegate <NSObject>
@optional
- (void)didClickBookHomeCellBuyButton:(NSIndexPath *)indexPath;
@end

@class Business;

@interface BookHomeCell : DDTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *businessImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@property (weak, nonatomic) IBOutlet UIButton *buyButton;

@property (weak, nonatomic) IBOutlet UILabel *neighborhoodLabel;

@property (weak, nonatomic) IBOutlet UIView *oldPriceHolderView;
@property (weak, nonatomic) IBOutlet UILabel *oldPriceLabel;

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (assign, nonatomic) id<BookHomeCellDelegate> delegate;

- (void)updateCellWithBusiness:(Business *)business indexPath:(NSIndexPath *)indexPath isLast:(BOOL)isLast;

@end
