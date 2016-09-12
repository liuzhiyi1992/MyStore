//
//  PointCell.h
//  Sport
//
//  Created by haodong  on 15/3/19.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@protocol PointCellDelegate <NSObject>
@optional
- (void)didClickPointCell;

@end

@interface PointCell : DDTableViewCell

@property (assign, nonatomic) id<PointCellDelegate> delegate;

- (void)updatePoint:(int)point;

@end
