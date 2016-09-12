//
//  AMapSearchAddressCell.m
//  Sport
//
//  Created by 江彦聪 on 15/10/17.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import "AMapSearchAddressCell.h"

@interface AMapSearchAddressCell()
@property (strong, nonatomic) NSIndexPath *indexPath;
@end

@implementation AMapSearchAddressCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (CGFloat) getCellHeight {
    return 60;
}

+ (NSString *)getCellIdentifier
{
    return @"AMapSearchAddressCell";
}

- (void)updateCellWithTitle:(NSString *)title
                   subTitle:(NSString *)subTitle
                  indexPath:(NSIndexPath *)indexPath
                     isLast:(BOOL)isLast
{
    self.indexPath = indexPath;
    UIImage *image = nil;
    if (indexPath.section == 0 && indexPath.row == 0 && isLast ) {
        image = [SportImage otherCellBackground4Image];
    } else if (indexPath.section == 0 && indexPath.row == 0) {
        image = [SportImage otherCellBackground1Image];
    } else if (isLast) {
        image = [SportImage otherCellBackground3Image];
    } else {
        image = [SportImage otherCellBackground2Image];
    }
    
    UIImageView *bv = [[UIImageView alloc] initWithImage:image];
    [self setBackgroundView:bv];
    
    self.titleLabel.text = title;
    self.subTitleLabel.text = subTitle;
    
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        self.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
    
    [self.contentView setNeedsUpdateConstraints];
    [self.contentView updateConstraintsIfNeeded];
}


@end
