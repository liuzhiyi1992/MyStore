//
//  CardSelectedCell.h
//  Sport
//
//  Created by 江彦聪 on 15/11/4.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@interface CardSelectedCell : DDTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *cardNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardBalanceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;
@property (weak, nonatomic) IBOutlet UIImageView *topLineImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cardNumberLabelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingConstrant;

- (void)updateCellWithNumber:(NSString *)cardNumber
                     balance:(NSString *)cardBalance
                  isSelected:(BOOL)isSelected
                   indexPath:(NSIndexPath *)indexPath;

@end
