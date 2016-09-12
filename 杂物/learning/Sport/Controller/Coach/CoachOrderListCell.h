//
//  CoachOrderListCell.h
//  Sport
//
//  Created by 江彦聪 on 15/5/19.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"
#import "Order.h"

@protocol CoachOrderListCellDelegate <NSObject>

@end

@interface CoachOrderListCell : DDTableViewCell

- (void)updateCell:(Order *)order
         indexPath:(NSIndexPath *)indexPath
            isLast:(BOOL)isLast;

@property (assign,nonatomic) id<CoachOrderListCellDelegate> delegate;
@end
