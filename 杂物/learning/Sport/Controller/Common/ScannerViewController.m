//
//  ViewController.m
//  iOS7_BarcodeScanner
//
//  Created by Jake Widmer on 11/16/13.
//  Copyright (c) 2013 Jake Widmer. All rights reserved.
//


#import "ScannerViewController.h"
#import "SportColor.h"
#import "SportProgressView.h"
#import "Barcode.h"
#import "ScanQrCodeMaskView.h"
#import "UIView+Utils.h"

@interface ScannerViewController ()
{
    int num;
    BOOL upOrdown;
}

@property (weak, nonatomic) NSTimer *timer;

@end

@implementation ScannerViewController{
    /* Here’s a quick rundown of the instance variables (via 'iOS 7 By Tutorials'):
     
     1. _captureSession – AVCaptureSession is the core media handling class in AVFoundation. It talks to the hardware to retrieve, process, and output video. A capture session wires together inputs and outputs, and controls the format and resolution of the output frames.
     
     2. _videoDevice – AVCaptureDevice encapsulates the physical camera on a device. Modern iPhones have both front and rear cameras, while other devices may only have a single camera.
     
     3. _videoInput – To add an AVCaptureDevice to a session, wrap it in an AVCaptureDeviceInput. A capture session can have multiple inputs and multiple outputs.
     
     4. _previewLayer – AVCaptureVideoPreviewLayer provides a mechanism for displaying the current frames flowing through a capture session; it allows you to display the camera output in your UI.
     5. _running – This holds the state of the session; either the session is running or it’s not.
     6. _metadataOutput - AVCaptureMetadataOutput provides a callback to the application when metadata is detected in a video frame. AV Foundation supports two types of metadata: machine readable codes and face detection.
     7. _backgroundQueue - Used for showing alert using a separate thread.
     */
    AVCaptureSession *_captureSession;
    AVCaptureDevice *_videoDevice;
    AVCaptureDeviceInput *_videoInput;
    AVCaptureVideoPreviewLayer *_previewLayer;
    BOOL _running;
    AVCaptureMetadataOutput *_metadataOutput;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self setupCaptureSession];
//    _previewLayer.frame = _previewView.bounds;
    //[_previewView.layer insertSublayer:_previewLayer atIndex:0];
    
    // listen for going into the background and stop the session
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationWillEnterForeground:)
     name:UIApplicationWillEnterForegroundNotification
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationDidEnterBackground:)
     name:UIApplicationDidEnterBackgroundNotification
     object:nil];
    
    //改用切图
//    self.pickImageView.layer.cornerRadius = 3.0;
//    self.pickImageView.layer.masksToBounds = YES;
//    self.pickImageView.layer.borderWidth = 1;
//    self.pickImageView.layer.borderColor = [[UIColor whiteColor] CGColor];

}

-(void)lineAnimation
{
    if (upOrdown == NO) {
        num += 2;
        _animateLineConstraint.constant = num;
        if (num >= self.pickImageView.frame.size.height) {
            upOrdown = YES;
        }
    }
    else {
        num -= 2;
        _animateLineConstraint.constant = num;
        if (num <= 0) {
            upOrdown = NO;
        }
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
        
        // set default allowed barcode types, remove types via setings menu if you don't want them to be able to be scanned
        self.allowedBarcodeTypes = [NSMutableArray new];
        [self.allowedBarcodeTypes addObject:AVMetadataObjectTypeQRCode];
        [self setupCaptureSession];
        _previewLayer.frame = _previewView.bounds;
        [self startRunning];
    }
    
    self.pickImageView.hidden = NO;
    self.lineImageView.hidden = NO;
    
    if (self.maskView == nil) {
        
        
        self.maskView = [[ScanQrCodeMaskView alloc] initWithFrame:self.view.frame maskFrame:self.pickImageView.frame];
        
        [self.maskView updateOriginY:self.maskView.frame.origin.y - self.navigationController.navigationBar.frame.origin.y - self.navigationController.navigationBar.frame.size.height];
        
        if (_descTextView != nil) {
            [self.view insertSubview:self.maskView belowSubview:self.descTextView];
        } else {
            [self.view addSubview:self.maskView];
        }
        
    }
    
    [SportProgressView dismiss];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopRunning];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AV capture methods
- (void)setupCaptureSession {
    // 1
    if (_captureSession) return;
    // 2
    _videoDevice = [AVCaptureDevice
                    defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!_videoDevice) {
       // NSLog(@"No video camera on this device!");
        return;
    }
    // 3
    _captureSession = [[AVCaptureSession alloc] init];
    // 4
    _videoInput = [[AVCaptureDeviceInput alloc]
                   initWithDevice:_videoDevice error:nil];
    // 5
    if ([_captureSession canAddInput:_videoInput]) {
        [_captureSession addInput:_videoInput];
    }
    
    //fix for iphone4
    if( [_captureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080] == YES )
    {
        _captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
    } else {
        _captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    }
    
    // 6
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc]
                     initWithSession:_captureSession];
    _previewLayer.videoGravity =
    AVLayerVideoGravityResizeAspectFill;
    [_previewView.layer insertSublayer:_previewLayer atIndex:0];
    
    // capture and process the metadata
    _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    dispatch_queue_t metadataQueue =
    dispatch_queue_create("com.quyundong.metadata", 0);
    
    [self limitOutputCaptureScreen];
    
    [_metadataOutput setMetadataObjectsDelegate:self
                                          queue:metadataQueue];
    if ([_captureSession canAddOutput:_metadataOutput]) {
        [_captureSession addOutput:_metadataOutput];
    }
}

- (void) limitOutputCaptureScreen {
    
    CGSize size = self.view.bounds.size;
    CGRect cropRect = self.pickImageView.frame;
    //CGRect cropRect = CGRectMake(40, 100, 240, 240);
    CGFloat p1 = size.height/size.width;
    CGFloat p2 = 1920./1080.;  //使用了1080p的图像输出
    if (p1 < p2) {
        CGFloat fixHeight = size.width * 1920. / 1080.;
        CGFloat fixPadding = (fixHeight - size.height)/2;
        _metadataOutput.rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                                                    cropRect.origin.x/size.width,
                                                    cropRect.size.height/fixHeight,
                                                    cropRect.size.width/size.width);
    } else {
        CGFloat fixWidth = size.height * 1080. / 1920.;
        CGFloat fixPadding = (fixWidth - size.width)/2;
        _metadataOutput.rectOfInterest = CGRectMake(cropRect.origin.y/size.height,
                                                    (cropRect.origin.x + fixPadding)/fixWidth,
                                                    cropRect.size.height/size.height,
                                                    cropRect.size.width/fixWidth);
    }
}

- (void)startRunning {
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
        
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        if(status != AVAuthorizationStatusAuthorized){
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if(granted){ // Access has been granted ..do something
                    [_delegate didGrantedAVCaptureAuthority:YES];
                } else { // Access denied ..do something
                    [_delegate didGrantedAVCaptureAuthority:NO];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"请在iPhone的\"设置－隐私-相机\"选项中，允许趣运动访问你的相机" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
                        [alert show];
                        [self.navigationController popViewControllerAnimated:YES];
                        return;
                    });
                }
            }];
        }
        
        if (_running) return;
        [_captureSession startRunning];

        //fix bug  unsupported type found.
        _metadataOutput.metadataObjectTypes = _metadataOutput.availableMetadataObjectTypes;
        _running = YES;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(lineAnimation) userInfo:nil repeats:YES];
    }
    
    
}
- (void)stopRunning {
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
        if (!_running) return;
        [_captureSession stopRunning];
        _running = NO;
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
    }
}

//  handle going foreground/background
- (void)applicationWillEnterForeground:(NSNotification*)note {
    [self startRunning];
}
- (void)applicationDidEnterBackground:(NSNotification*)note {
    [self stopRunning];
}

#pragma mark - Delegate functions

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    [metadataObjects
     enumerateObjectsUsingBlock:^(AVMetadataObject *obj,
                                  NSUInteger idx,
                                  BOOL *stop)
     {
         if ([obj isKindOfClass:
              [AVMetadataMachineReadableCodeObject class]])
         {
             // 3
             AVMetadataMachineReadableCodeObject *code =
             (AVMetadataMachineReadableCodeObject*)
             [_previewLayer transformedMetadataObjectForMetadataObject:obj];
             // 4
             Barcode * barcode = [Barcode processMetadataObject:code];
             
             for(NSString * str in self.allowedBarcodeTypes){
                if([barcode.getBarcodeType isEqualToString:str]){
                    [self validBarcodeFound:barcode];
                    return;
                }
            }

         }
     }];
}

- (void) validBarcodeFound:(Barcode *)barcode{
    [self stopRunning];
    
    HDLog(@"code data %@", [barcode getBarcodeData]);
    NSString *barCodeString = [barcode getBarcodeData];
    
    [self processValidaeQrCode:barCodeString];
    //[_previewLayer removeFromSuperlayer];
}


- (void) processValidaeQrCode:(NSString *)barCodeString{

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_delegate respondsToSelector:@selector(willValidateQrCode:)]) {
            [_delegate willValidateQrCode:barCodeString];
        }
    });
}

@end


