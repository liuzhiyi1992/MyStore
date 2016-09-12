//
//  CourtJoinListCell.m
//  Sport
//
//  Created by xiaoyang on 16/5/20.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "CourtJoinListCell.h"
#import "UIImageView+WebCache.h"
#import "DateUtil.h"
#import "PriceUtil.h"


@implementation CourtJoinListCell

+ (id)createCell
{
    CourtJoinListCell *cell = [super createCell];
    cell.nicknameImageView.layer.cornerRadius = 25.0;
    cell.nicknameImageView.layer.masksToBounds = YES;
    [cell.nicknameImageView setContentMode:UIViewContentModeScaleAspectFill];
    [cell.detailButton setBackgroundImage:[[UIImage imageNamed:@"DetailBackground"] stretchableImageWithLeftCapWidth:12 topCapHeight:0] forState:UIControlStateNormal];
    return cell;
}

+ (NSString*)getCellIdentifier {
    
    return @"CourtJoinListCell";
}
- (void)updateCellWithCourtJoin:(CourtJoin *)courtJoin indexPath:(NSIndexPath *)indexPath{
    
        self.indexPath = indexPath;
        if (courtJoin.leftJoinNumber == 0) {
           self.canJoinNumberLabel.text = @"已加满";
        } else {
            self.canJoinNumberLabel.text = [NSString stringWithFormat:@"还可加入%d人",courtJoin.leftJoinNumber];
        }
    
        self.nicknameLabel.text = courtJoin.nickName;
        //如果URL为空，传nil进去防止闪退
        NSURL *url = (courtJoin.avatarUrl ? [NSURL URLWithString:courtJoin.avatarUrl] : nil);
        [self.nicknameImageView sd_setImageWithURL:url placeholderImage:[SportImage avatarDefaultImage]];
    
        //去除掉首尾的空白字符和换行字符
        courtJoin.joinDescription = [courtJoin.joinDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
       courtJoin.joinDescription = [courtJoin.joinDescription stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
        courtJoin.joinDescription = [courtJoin.joinDescription stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        self.introduceLabel.text = courtJoin.joinDescription;
    
        self.pricePerPeason.text = [NSString stringWithFormat:@"%@元/每人",[PriceUtil toValidPriceString:courtJoin.price]];
    
        if ([courtJoin.gender length] == 0) {
            self.genderImageView.hidden = YES;
        }else {
            self.genderImageView.hidden = NO;
            
            UIImage *genderImage = [SportImage genderImageWithGender:courtJoin.gender];
            [self.genderImageView setImage:genderImage];
        }
    
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        NSString *startTimeString = [formatter stringFromDate:courtJoin.startTime];
        NSString *endTimeString = [formatter stringFromDate:courtJoin.endTime];
        self.businessNameLabel.text = courtJoin.businessName;
        if ([courtJoin.continuous isEqualToString:@"0"]) {
            self.hourLabel.text = [NSString stringWithFormat:@"从%@开始",startTimeString];

        }else {
            self.hourLabel.text = [NSString stringWithFormat:@"%@-%@",startTimeString,endTimeString];

        }
        self.timeLabel.text =[DateUtil todayAndOtherWeekStringNoBracket:courtJoin.bookDate];
}
- (IBAction)clickDetailButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickDetailButton:)]) {
        [_delegate didClickDetailButton:_indexPath];
    }
}
- (IBAction)clickNickNameButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickNickNameButton:)]) {
        [_delegate didClickNickNameButton:_indexPath];
    }
}

@end
