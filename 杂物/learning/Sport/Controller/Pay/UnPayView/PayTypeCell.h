//
//  PayTypeCell.h
//  Sport
//
//  Created by haodong  on 15/3/23.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

#import "PayMethod.h"
@interface PayTypeCell : DDTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *radioImageView;
@property (weak, nonatomic) IBOutlet UIImageView *payRecommendImageView;
@property (weak, nonatomic) IBOutlet UIView *advertHolderView;


- (void)updateCellWithPayMethod:(PayMethod *)method
                   isSelected:(BOOL)isSelected
                    indexPath:(NSIndexPath *)indexPath
                       isLast:(BOOL)isLast;

@end
