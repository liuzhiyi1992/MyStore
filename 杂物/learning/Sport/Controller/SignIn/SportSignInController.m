//
//  SportSportInController.m
//  Sport
//
//  Created by lzy on 16/5/23.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "SportSignInController.h"
#import <MapKit/MapKit.h>
#import "SportLocationManager.h"
#import "SignInService.h"
#import "NSDictionary+JsonValidValue.h"
#import "UserManager.h"
#import "VenuesSelectView.h"
#import <objc/runtime.h>
#import "SignInSuccessView.h"
#import "UIView+Utils.h"
#import "SportRecordsViewController.h"
#import "ShareView.h"
#import "SportPopupView.h"
#import "SportProgressView.h"
#import "ScanQrCodeMaskView.h"

const CGFloat LOADING_MASK_WIDTH = 6.f;
const CGFloat LOADING_MASK_HEIGHT = 30.f;
const CGFloat QUERY_LOCATION_DELAY = 2;
const CGFloat QUERY_LOCATION_TIMEOUT = 15;
const CGFloat SIGN_IN_FAIL_AUTO_POP_DELAY = 3;
NSString * const NOTIFICATION_NAME_SIGN_IN_SUCCEED = @"NOTIFICATION_NAME_SIGN_IN_SUCCEED";

@interface SportSignInController () <VenuesSelectViewDelegate, SignInSuccessViewDelegate, UIAlertViewDelegate, ShareViewDelegate, ScannerViewControllerDelegate>
@property(nonatomic,strong) MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIImageView *scanningNetImageView;
@property (weak, nonatomic) IBOutlet UIButton *failingButton;
@property (weak, nonatomic) IBOutlet UILabel *topTipsLabel;
@property (strong, nonatomic) VenuesSelectView *venuesSelectView;

@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UILabel *loadingbackgroundLabel;
@property (strong, nonatomic) CAShapeLayer *loadingMaskLayer;
@property (strong, nonatomic) CAShapeLayer *loadingBackgroundMaskLayer;
@property (assign, nonatomic) CGFloat loadingMaskOriginX;
@property (strong, nonatomic) CADisplayLink *displayLink;
@property (assign, nonatomic) BOOL haveQueryLocation;
@property (strong, nonatomic) ShareContent *shareContent;
@property (assign, nonatomic) BOOL venuesSelectViewCannotVisable;
@property (assign, nonatomic) BOOL queryLocationTimeout;
@property (assign, nonatomic) BOOL canNotQueryLocation;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imagePickImageViewCenterYConstraint;

@end

@implementation SportSignInController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"打卡";
    self.delegate = self;
    
    [self registerNotification];
    [self configureUI];
    [self configureLoadingAnimation];
    [self beginQueryLocation];
    [MobClickUtils beginEvent:umeng_event_sign_in_duration label:@"打卡成功耗时"];
}

- (void)dealloc {
    [_venuesSelectView removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_displayLink invalidate];
    self.displayLink = nil;
    self.venuesSelectViewCannotVisable = YES;
    [_venuesSelectView dismiss];
}

- (void)clickBackButton:(id)sender {
    if (_venuesSelectView == nil) {
        [super clickBackButton:sender];
    } else {
        [self refuseSignInFailing];
    }
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signInSuccessPopShareView) name:NOTIFICATION_NAME_SIGN_IN_POP_SHARE_VIEW object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginQueryLocation) name:UIApplicationWillEnterForegroundNotification object:nil];
    
}

- (void)configureUI {
    //4s超出顶部问题
    if ([[UIScreen mainScreen] bounds].size.height == 480) {//i4
        _imagePickImageViewCenterYConstraint.constant = 0;
    }
}

- (void)beginQueryLocation {
    if (_canNotQueryLocation) {
        return;
    }
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status != AVAuthorizationStatusAuthorized) {
        return;
    }
    __weak __typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(QUERY_LOCATION_DELAY * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf queryLocation];
    });
    //timeout
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((QUERY_LOCATION_DELAY + QUERY_LOCATION_TIMEOUT)* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.queryLocationTimeout = YES;
    });
}

- (void)queryLocation {
    SportLocationManager *sportLocationManager = [SportLocationManager shareManager];
    __weak __typeof(self) weakSelf = self;
    [sportLocationManager getLocationCoordinate:weakSelf complete:^(CLLocationCoordinate2D location, NSError *error) {
        HDLog(@"location :%f -- %f", location.latitude, location.longitude);
        //la 23.093985  lo 113.324852
        if (nil == error && NO == weakSelf.haveQueryLocation) {
            weakSelf.haveQueryLocation = YES;
            [SignInService getNearbyVenuesWithLatitude:location.latitude longitude:location.longitude completion:^(NSString *status, NSString *msg, NSArray *venuesArray) {
                if ([status isEqualToString:STATUS_SUCCESS]) {
                    if (venuesArray.count > 0) {
                        //有场馆
                        [weakSelf signInWithVenuesArray:venuesArray];
                    } else {
                        [weakSelf signInFailingWithTips:@"检测您所在的位置并不是场馆"];
                    }
                } else if ([status isEqualToString:STATUS_NO_RESULT]){
                    //无场馆error
                    [weakSelf signInFailingWithTips:@"检测您所在的位置并不是场馆"];
                } else {
                    [weakSelf signInFailingWithTips:@"网络连接失败"];
                }
            }];
        } else {
            //alertView delegate 耦合问题 可以用ZYAlertController解决
            if (NO == _queryLocationTimeout) {
                authorityBlock(error, weakSelf);
            } else {
                [self signInTimeout];
            }
        }
    }];
}

- (void)configureLoadingAnimation {
    self.loadingMaskOriginX = -LOADING_MASK_WIDTH;
    self.loadingMaskLayer = [CAShapeLayer layer];
    self.loadingBackgroundMaskLayer = [CAShapeLayer layer];
    _loadingMaskLayer.opacity = 0.4f;
    _loadingLabel.layer.mask = _loadingMaskLayer;
    _loadingbackgroundLabel.layer.mask = _loadingBackgroundMaskLayer;
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)showVenuesSelectViewWithArray:(NSArray *)array {
    NSMutableArray *nameArray = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        NSString *venuesName = [dict validStringValueForKey:PARA_VENUES_NAME];
        NSString *venuesId = [dict validStringValueForKey:PARA_VENUES_ID];
        objc_setAssociatedObject(venuesName, &kVenuesId, venuesId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [nameArray addObject:venuesName];
    }
    [_displayLink invalidate];
    self.displayLink = nil;
    self.maskView.hidden = YES;
    self.pickImageView.hidden = YES;
    self.lineImageView.hidden = YES;
    _scanningNetImageView.hidden = YES;
    _loadingLabel.hidden = YES;
    _loadingbackgroundLabel.hidden = YES;
    if (!_venuesSelectViewCannotVisable) {
        self.venuesSelectView = [VenuesSelectView showViewWithVenuesNameArray:nameArray delegate:self];
    }
}

- (void)signInWithVenuesArray:(NSArray *)venuesArray {
    if (venuesArray.count == 1) {
        //打卡
        NSString *venuesId = [venuesArray.firstObject validStringValueForKey:PARA_VENUES_ID];
        [self signInWithVenuesId:venuesId];
    } else if (venuesArray.count > 1) {
        //多个场馆
        [self showVenuesSelectViewWithArray:venuesArray];
    }
}

- (void)signInWithVenuesId:(NSString *)venuesId {
    [SportProgressView showWithStatus:@"打卡请求中" hasMask:YES];
    NSString *userId = [[UserManager defaultManager] readCurrentUser].userId;
    __weak SportSignInController *weakSelf = self;
    [SignInService signInWithUserID:userId venuesId:venuesId completion:^(NSString *status, NSString *msg, NSDictionary *data, ShareContent *shareContent) {
        [SportProgressView dismiss];
        if ([status isEqualToString:STATUS_SUCCESS]) {
            [weakSelf signInSucceedWithData:data];
            weakSelf.shareContent = shareContent;
        } else {
            [SportPopupView popupWithMessage:msg];
        }
    }];
}

- (void)signInSucceedWithData:(NSDictionary *)dataDict {
    [MobClickUtils endEvent:umeng_event_sign_in_duration label:@"打卡成功耗时"];
    [_venuesSelectView removeFromSuperview];
    self.venuesSelectView = nil;
    SignInSuccessView *signInSuccessView = [SignInSuccessView createViewWithDataDict:dataDict delegate:self];
    [signInSuccessView updateWidth:self.view.bounds.size.width];
    [signInSuccessView updateHeight:self.view.bounds.size.height];
    [self.view addSubview:signInSuccessView];
    
    //notification
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NAME_SIGN_IN_SUCCEED object:nil];
    _canNotQueryLocation = YES;
    
}

- (void)refuseSignInFailing {
    [_venuesSelectView removeFromSuperview];
    [_topTipsLabel removeFromSuperview];
    self.pickImageView.hidden = NO;
    _scanningNetImageView.alpha = 1;
    _scanningNetImageView.hidden = NO;
    [self signInFailingWithTips:@""];
}

- (void)signInFailingWithTips:(NSString *)tips {
    _loadingLabel.hidden = YES;
    _loadingbackgroundLabel.hidden = YES;
    _failingButton.hidden = NO;
    _failingButton.titleLabel.text = @"打卡失败";
    _topTipsLabel.hidden = NO;
    _topTipsLabel.text = tips;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SIGN_IN_FAIL_AUTO_POP_DELAY * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)signInTimeout {
    [_venuesSelectView removeFromSuperview];
    self.pickImageView.hidden = NO;
    _loadingLabel.hidden = YES;
    _loadingbackgroundLabel.hidden = YES;
    _scanningNetImageView.alpha = 1;
    _scanningNetImageView.hidden = NO;
    _failingButton.titleLabel.text = @"打卡失败";
    _topTipsLabel.hidden = NO;
    _topTipsLabel.text = @"您的网络不太好，请重试";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SIGN_IN_FAIL_AUTO_POP_DELAY * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)displayLinkAction {
    //扫描中动画
    self.loadingMaskOriginX ++;
    if (_loadingMaskOriginX > _loadingLabel.bounds.size.width - LOADING_MASK_WIDTH) {
        self.loadingMaskOriginX = -LOADING_MASK_WIDTH;
    }
    UIBezierPath *removePath = [UIBezierPath bezierPathWithRect:CGRectMake(_loadingMaskOriginX, 0, LOADING_MASK_WIDTH, LOADING_MASK_HEIGHT)];
    UIBezierPath *pathOne = [UIBezierPath bezierPathWithRect:_loadingbackgroundLabel.bounds];
    if (removePath != nil) {
        [pathOne appendPath:[removePath bezierPathByReversingPath]];
    }
    _loadingBackgroundMaskLayer.path = pathOne.CGPath;
    _loadingMaskLayer.path = [UIBezierPath bezierPathWithRect:CGRectMake(_loadingMaskOriginX, 0, LOADING_MASK_WIDTH, LOADING_MASK_HEIGHT)].CGPath;
    
    //扫描网动画
    CGFloat progress = 1 - fabs(_scanningNetImageView.center.y - self.lineImageView.center.y)/(self.scanningNetImageView.bounds.size.height/2);
    _scanningNetImageView.layer.opacity = progress < 0 ? 0 : progress;
}

- (void)venuesSelectViewDidSelectedVenuesId:(NSString *)venuesId {
    [self signInWithVenuesId:venuesId];
}

- (void)signInSuccessViewWillPushRecordsViewController {
    SportRecordsViewController *controller = [[SportRecordsViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)signInSuccessPopShareView {
    [ShareView popUpViewWithContent:_shareContent channelList:[NSArray arrayWithObjects:@(ShareChannelWeChatSession), @(ShareChannelWeChatTimeline), @(ShareChannelSina), @(ShareChannelQQ), nil] viewController:self delegate:self];
}

- (void)didShare:(ShareChannel)channel {
    switch (channel) {
        case ShareChannelWeChatSession:
            [MobClickUtils event:umeng_event_sign_in_share_success label:@"微信消息"];
            break;
        case ShareChannelWeChatTimeline:
            [MobClickUtils event:umeng_event_sign_in_share_success label:@"微信朋友圈"];
            break;
        case ShareChannelSina:
            [MobClickUtils event:umeng_event_sign_in_share_success label:@"新浪"];
            break;
        case ShareChannelQQ:
            [MobClickUtils event:umeng_event_sign_in_share_success label:@"qq"];
            break;
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    } else if (buttonIndex == alertView.cancelButtonIndex) {
        [self signInFailingWithTips:@"你没有打开相关服务，无法完成打卡"];
    }
}

- (void)didGrantedAVCaptureAuthority:(BOOL)isGranted {
    if (isGranted) {
        [self beginQueryLocation];
    } else {
        [self refuseSignInFailing];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
