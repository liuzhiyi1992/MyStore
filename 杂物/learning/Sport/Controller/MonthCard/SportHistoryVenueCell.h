//
//  SportHistoryVenueCell.h
//  Sport
//
//  Created by haodong  on 15/6/10.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"
#import "Business.h"

@interface SportHistoryVenueCell : DDTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *venueNameLabel;
- (void)updateCellWithBusiness:(Business *)business indexPath:(NSIndexPath *)indexPath;

@end
