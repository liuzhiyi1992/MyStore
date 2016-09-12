//
//  MonthCardCourseListCell.m
//  Sport
//
//  Created by 江彦聪 on 15/5/19.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "MonthCardCourseListCell.h"
#import "DateUtil.h"
#import "UIImageView+WebCache.h"

@interface MonthCardCourseListCell()
@property (strong, nonatomic) MonthCardCourse* course;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMarginHeightConstraint;

@property (strong, nonatomic) NSIndexPath *indexPath;
@end

@implementation MonthCardCourseListCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (NSString *)getCellIdentifier
{
    return @"MonthCardCourseListCell";
}

+ (id)createCell
{
    MonthCardCourseListCell *cell = [super createCell];

    return cell;
}

// default
+ (CGFloat)getCellHeight
{
    return 100;
}


- (void)updateCell:(MonthCardCourse *)course
         indexPath:(NSIndexPath *)indexPath
            isLast:(BOOL)isLast
{
    self.indexPath = indexPath;
    
    if (isLast) {
        self.bottomMarginHeightConstraint.constant = 0;
    } else {
        self.bottomMarginHeightConstraint.constant = 10;
    }
    
    //self.backgroundImageView
    [self.backgroundImageView sd_setImageWithURL:[NSURL URLWithString:course.imageUrl] placeholderImage:[SportImage defaultImage_300x155]];
    [self.backgroundImageView setClipsToBounds:YES];
    [self.backgroundImageView setContentMode:UIViewContentModeScaleAspectFill];
    
    self.nameLabel.text = course.courseName;
    self.addressLabel.text = course.venuesName;
    NSString *startTimeString = [DateUtil stringFromDate:course.startTime DateFormat:@"MM/dd HH:mm"];
    NSString *endTimeString = [DateUtil stringFromDate:course.endTime DateFormat:@"HH:mm"];
    self.timeLabel.text = [NSString stringWithFormat:@"%@-%@",startTimeString,endTimeString];
    
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        self.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
    
    [self.contentView setNeedsUpdateConstraints];
    [self.contentView updateConstraintsIfNeeded];
    
}

@end
