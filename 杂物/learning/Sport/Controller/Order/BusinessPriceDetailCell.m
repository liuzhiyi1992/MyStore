//
//  BusinessPriceDetailCell.m
//  Sport
//
//  Created by 江彦聪 on 8/8/16.
//  Copyright © 2016 haodong . All rights reserved.
//

#import "BusinessPriceDetailCell.h"
@interface BusinessPriceDetailCell()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contendLabel;


@end
@implementation BusinessPriceDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)getCellHeight
{
    return 35;
}

+ (NSString *)getCellIdentifier
{
    return @"BusinessPriceDetailCell";
}

-(void) updateWithNameContendArray:(NSArray *)array {
    if ([array count] >= 2) {
        self.nameLabel.text = array[0];
        self.contendLabel.text = array[1];
    }
}

@end
