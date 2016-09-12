//
//  MyPointCell.h
//  Sport
//
//  Created by haodong  on 14/11/13.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@class PointGoods;

@interface MyPointCell : DDTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *goodsImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointLabel;

@property (weak, nonatomic) IBOutlet UIView *originalPointHolderView;

@property (weak, nonatomic) IBOutlet UILabel *originalPointLabel;
@property (weak, nonatomic) IBOutlet UIView *originalPointLineView;
@property (weak, nonatomic) IBOutlet UILabel *joinTimesLabel;
@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lineViewConstraintHeight;

- (void)updateCellWithPointGoods:(PointGoods *)pointGoods
                       indexPath:(NSIndexPath *)indexPath
                          isLast:(BOOL)isLast;

@end
