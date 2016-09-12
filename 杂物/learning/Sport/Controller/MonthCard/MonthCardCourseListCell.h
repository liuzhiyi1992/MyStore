//
//  MonthCardCourseListCell.h
//  Sport
//
//  Created by 江彦聪 on 15/5/19.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"
#import "MonthCardCourse.h"

@interface MonthCardCourseListCell : DDTableViewCell

- (void)updateCell:(MonthCardCourse *)course
         indexPath:(NSIndexPath *)indexPath
            isLast:(BOOL)isLast;
@end
