//
//  BusinessMapCell.h
//  Sport
//
//  Created by xiaoyang on 16/7/29.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"
#import "TrafficInfo.h"

@interface BusinessMapCell : DDTableViewCell
+ (id)createCell;
+ (NSString *)getCellIdentifier;
- (void)updateCellWithTrafficInfo:(TrafficInfo *)TrafficInfo;
@end
