//
//  CoachCollectionCell.m
//  Sport
//
//  Created by liuzhiyi on 15/9/2.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CoachCollectionCell.h"
#import "UIImageView+WebCache.h"
#import "Coach.h"

@implementation CoachCollectionCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (id)createCell {
    CoachCollectionCell *cell = [super createCell];
    
    //cell背景图片
    cell.backgroundView = [[UIImageView alloc] initWithImage:[[SportImage whiteBackgroundWithGrayLineImage] stretchableImageWithLeftCapWidth:3 topCapHeight:3]];
    
    //适配iphone4
    if([UIScreen mainScreen].bounds.size.height <= 480) {
        for (NSLayoutConstraint *constraint in cell.sizedConstraints) {
            constraint.constant = 0.9 * constraint.constant;
        }
    }
    //圆形imageview
    cell.headImageView.layer.cornerRadius = 0.5 * cell.headImageViewHeightConstraint.constant;
    cell.headImageView.layer.masksToBounds = YES;
    
    return cell;
}

+ (NSString *)getCellIdentifier {
    return @"CoachCollectionCell";
}

+ (CGFloat)getCellHeight {
    return 110.0;
}

- (void)updateCellWithCoach:(Coach *)coach {
    self.nameLabel.text = coach.name;
    self.descLabel.text = coach.introduction;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:coach.avatarUrl]];
    
    if ([coach.gender isEqualToString:@"m"]) {
        [self.genderBackgroundImageView setImage:[UIImage imageNamed:@"male_background_new"]];
    } else if ([coach.gender isEqualToString:@"f"]){
        [self.genderBackgroundImageView setImage:[UIImage imageNamed:@"female_background_new"]];
    }

}

@end
