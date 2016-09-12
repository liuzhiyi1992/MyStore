//
//  MonthCardAssistentFoldCell.m
//  Sport
//
//  Created by 江彦聪 on 15/5/19.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "MonthCardAssistentFoldCell.h"
#import "DateUtil.h"
#import "NSDate+Utils.h"
#import "UIImageView+WebCache.h"

@interface MonthCardAssistentFoldCell()
@property (strong, nonatomic) MonthCardAssistent* assist;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *venuesNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@end

@implementation MonthCardAssistentFoldCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (NSString *)getCellIdentifier
{
    return @"MonthCardAssistentFoldCell";
}

+ (id)createCell
{
    MonthCardAssistentFoldCell *cell = [super createCell];
    
    return cell;
}

// default
+ (CGFloat)getCellHeight
{
    return 100;
}

- (void)updateCell:(MonthCardAssistent *)assist
         indexPath:(NSIndexPath *)indexPath
            isLast:(BOOL)isLast
{
    self.indexPath = indexPath;
    self.assist = assist;
    UIImage *image = nil;
    if (indexPath.row == 0 && isLast ) {
        image = [SportImage otherCellBackground4Image];
    } else if (indexPath.row == 0) {
        image = [SportImage otherCellBackground1Image];
    } else if (isLast) {
        image = [SportImage otherCellBackground3Image];
    } else {
        image = [SportImage otherCellBackground2Image];
    }
    
    UIImageView *bv = [[UIImageView alloc] initWithImage:image];
    [self setBackgroundView:bv];

    if ([assist.date isToday]) {
        self.dateLabel.text = @"今天";
    } else if ([assist.date isTomorrow]) {
        self.dateLabel.text = @"明天";
    }else {
        self.dateLabel.text = [DateUtil stringFromDate:assist.date DateFormat:@"M月d日"];
    }
    
    self.courseNameLabel.text = assist.course.courseName;
    self.venuesNameLabel.text = assist.venuesName;
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:assist.categoryImageURL] placeholderImage:nil];
    
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        self.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
    
    [self.contentView setNeedsUpdateConstraints];
    [self.contentView updateConstraintsIfNeeded];
}

- (IBAction)clickUnfoldButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickUnfoldButton:)]) {
        [_delegate didClickUnfoldButton:self.indexPath];
    }
}
- (IBAction)clickCourseButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickCourseButtonWithCourse:)]) {
        [_delegate didClickCourseButtonWithCourse:self.assist.course];
    }
}



@end
