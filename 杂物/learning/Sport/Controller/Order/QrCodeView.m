//
//  QrCodeView.m
//  Sport
//
//  Created by 江彦聪 on 15/3/24.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "QrCodeView.h"
#import "NSString+Utils.h"
#import "QRCodeGenerator.h"

@interface QrCodeView()
@property (copy, nonatomic) NSString *code;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;
@property (weak, nonatomic) IBOutlet UIView *contentHolderView;
@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;
@property (weak, nonatomic) IBOutlet UIView *headerHolderView;
@property (weak, nonatomic) IBOutlet UIView *footerHolderView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMarginConstraint;
@end

@implementation QrCodeView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


+ (QrCodeView *)createQrCodeViewWithCode:(NSString *)code
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"QrCodeView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    QrCodeView *view = [topLevelObjects objectAtIndex:0];
    view.frame = [UIScreen mainScreen].bounds;
    
    view.code = code;
    view.headerHolderView.hidden = YES;
    view.footerHolderView.hidden = YES;
    view.contentHolderView.layer.cornerRadius = 6.0f;
    view.contentHolderView.layer.masksToBounds = YES;
    return view;
}

-(void)showWithMonthCardCodeView
{
    self.footerHolderView.hidden = NO;
    if ([self.code length] > 0) {
        NSString *encodeCode = [self.code encodedURLParameterString];
        NSString *value = [NSString stringWithFormat:@"m=%@", encodeCode];
        UIImage *qrcodeImage = [self qrCodeGenerate:value];
        [self.qrCodeImageView setImage:qrcodeImage];
    }
    self.bottomMarginConstraint.constant = 60;
    
    [self show];
}

-(void)showWithOrderCodeView
{
    self.headerHolderView.hidden = NO;
    
    if ([self.code length] > 0) {
        NSString *value = [NSString stringWithFormat:@"c=%@", self.code];
        
        UIImage *qrcodeImage = [self qrCodeGenerate:value];
        [self.qrCodeImageView setImage:qrcodeImage];
    }
    
    self.codeLabel.text = self.code;
    self.bottomMarginConstraint.constant = 15;
    [self show];
}

-(UIImage *)qrCodeGenerate:(NSString *)value
{
    UIImage* qrcodeImage = nil;
    int qrcodeImageDimension = 300;
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_7_0) {
        
        qrcodeImage = [QRCodeGenerator qrImageForString:value imageSize:qrcodeImageDimension];
        
    } else {
        qrcodeImage = [self createNonInterpolatedUIImageFormCIImage:[self createQRForString:value] withSize:qrcodeImageDimension];
    }
    
    return qrcodeImage;
}

- (void)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];

    self.contentHolderView.alpha = 0;
    self.contentHolderView.transform = CGAffineTransformMakeScale(1.1, 1.1);
    
    [UIView animateWithDuration:0.5 delay:0.06 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.contentHolderView.alpha = 1;
        self.contentHolderView.transform = CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - InterpolatedUIImage
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // create a bitmap image that we'll draw into a bitmap context at the desired size;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // Create an image with the contents of our bitmap
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    // Cleanup
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    CGColorSpaceRelease(cs);
    UIImage *resultImage = [UIImage imageWithCGImage:scaledImage];
    CGImageRelease(scaledImage);
    return resultImage;
}

#pragma mark - QRCodeGenerator
- (CIImage *)createQRForString:(NSString *)qrString {
    // Need to convert the string to a UTF-8 encoded NSData object
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    // Create the filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // Set the message content and error-correction level
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    // Send the image back
    return qrFilter.outputImage;
}

- (IBAction)touchDownBackground:(id)sender {
    [self removeFromSuperview];
}


//- (void)dealloc {
//    [_codeLabel release];
//    [_contentHolderView release];
//    [_headerHolderView release];
//    [_footerHolderView release];
//    [_bottomMarginConstraint release];
//    [super dealloc];
//}
@end
