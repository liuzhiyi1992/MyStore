//
//  CourtJoinInfoCell.m
//  Sport
//
//  Created by 江彦聪 on 16/6/8.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "CourtJoinInfoCell.h"

@interface CourtJoinInfoCell()


@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;

@property (nonatomic, copy) void (^option)();

@end


@implementation CourtJoinInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.arrowImageView.hidden = NO;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSString *)getCellIdentifier
{
    return @"CourtJoinInfoCell";
}

+ (CGFloat)getCellHeight {
    return 45.0;
}

-(void) updateViewWithTitle:(NSString *)title
                     detail:(NSString *)detail
                isShowArrow:(BOOL) isShowArrow {
    self.titleLabel.text = title;
    self.detailLabel.text = detail;
    if(isShowArrow) {
        self.arrowImageView.hidden = NO;
    } else {
        self.arrowImageView.hidden = YES;
    }
}



@end
