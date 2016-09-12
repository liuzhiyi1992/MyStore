//
//  MonthCardAssistentFoldCell.h
//  Sport
//
//  Created by 江彦聪 on 15/5/19.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"
#import "MonthCardAssistent.h"

@protocol MonthCardAssistentFoldCellDelegate <NSObject>

-(void)didClickUnfoldButton:(NSIndexPath *)indexPath;
-(void)didClickCourseButtonWithCourse:(MonthCardCourse *)course;
@end

@interface MonthCardAssistentFoldCell : DDTableViewCell

- (void)updateCell:(MonthCardAssistent *)assist
         indexPath:(NSIndexPath *)indexPath
            isLast:(BOOL)isLast;

@property (assign,nonatomic) id<MonthCardAssistentFoldCellDelegate>delegate;
@end
