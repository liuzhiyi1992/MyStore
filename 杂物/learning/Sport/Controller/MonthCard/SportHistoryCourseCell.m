//
//  SportHistoryCourseCell.m
//  Sport
//
//  Created by haodong  on 15/6/11.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportHistoryCourseCell.h"

@implementation SportHistoryCourseCell
+ (NSString*)getCellIdentifier{
    return @"SportHistoryCourseCell";
}
+ (id)createCell
{
    SportHistoryCourseCell *cell = [super createCell];
    
     return cell;
}
+ (CGFloat)getCellHeight{
    return 74;
}
- (void)updateCellWithCourse:(MonthCardCourse *)course indexPath:(NSIndexPath *)indexPath{
    NSDate *date = course.startTime;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"M月d日"];
    self.dateLabel.text = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"H:mm"];
    NSString *startTime = [dateFormatter stringFromDate:date];
    date = course.endTime;
    NSString *endTime = [dateFormatter stringFromDate:date];
    self.timeLabel.text = [NSString stringWithFormat:@"%@-%@",startTime,endTime];
    self.typeLabel.text = course.courseName;
    self.venueNameLabel.text = course.venuesName;

}

@end
