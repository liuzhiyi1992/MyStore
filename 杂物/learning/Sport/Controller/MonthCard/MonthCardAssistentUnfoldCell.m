//
//  MonthCardAssistentUnfoldCell.m
//  Sport
//
//  Created by 江彦聪 on 15/5/19.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "MonthCardAssistentUnfoldCell.h"
#import "DateUtil.h"
#import "UIImageView+WebCache.h"
#import "NSDate+Utils.h"
#import "UIUtils.h"
#import "SportPopupView.h"

@interface MonthCardAssistentUnfoldCell()
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *venuesNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *noticeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (strong, nonatomic) MonthCardAssistent *assist;

@end

@implementation MonthCardAssistentUnfoldCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (NSString *)getCellIdentifier
{
    return @"MonthCardAssistentUnfoldCell";
}

+ (id)createCell
{
    MonthCardAssistentUnfoldCell *cell = [super createCell];
    
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
    } else {
        self.dateLabel.text = [DateUtil stringFromDate:assist.date DateFormat:@"M月d日"];
    }
    
    self.startTimeLabel.text = [DateUtil stringFromDate:assist.course.startTime DateFormat:@"HH:mm"];
    self.endTimeLabel.text = [DateUtil stringFromDate:assist.course.endTime DateFormat:@"HH:mm"];
    
    self.courseNameLabel.text = assist.course.courseName;
    self.venuesNameLabel.text = assist.venuesName;
    self.noticeLabel.text = assist.notice;
    self.addressLabel.text = assist.address;
    self.phoneLabel.text = assist.phone;
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:assist.categoryImageURL] placeholderImage:nil];
    
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        self.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
    
    [self.contentView setNeedsUpdateConstraints];
    [self.contentView updateConstraintsIfNeeded];
    
}
- (IBAction)clickAddressButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickAddressButtonWithLatitude:longitude:businessName:businessAddress:)]) {
        [_delegate didClickAddressButtonWithLatitude:self.assist.latitude longitude:self.assist.longitude businessName:self.assist.venuesName businessAddress:self.assist.address];
    }
}

- (IBAction)clickCourseButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickCourseButtonWithCourse:)]) {
        [_delegate didClickCourseButtonWithCourse:self.assist.course];
    }
}

- (IBAction)clickPhoneButton:(id)sender {
   [MobClickUtils event:umeng_event_month_sports_assistant_click_phone];
    BOOL result = [UIUtils makePromptCall:self.assist.phone];
    if (result == NO) {
        [SportPopupView popupWithMessage:@"此设备不支持打电话"];
    }
}

@end
