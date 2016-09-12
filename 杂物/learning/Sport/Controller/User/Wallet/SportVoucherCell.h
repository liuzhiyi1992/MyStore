//
//  SportVoucherCell.h
//  Sport
//
//  Created by qiuhaodong on 15/6/29.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@class Voucher;

@protocol SportVoucherCellDelegate <NSObject>
@optional

- (void)didClickSportVoucherCellVoucher:(Voucher *)voucher;

@end

@interface SportVoucherCell : DDTableViewCell

@property (assign, nonatomic) id<SportVoucherCellDelegate> delegate;

- (void)updateCellWithVoucher:(Voucher *)voucher
              isShowUseButton:(BOOL)isShowUseButton;

@end
