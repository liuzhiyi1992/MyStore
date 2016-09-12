//
//  VoucherCell.m
//  Sport
//
//  Created by haodong  on 14-5-26.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "VoucherCell.h"
#import "Voucher.h"
#import "PriceUtil.h"
#import "DateUtil.h"
#import "NSDate+Utils.h"

@interface VoucherCell()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconHeightConstraint;
@property (strong, nonatomic) Voucher *voucher;
@property (weak, nonatomic) IBOutlet UILabel *passwordTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *cannotUserHolderView;
@property (weak, nonatomic) IBOutlet UIView *holderView;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainLabel;
@property (weak, nonatomic) IBOutlet UILabel *voucherNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstDescLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondDescLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdDescLabel;
@property (weak, nonatomic) IBOutlet UIButton *iconButton;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIImageView *rightBottomImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *thirdLabelHeight;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *descLabelCollection;
@end

@implementation VoucherCell


+ (NSString*)getCellIdentifier
{
    return @"VoucherCell";
}

+ (CGFloat)getCellHeight
{
    return 162;
}

+ (id)createCell
{
    VoucherCell *cell = [super createCell];
    cell.holderView.layer.cornerRadius = 5;
    cell.holderView.layer.masksToBounds = YES;
    cell.iconButton.layer.cornerRadius = cell.iconHeightConstraint.constant/2;
    cell.iconButton.layer.masksToBounds = YES;
//    cell.cannotUserHolderView.layer.cornerRadius = 8;
//    cell.cannotUserHolderView.layer.masksToBounds = YES;
    [cell.selectButton setBackgroundImage:[SportColor createImageWithColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.2]] forState:UIControlStateHighlighted];
    return cell;
}

- (void)updateCellWithVoucher:(Voucher *)voucher isShowUseButton:(BOOL)isShowUseButton
{    self.voucher = voucher;
    if (voucher.type == VoucherTypeSport) {
        
        [self.iconButton setAttributedTitle:nil forState:UIControlStateNormal];
        [self.iconButton setTitle:@"兑" forState:UIControlStateNormal];
    } else {
        NSString *priceString = [NSString stringWithFormat:@"￥%@",[PriceUtil toValidPriceString:voucher.amount]];

        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc]initWithString:priceString attributes:@{NSForegroundColorAttributeName:voucher.status == VoucherStatusActive?[SportColor highlightTextColor]:[UIColor hexColor:@"aaaaaa"]}];
        
        [attrString addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14]} range:NSMakeRange(0,1)];
        [attrString addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:24]} range:NSMakeRange(1,[priceString length]-1)];
        
        [self.iconButton setAttributedTitle:attrString forState:UIControlStateNormal];
    }
    
    self.voucherNameLabel.text = voucher.voucherName;
    if ([voucher.firstInstruction length]) {
        self.firstDescLabel.text = [NSString stringWithFormat:@"• %@",voucher.firstInstruction];
    } else {
        self.firstDescLabel.text = @"";
    }
    
    if ([voucher.secondInstruction length]) {
        self.secondDescLabel.text = [NSString stringWithFormat:@"• %@",voucher.secondInstruction];
    } else {
        self.secondDescLabel.text = @"";
    }
    
    if ([voucher.thirdInstruction length]) {
        
        self.thirdDescLabel.text = [NSString stringWithFormat:@"• %@",voucher.thirdInstruction];
        NSAttributedString *attributedText =
        [[NSAttributedString alloc] initWithString:self.thirdDescLabel.text
                                        attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:10]}];
        CGRect rect = [attributedText boundingRectWithSize:(CGSize){self.thirdDescLabel.frame.size.width, CGFLOAT_MAX}
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
        

        CGSize adjustedSize = CGSizeMake(ceilf(rect.size.width), ceilf(rect.size.height));
        self.thirdLabelHeight.constant = adjustedSize.height>= 24? 24:adjustedSize.height;
        
    } else {
        self.thirdDescLabel.text = @"";
    }
    
    self.numberLabel.text = [NSString stringWithFormat:@"%@",voucher.voucherNumber];

    NSString *validStr = [NSString stringWithFormat:@"有效至%@",[DateUtil stringFromDate:voucher.validDate DateFormat:@"yyyy/MM/dd"]];
    NSString *remainStr = @"";
    NSInteger remainDay = 100;
    if (voucher.status == VoucherStatusInvalid) {
        remainStr = @"(已过期)";
    } else if (voucher.status == VoucherStatusUsed) {
        remainStr = @"(已使用)";
    } else {

//        NSDate *today = [NSDate date];
//        int diff = [voucher.validDate timeIntervalSince1970] - [today timeIntervalSince1970];
//        if (diff >= 0) {
//            int remain = diff / (24 * 60 * 60) + 1;
//            self.remainLabel.text = [NSString stringWithFormat:@"还有%d天过期", remain];
//        }

        remainDay = voucher.endDate;
        if (remainDay > 10) {
            remainStr = [NSString stringWithFormat:@"(还有%ld天)",(long)remainDay];
        } else {
            remainStr = [NSString stringWithFormat:@"(仅剩%ld天)",(long)remainDay];
        }
    }

    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%@",validStr,remainStr] attributes:@{NSForegroundColorAttributeName:[SportColor hex6TextColor],NSFontAttributeName:[UIFont systemFontOfSize:10]}];
    if (remainDay <= 10) {
        [attrString addAttributes:@{NSForegroundColorAttributeName:[SportColor defaultColor]} range:NSMakeRange([validStr length], [attrString length] - [validStr length])];
    }

    [self.remainLabel setAttributedText:attrString];

    if (voucher.status == VoucherStatusActive
        /*&& diff > - 24 * 60 * 60*/) {
        
//       [self.selectButton setBackgroundImage:[SportColor createImageWithColor:[UIColor colorWithRed:239.0/255.0 green:132.0/255.0 blue:128.0/255.0 alpha:1]] forState:UIControlStateNormal];
        [self.rightBottomImageView setImage:[UIImage imageNamed:@"NormalVoucher"]];
        [self.voucherNameLabel setTextColor:[UIColor hexColor:@"222222"]];
        [self.iconButton setTintColor:[UIColor hexColor:@"222222"]];
        [self.bottomView setBackgroundColor:[SportColor defaultColor]];
        
        [self.passwordTitleLabel setTextColor:[UIColor hexColor:@"666666"]];
        [self.numberLabel setTextColor:[UIColor hexColor:@"666666"]];
        for (UILabel *label in self.descLabelCollection) {
            [label setTextColor:[UIColor hexColor:@"666666"]];
        }
    } else {
        
//        [self.selectButton setBackgroundImage:[SportColor createImageWithColor:[UIColor colorWithRed:168.0/255.0 green:168.0/255.0 blue:168.0/255.0 alpha:1]] forState:UIControlStateNormal];
        
        [self.rightBottomImageView setImage:[UIImage imageNamed:@"ExpireVoucher"]];
        [self.voucherNameLabel setTextColor:[UIColor hexColor:@"aaaaaa"]];
        [self.iconButton setTitleColor:[UIColor hexColor:@"aaaaaa"] forState:UIControlStateNormal];
        [self.remainLabel setTextColor:[UIColor hexColor:@"aaaaaa"]];
        [self.bottomView setBackgroundColor:[UIColor hexColor:@"c5c5c5"]];
        
        [self.numberLabel setTextColor:[UIColor hexColor:@"aaaaaa"]];
        [self.passwordTitleLabel setTextColor:[UIColor hexColor:@"aaaaaa"]];
        
        for (UILabel *label in self.descLabelCollection) {
            [label setTextColor:[UIColor hexColor:@"aaaaaa"]];
        }
    }
    
    self.selectButton.enabled = isShowUseButton;

    if (isShowUseButton && voucher.isEnable == NO) {
        self.cannotUserHolderView.hidden = NO;
    } else {
        self.cannotUserHolderView.hidden = YES;
    }

}

- (IBAction)clickSelectButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickVoucherCellVoucher:)]) {
        [_delegate didClickVoucherCellVoucher:_voucher];
    }
}


@end
