//
//  SportHistoryCourseCell.h
//  Sport
//
//  Created by haodong  on 15/6/11.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"
#import "MonthCardCourse.h"

@interface SportHistoryCourseCell : DDTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *venueNameLabel;
- (void)updateCellWithCourse:(MonthCardCourse *)course indexPath:(NSIndexPath *)indexPath;
@end
