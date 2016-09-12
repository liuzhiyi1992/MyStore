//
//  CoachDetailCell.m
//  Sport
//
//  Created by 江彦聪 on 15/5/19.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "CoachDetailCell.h"
#import "UIImageView+WebCache.h"
#import "DateUtil.h"
#import "UIColor+HexColor.h"

@interface CoachDetailCell()
@property (weak, nonatomic) IBOutlet UILabel *itemLabel;

@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@end

@implementation CoachDetailCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (NSString *)getCellIdentifier
{
    return @"CoachDetailCell";
}

- (void) awakeFromNib
{

}

- (void)updateCellWithTitle:(NSString *)title
                    content:(NSString *)content
                  indexPath:(NSIndexPath *)indexPath
                     isLast:(BOOL)isLast
               contentColor:(UIColor *)contentColor
{
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
    
    self.itemLabel.text = title;
    self.contentTextView.text = content;
    
    if (contentColor) {
        self.contentTextView.textColor = contentColor;
    } else {
        self.contentTextView.textColor = [UIColor hexColor:@"222222"];
    }
    
    //workaround for IOS 7 auto layout bug
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        self.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
    }
    
    [self.contentView setNeedsUpdateConstraints];
    [self.contentView updateConstraintsIfNeeded];
}

@end
