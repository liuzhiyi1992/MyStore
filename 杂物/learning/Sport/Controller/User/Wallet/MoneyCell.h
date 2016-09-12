//
//  MoneyCell.h
//  Sport
//
//  Created by haodong  on 15/3/18.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@protocol MoneyCellDelegate <NSObject>
@optional
- (void)didClickMoneyCell;
@end

@interface MoneyCell : DDTableViewCell

@property (assign, nonatomic) id<MoneyCellDelegate> delegate;

- (void)updateMoney:(float)money;

@end
