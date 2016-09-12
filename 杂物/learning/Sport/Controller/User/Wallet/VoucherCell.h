//
//  VoucherCell.h
//  Sport
//
//  Created by haodong  on 14-5-26.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "DDTableViewCell.h"

@class Voucher;

@protocol VoucherCellDelegate <NSObject>
@optional

- (void)didClickVoucherCellVoucher:(Voucher *)voucher;

@end

@interface VoucherCell : DDTableViewCell

@property (assign, nonatomic) id<VoucherCellDelegate> delegate;

- (void)updateCellWithVoucher:(Voucher *)voucher isShowUseButton:(BOOL)isShowUseButton;

@end
