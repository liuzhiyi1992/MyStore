//
//  FacilityCell.h
//  Sport
//
//  Created by haodong  on 15/4/28.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@class Facility;

@interface FacilityCell : DDTableViewCell

- (void)updateCellWithFacility:(Facility *)facility
                     indexPath:(NSIndexPath *)indexPath
                        isLast:(BOOL)isLast;

@end
