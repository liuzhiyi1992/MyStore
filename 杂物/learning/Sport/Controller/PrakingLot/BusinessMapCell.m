//
//  BusinessMapCell.m
//  Sport
//
//  Created by xiaoyang on 16/7/29.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "BusinessMapCell.h"
@interface BusinessMapCell()
@property (weak, nonatomic) IBOutlet UIImageView *informationIcon;
@property (weak, nonatomic) IBOutlet UILabel *informationName;
@property (weak, nonatomic) IBOutlet UILabel *informationContent;


@end
@implementation BusinessMapCell

+ (id)createCell
{
    BusinessMapCell *cell = [super createCell];
    
    return cell;
}

+ (NSString *)getCellIdentifier
{
    return @"BusinessMapCell";
}

- (void)updateCellWithTrafficInfo:(TrafficInfo *)TrafficInfo
{
    if ([TrafficInfo.name isEqualToString:@"停车"]) {
        [self.informationIcon setImage:[UIImage imageNamed:@"ParkIcon"]];
    }else if([TrafficInfo.name isEqualToString:@"公交"]) {
        [self.informationIcon setImage:[UIImage imageNamed:@"BusIcon"]];
    }else if([TrafficInfo.name isEqualToString:@"地铁"]) {
        [self.informationIcon setImage:[UIImage imageNamed:@"SubwayIcon"]];
    }
    
    self.informationName.text = [NSString stringWithFormat:@"%@:",TrafficInfo.name];
    self.informationContent.text = TrafficInfo.content;
}

@end
