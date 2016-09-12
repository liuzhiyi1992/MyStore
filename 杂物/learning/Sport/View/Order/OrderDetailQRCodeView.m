//
//  OrderDetailQRCodeView.m
//  Sport
//
//  Created by lzy on 16/8/4.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "OrderDetailQRCodeView.h"
#import "QrCode.h"
#import "QRCodeGenerator.h"
#import "UIView+ExtendTouchArea.h"
#import "SportNetworkContent.h"

#define ALPHA_DEFAULT 1.f
#define ALPHA_EXPIRED 0.2f
#define EDGEINSET_DEFAULT_TOUCH_EXTEND UIEdgeInsetsMake(-30, -30, -30, -30)

NSString * const NOTIFICATION_NAME_VERIFICATION_DID_CHANGE = @"NOTIFICATION_NAME_VERIFICATION_DID_CHANGE";

@interface OrderDetailQRCodeView ()
@property (weak, nonatomic) IBOutlet UILabel *pageLabel;
@property (weak, nonatomic) IBOutlet UILabel *verificationCodeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UILabel *expireDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *qrCodeStatusLabel;
@property (assign, nonatomic) NSInteger codeDisplayIndex;
@property (strong, nonatomic) NSArray *verificationArray;
@property (strong, nonatomic) NSArray *qrCodeImageArray;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@end

@implementation OrderDetailQRCodeView
+ (OrderDetailQRCodeView *)createViewWithVerificationArray:(NSArray *)verificationArray {
    OrderDetailQRCodeView *view = [[NSBundle mainBundle] loadNibNamed:@"OrderDetailQRCodeView" owner:self options:nil][0];
    [view registerNotification];
    [view configureBaseUI];
    [view setupWithVerificationArray:verificationArray];
    return view;
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(verificationDidChange:) name:NOTIFICATION_NAME_VERIFICATION_DID_CHANGE object:nil];
}

- (NSDateFormatter *)dateFormatter {
    if (nil == _dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"MM月dd日"];
    }
    return _dateFormatter;
}

- (void)setCodeDisplayIndex:(NSInteger)codeDisplayIndex {
    _codeDisplayIndex = codeDisplayIndex;
    [self updateButtonStatus];
    [self configureQrCodeWithIndex:_codeDisplayIndex];
}

- (void)setVerificationArray:(NSArray *)verificationArray {
    _verificationArray = [verificationArray copy];
    if (_verificationArray.count <= 1) {
        [_backButton setHidden:YES];
        [_forwardButton setHidden:YES];
    }
}

- (void)setupWithVerificationArray:(NSArray *)verificationArray {
    self.verificationArray = verificationArray;
    [self generatorQrCodeImages];
    self.codeDisplayIndex = 0;
    //无数据容错
    [self validSystemExceptionWithVerificationArray:verificationArray];
}

- (void)configureBaseUI {
    [_backButton setTouchExtendInset:EDGEINSET_DEFAULT_TOUCH_EXTEND];
    [_forwardButton setTouchExtendInset:EDGEINSET_DEFAULT_TOUCH_EXTEND];
}

- (void)generatorQrCodeImages {
    NSMutableArray *qrCodeImageArray = [NSMutableArray array];
    for (QrCode *qrCode in _verificationArray) {
        [qrCodeImageArray addObject:[QRCodeGenerator qrImageForString:qrCode.code imageSize:130.f]];
    }
    self.qrCodeImageArray = [qrCodeImageArray copy];
}

- (void)configureQrCodeWithIndex:(NSInteger)index {
    if (_verificationArray.count == 0) {
        return;
    }
    [self changePageLabelWithIndex:index];
    QrCode *qrCode = [_verificationArray objectAtIndex:index];
    UIImage *qrCodeImage = [_qrCodeImageArray objectAtIndex:index];
    switch (qrCode.status) {
        case QrCodeStatusNew:
            [self setupQrCodeWithCodeImage:qrCodeImage qrCode:qrCode tips:nil];
            break;
        case QrCodeStatusUsed:
            [self setupQrCodeWithCodeImage:qrCodeImage qrCode:qrCode tips:@"已使用"];
            break;
        case QrCodeStatusRefunded:
            [self setupQrCodeWithCodeImage:qrCodeImage qrCode:qrCode tips:@"已退"];
            break;
        default:
            break;
    }
}

- (void)setupQrCodeWithCodeImage:(UIImage *)codeImage
                          qrCode:(QrCode *)qrCode
                            tips:(NSString *)tips {
    [_qrCodeImageView setImage:codeImage];
    [_verificationCodeLabel setText:qrCode.code];
    if (qrCode.usedTime && tips) {
        [_expireDateLabel setHidden:NO];
        [_qrCodeStatusLabel setHidden:NO];
        [_qrCodeImageView setAlpha:ALPHA_EXPIRED];
        [_verificationCodeLabel setAlpha:ALPHA_EXPIRED];
        _expireDateLabel.text = [self.dateFormatter stringFromDate:qrCode.usedTime];
        _qrCodeStatusLabel.text = tips;
    } else {
        [_expireDateLabel setHidden:YES];
        [_qrCodeStatusLabel setHidden:YES];
        [_qrCodeImageView setAlpha:ALPHA_DEFAULT];
        [_verificationCodeLabel setAlpha:ALPHA_DEFAULT];
    }
}

- (IBAction)clickChangeButtons:(id)sender {
    if (_backButton == sender) {
        [self slideBackQrCode];
    } else if (_forwardButton == sender) {
        [self slideForwardQrCode];
    }
}

- (void)slideBackQrCode {
    self.codeDisplayIndex --;
    [self updateButtonStatus];
}

- (void)slideForwardQrCode {
    self.codeDisplayIndex ++;
    [self updateButtonStatus];
}

- (void)updateButtonStatus {
    [_backButton setEnabled:!(0 == _codeDisplayIndex)];
    [_forwardButton setEnabled:!(_verificationArray.count - 1 == _codeDisplayIndex)];
}

- (void)changePageLabelWithIndex:(NSInteger)index {
    [_pageLabel setText:[NSString stringWithFormat:@"%0.ld/%0.lu", (long)(index+1), (unsigned long)_verificationArray.count]];
}

- (void)validSystemExceptionWithVerificationArray:(NSArray *)verificationArray {
    if (verificationArray.count == 0) {
        [_expireDateLabel setHidden:NO];
        [_expireDateLabel setText:@"系统错误，请咨询客服"];
    }
}

- (void)verificationDidChange:(NSNotification *)notify {
    NSArray *qrCodeList = [notify.userInfo objectForKey:PARA_QR_CODE_LIST];
    [self setupWithVerificationArray:qrCodeList];
}

@end
