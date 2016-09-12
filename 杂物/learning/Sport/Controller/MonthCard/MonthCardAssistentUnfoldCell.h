//
//  MonthCardAssistentUnfoldCell.h
//  Sport
//
//  Created by 江彦聪 on 15/5/19.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"
#import "MonthCardAssistent.h"

@protocol MonthCardAssistentUnfoldCellDelegate <NSObject>

-(void)didClickCourseButtonWithCourse:(MonthCardCourse *)course;
-(void)didClickAddressButtonWithLatitude:(double)latitude
                               longitude:(double)longitude
                            businessName:(NSString *)businessName
                         businessAddress:(NSString *)businessAddress;

@end

@interface MonthCardAssistentUnfoldCell : DDTableViewCell

- (void)updateCell:(MonthCardAssistent *)assist
         indexPath:(NSIndexPath *)indexPath
            isLast:(BOOL)isLast;

@property (assign,nonatomic) id<MonthCardAssistentUnfoldCellDelegate> delegate;
@end
