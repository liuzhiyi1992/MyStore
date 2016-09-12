//
//  RefundCauseCell.h
//  Sport
//
//  Created by haodong  on 15/3/13.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@interface RefundCauseCell : DDTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *causeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;

- (void)updateCellWithCause:(NSString *)cause
                 isSelected:(BOOL)isSelected
                  indexPath:(NSIndexPath *)indexPath
                     isLast:(BOOL)isLast;

@end
