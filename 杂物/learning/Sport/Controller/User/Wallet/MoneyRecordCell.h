//
//  MoneyRecordCell.h
//  Sport
//
//  Created by haodong  on 15/3/22.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"
#import "MoneyRecord.h"
#import "MembershipCardRecord.h"


@interface MoneyRecordCell : DDTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;

- (void)updateCellWithMoneyRecord:(MoneyRecord *)moneyRecord;
- (void)updateCellWithMembershipCard:(MembershipCardRecord *)memberRecord;
@end
