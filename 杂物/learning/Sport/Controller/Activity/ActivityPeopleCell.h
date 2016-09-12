//
//  ActivityPeopleCell.h
//  Sport
//
//  Created by haodong  on 14-3-17.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@protocol ActivityPeopleCellDelegate <NSObject>
@optional
- (void)didClickAgreeButton:(NSIndexPath *)indexPath;
- (void)didClickRejectButton:(NSIndexPath *)indexPath;
@end

@class ActivityPromise;

@interface ActivityPeopleCell : DDTableViewCell
@property (assign, nonatomic) id<ActivityPeopleCellDelegate> delegate;

- (void)updateCellWithPromise:(ActivityPromise *)promise indexPath:(NSIndexPath *)indexPath;

@end
