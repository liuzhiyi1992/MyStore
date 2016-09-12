//
//  PlayedBusinessCell.h
//  Sport
//
//  Created by haodong  on 14/11/7.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@class Business;

@protocol PlayedBusinessCellDelegate <NSObject>
@optional
- (void)didClickPlayedBusinessCellSelectButton:(Business *)business;
@end

@interface PlayedBusinessCell : DDTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *businessNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *neighborhoodLabel;
@property (weak, nonatomic) IBOutlet UILabel *playHourCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *lineImageView;

@property (assign, nonatomic) id<PlayedBusinessCellDelegate> delegate;

- (void)updateCellWithBusiness:(Business *)business;

@end
