//
//  SportHistoryVenueCell.m
//  Sport
//
//  Created by haodong  on 15/6/10.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportHistoryVenueCell.h"

@implementation SportHistoryVenueCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+ (NSString*)getCellIdentifier{
    return @"SportHistoryVenueCell";
}
+ (id)createCell
{
    SportHistoryVenueCell *cell = [super createCell];
    
    return cell;
}
+ (CGFloat)getCellHeight{
    return 55;
}
- (void)updateCellWithBusiness:(Business *)business indexPath:(NSIndexPath *)indexPath{
    self.venueNameLabel.text = business.name;
    NSDate *date = business.businessDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"M月d日"];
    self.dateLabel.text = [dateFormatter stringFromDate:date];
}

@end
