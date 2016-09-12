//
//  SportVoucherCell.m
//  Sport
//
//  Created by qiuhaodong on 15/6/29.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportVoucherCell.h"
#import "Voucher.h"
#import "UIView+Utils.h"

@interface SportVoucherCell()

@property (strong, nonatomic) Voucher *voucher;

@property (weak, nonatomic) IBOutlet UIView *holderView;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UIView *cannotUserHolderView;

@end

@implementation SportVoucherCell


+ (NSString *)getCellIdentifier
{
    return @"SportVoucherCell";
}

+ (CGFloat)getCellHeight
{
    return 110;
}

+ (id)createCell
{
    SportVoucherCell *cell = [super createCell];
    cell.holderView.layer.cornerRadius = 3;
    cell.holderView.layer.masksToBounds = YES;
    return cell;
}

- (void)updateCellWithVoucher:(Voucher *)voucher
              isShowUseButton:(BOOL)isShowUseButton
{
    self.voucher = voucher;
    
    self.numberLabel.text = [NSString stringWithFormat:@"密码:%@",voucher.voucherNumber];
    self.descLabel.text = voucher.desc;
    
    
    if (voucher.status == VoucherStatusInvalid) {
         self.remainLabel.text = @"已经过期";
    } else if (voucher.status == VoucherStatusUsed) {
            self.remainLabel.text = @"已使用";
    } else {
        NSDate *today = [NSDate date];
        int diff =  [voucher.validDate timeIntervalSince1970] - [today timeIntervalSince1970];
        if (diff >= 0) {
            int remain = diff / (24 * 60 * 60) + 1;
            self.remainLabel.text = [NSString stringWithFormat:@"还有%d天过期", remain];
        }
    }
    
    if (voucher.status == VoucherStatusActive) {
        [self.holderView setBackgroundColor:[UIColor colorWithRed:253.0/255.0 green:143.0/255.0 blue:47.0/255.0 alpha:1]];
    } else {
        [self.holderView setBackgroundColor:[UIColor hexColor:@"bababa"]];
    }
    
    self.selectButton.enabled = isShowUseButton;
   //
    if (isShowUseButton && voucher.isEnable == NO) {
        self.cannotUserHolderView.hidden = NO;
    } else {
        self.cannotUserHolderView.hidden = YES;
    }
}

- (IBAction)clickSelectButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickSportVoucherCellVoucher:)]) {
        [_delegate didClickSportVoucherCellVoucher:_voucher];
    }
}

@end
