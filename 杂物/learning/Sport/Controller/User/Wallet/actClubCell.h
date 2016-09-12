//
//  actClubCell.h
//  Sport
//
//  Created by 冯俊霖 on 15/8/10.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@protocol actClubCellDelegate <NSObject>
@optional
- (void)didClickactClubCell;
@end

@interface actClubCell : DDTableViewCell
@property (assign, nonatomic) id<actClubCellDelegate> delegate;

- (void)updateUserClubStatus:(int)userClubStatus usableDays:(NSString *)usableDays;

@end
