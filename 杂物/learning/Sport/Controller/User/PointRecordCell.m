//
//  PointRecordCell.m
//  Sport
//
//  Created by haodong  on 14/11/17.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "PointRecordCell.h"
#import "PointRecord.h"

@interface PointRecordCell()
@property (strong, nonatomic) NSDateFormatter *formatter;
@end

@implementation PointRecordCell

+ (NSString*)getCellIdentifier
{
    return @"PointRecordCell";
}

- (void)updateCellWithPointRecord:(PointRecord *)pointRecord
{
    
    self.titleLabel.text = pointRecord.desc;
    
    if (_formatter == nil) {
        self.formatter = [[NSDateFormatter alloc] init] ;
        [_formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    }
    self.timeLabel.text = [_formatter stringFromDate:pointRecord.createDate];
    
    if (pointRecord.type == 1) {
        self.pointLabel.hidden = NO;
        self.pointLabel.text = [NSString stringWithFormat:@"+%d", pointRecord.point];
        self.pointLabel.textColor = [UIColor colorWithRed:106.0/255.0 green:212.0/255.0 blue:73.0/255.0 alpha:1];
    } else if (pointRecord.type == 2) {
        self.pointLabel.hidden = NO;
        self.pointLabel.text = [NSString stringWithFormat:@"-%d", pointRecord.point];
        self.pointLabel.textColor = [SportColor defaultOrangeColor];
    } else {
        self.pointLabel.hidden = YES;
    }
}

@end
