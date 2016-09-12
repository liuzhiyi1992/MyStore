//
//  MoneyRecordCell.m
//  Sport
//
//  Created by haodong  on 15/3/22.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "MoneyRecordCell.h"

#import "PriceUtil.h"

@interface MoneyRecordCell()
@property (strong, nonatomic) NSDateFormatter *formatter;
@end

@implementation MoneyRecordCell


+ (NSString *)getCellIdentifier
{
    return @"MoneyRecordCell";
}

+ (CGFloat)getCellHeight
{
    return 46;
}

- (void)updateCellWithMoneyRecord:(MoneyRecord *)moneyRecord
{
    self.descLabel.text = moneyRecord.desc;
    
    if (_formatter == nil) {
        self.formatter = [[NSDateFormatter alloc] init] ;
        [_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    
    self.timeLabel.text = [_formatter stringFromDate:moneyRecord.createTime];
    self.moneyLabel.text = [NSString stringWithFormat:@"%@%@", (moneyRecord.type == MoneyRecordTypeUsed ? @"-" : @"+"), [PriceUtil toValidPriceString:moneyRecord.money]];
    self.moneyLabel.textColor = (moneyRecord.type == MoneyRecordTypeUsed ? [SportColor defaultOrangeColor] : [UIColor colorWithRed:106.0/255.0 green:212.0/255.0 blue:73.0/255.0 alpha:1]);
}

- (void)updateCellWithMembershipCard:(MembershipCardRecord *)memberRecord
{
    self.descLabel.text = memberRecord.desc;
    
    if (_formatter == nil) {
        self.formatter = [[NSDateFormatter alloc] init] ;
        [_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    
    self.timeLabel.text = [_formatter stringFromDate:memberRecord.addTime];
    self.moneyLabel.text = [NSString stringWithFormat:@"%@%@",(memberRecord.type == MembershipCardRecordTypeUsed ? @"-" : @"+"),[PriceUtil toValidPriceString:memberRecord.amount]];

}

@end
