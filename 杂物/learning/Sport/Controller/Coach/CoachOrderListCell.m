//
//  CoachOrderListCell.m
//  Sport
//
//  Created by 江彦聪 on 15/5/19.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CoachOrderListCell.h"
#import "UIImageView+WebCache.h"
#import "DateUtil.h"
#import "UIColor+HexColor.h"

@interface CoachOrderListCell()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (strong, nonatomic) Order* order;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UIImageView *genderImage;
@property (weak, nonatomic) IBOutlet UILabel *timePeriodlabel;
@property (weak, nonatomic) IBOutlet UILabel *orderStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@end

@implementation CoachOrderListCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (NSString *)getCellIdentifier
{
    return @"CoachOrderListCell";
}

- (void) awakeFromNib
{
    self.avatarImage.layer.cornerRadius = self.avatarImage.frame.size.width/2;
    self.avatarImage.layer.masksToBounds = YES;
    self.avatarImage.layer.borderColor = [[UIColor hexColor:@"e1e1e1"] CGColor];
    self.avatarImage.layer.borderWidth = 1.0f;
    self.avatarImage.contentMode = UIViewContentModeScaleAspectFill;
    self.avatarImage.clipsToBounds = YES;
}

- (void)updateCell:(Order *)order
         indexPath:(NSIndexPath *)indexPath
            isLast:(BOOL)isLast
{
    self.indexPath = indexPath;
    self.order = order;
    UIImage *image = [SportImage otherCellBackground4Image];
    
    UIImageView *bv = [[UIImageView alloc] initWithImage:image];
    [self setBackgroundView:bv];
    
    [self.avatarImage sd_setImageWithURL:[NSURL URLWithString:order.coachAvatarUrl] placeholderImage:[SportImage monthCardDefaultAvatar]];
    
    if ([order.coachGender isEqualToString:GENDER_MALE]) {
        [self.genderImage setImage:[SportImage genderMaleImage]];
    } else {
        [self.genderImage setImage:[SportImage genderFemaleImage]];
    }
    
    self.nameLabel.text = order.coachName;
    
    NSDate *endTime = [NSDate dateWithTimeIntervalSince1970:order.coachStartTime.timeIntervalSince1970 + order.coachDuration*60];
    
    NSString *startTimeString = [DateUtil stringFromDate:order.coachStartTime DateFormat:@"yyyy年MM月dd日 HH:mm-"];
    
    self.timePeriodlabel.text = [startTimeString stringByAppendingString:[DateUtil stringFromDate:endTime DateFormat:@"HH:mm"]];
    
    self.orderStatusLabel.text = [order coachOrderStatusText];
    self.orderStatusLabel.textColor = [order coachOrderStatusTextColor];
    
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        self.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
    
    [self.contentView setNeedsUpdateConstraints];
    [self.contentView updateConstraintsIfNeeded];
    
}

@end
