//
//  RechargeAmountCell.h
//  Sport
//
//  Created by haodong  on 15/4/14.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@class MembershipCardRechargeGoods;

@interface RechargeAmountCell : DDTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *giftAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;


- (void)updateCellWithGoods:(MembershipCardRechargeGoods *)goods
                 isSelected:(BOOL)isSelected
                  indexPath:(NSIndexPath *)indexPath
                     isLast:(BOOL)isLast;

@end
