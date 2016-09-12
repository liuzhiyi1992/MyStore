//
//  PlayedBusinessCell.m
//  Sport
//
//  Created by haodong  on 14/11/7.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "PlayedBusinessCell.h"
#import "Business.h"

@interface PlayedBusinessCell()
@property (strong, nonatomic) Business *business;
@end

@implementation PlayedBusinessCell

+ (NSString*)getCellIdentifier
{
    return @"PlayedBusinessCell";
}

+ (id)createCell
{
    PlayedBusinessCell *cell = [super createCell];
    [cell.lineImageView setImage:[SportImage lineImage]];
    return cell;
}

+ (CGFloat)getCellHeight
{
    return 59.0;
}

- (void)updateCellWithBusiness:(Business *)business
{
    self.business = business;
    
    self.businessNameLabel.text = business.name;
    
    if (business.neighborhood) {
        self.neighborhoodLabel.text = [NSString stringWithFormat:@"【%@】", business.neighborhood];
    } else {
        self.neighborhoodLabel.text = @"";
    }
    
    self.playHourCountLabel.text = [NSString stringWithFormat:@"累计%d小时", business.playHourCount];
}

- (IBAction)clickSelectButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickPlayedBusinessCellSelectButton:)]) {
        [_delegate didClickPlayedBusinessCellSelectButton:_business];
    }
}

@end
