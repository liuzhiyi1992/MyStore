//
//  SportUnpaidAlertViewCell.m
//  Sport
//
//  Created by 江彦聪 on 8/18/16.
//  Copyright © 2016 haodong . All rights reserved.
//

#import "SportUnpaidAlertViewCell.h"
@interface SportUnpaidAlertViewCell()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailLabelHeight;

@end
@implementation SportUnpaidAlertViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSString *)getCellIdentifier
{
    return @"SportUnpaidAlertViewCell";
}

+ (CGFloat)getCellHeight {
    return 30.0;
}

-(void) updateViewWithTitle:(NSString *)title
                     detail:(NSString *)detail {
    self.titleLabel.text = title;
    
    self.detailLabel.text = detail;
    
//    CGSize labelSize = [self.detailLabel.text boundingRectWithSize:CGSizeMake(self.detailLabel.bounds.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.detailLabel.font} context:nil].size;
//    
//    self.detailLabelHeight.constant = labelSize.height;
    
}

@end
