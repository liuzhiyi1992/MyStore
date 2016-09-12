//
//  SelectGoodsCell.h
//  Sport
//
//  Created by haodong  on 14-8-17.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@interface SelectGoodsCell : DDTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UIImageView *lineImageView;

- (void)updateCellWithValue:(NSString *)value isSelected:(BOOL)isSelected;

@end
