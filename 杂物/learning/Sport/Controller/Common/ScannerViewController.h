//
//  ScannerViewController.h
//  iOS7_BarcodeScanner
//
//  Created by Jake Widmer on 11/16/13.
//  Copyright (c) 2013 Jake Widmer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SportController.h"

@import AVFoundation;   // iOS7 only import style

@class ScanQrCodeMaskView;
@protocol ScannerViewControllerDelegate <NSObject>

@optional
- (void) willValidateQrCode:(NSString *)string;
- (void)didGrantedAVCaptureAuthority:(BOOL)isGranted;

@end

@interface ScannerViewController : SportController<UIAlertViewDelegate, AVCaptureMetadataOutputObjectsDelegate>
@property (strong, nonatomic) NSMutableArray * allowedBarcodeTypes;
@property (assign, nonatomic) id<ScannerViewControllerDelegate> delegate;

@property (strong, nonatomic) ScanQrCodeMaskView *maskView;
@property (weak, nonatomic) IBOutlet UIImageView *pickImageView;
@property (weak, nonatomic) IBOutlet UIImageView *lineImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *animateLineConstraint;

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UILabel *descTextLabel;
@property (weak, nonatomic) IBOutlet UIView *descTextView;
- (void)stopRunning;
- (void)startRunning;

@end
