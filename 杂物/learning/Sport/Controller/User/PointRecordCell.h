//
//  PointRecordCell.h
//  Sport
//
//  Created by haodong  on 14/11/17.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@class PointRecord;

@interface PointRecordCell : DDTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointLabel;

- (void)updateCellWithPointRecord:(PointRecord *)pointRecord;

@end
