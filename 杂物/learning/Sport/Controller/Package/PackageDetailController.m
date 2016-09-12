//
//  PackageDetailController.m
//  Sport
//
//  Created by haodong  on 14/12/1.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "PackageDetailController.h"
#import "SingleBookingController.h"
#import "Package.h"
#import "Business.h"
#import "UIView+Utils.h"
#import "PriceUtil.h"
#import "SportProgressView.h"
#import "SportPopupView.h"
#import "User.h"
#import "UserManager.h"
#import "FastLoginController.h"

@interface PackageDetailController ()
@property (strong, nonatomic) Package *package;
@property (copy, nonatomic) NSString *packageId;
@property (assign, nonatomic) BOOL isSpecialSale;
@end

@implementation PackageDetailController


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (instancetype)initWithPackage:(Package *)package isSpecialSale:(BOOL)isSpecialSale
{
    self = [super init];
    if (self) {
        self.package = package;
        self.isSpecialSale = isSpecialSale;
    }
    return self;
}

- (instancetype)initWithPackageId:(NSString *)packageId isSpecialSale:(BOOL)isSpecialSale
{
    self = [super init];
    if (self) {
        self.packageId = packageId;
        self.isSpecialSale = isSpecialSale;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"套餐详情";
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    [self.myWebView updateHeight:screenHeight - 64 - _bottomHolderView.frame.size.height];
    [self.bottomHolderView updateOriginY:_myWebView.frame.size.height];
    [self.lineImageView setImage:[SportImage lineImage]];
    
    if (_package) {
        [self loadWebView];
        [self updateSubmitButton];
        [self calTime];
    } else {
        [self queryPackage];
    }
    
    [MobClickUtils event:umeng_event_enter_promotion_detail];
}

- (void)calTime
{
    if (_isSpecialSale && _package && _package.status == PackageStatusWaitSale) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            int diff = [_package.startDate timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970];
            
            while (diff > 0) {
                diff = [_package.startDate timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970];
                [NSThread sleepForTimeInterval:1];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (diff > 0) {
                        [self.submitButton setTitle:[NSString stringWithFormat:@"%d秒后  开始抢购", diff] forState:UIControlStateDisabled];
                    }
                });
            }
            
            if (diff <= 0) {
                self.package.status = PackageStatusCanSale;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateSubmitButton];
                });
            }
        });
    }
}

- (void)queryPackage
{
    [SportProgressView showWithStatus:@"加载中"];
    [PackageService queryPackage:self packageId:_packageId];
}

- (void)didQueryPackage:(Package *)package status:(NSString *)status msg:(NSString *)msg
{
    if ([status isEqualToString:STATUS_SUCCESS]) {
        [SportProgressView dismiss];
        self.package = package;
        [self loadWebView];
        [self updateSubmitButton];
        [self calTime];
    } else {
        if (msg) {
            [SportProgressView dismissWithError:msg];
        } else {
            [SportProgressView dismissWithError:@"网络错误"];
        }
    }
}

- (void)loadWebView
{
    NSURL *url = [NSURL URLWithString:_package.detailUrl];
    if (url != nil) {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.myWebView loadRequest:request];
        [SportProgressView showWithStatus:@"加载中..."];
    }
    else{
        [SportPopupView popupWithMessage:DDTF(@"无法打开网页")];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SportProgressView dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [SportProgressView dismiss];
}

- (void)updateSubmitButton
{
    if (_package) {
        self.bottomHolderView.hidden = NO;
        
        if (_isSpecialSale) {
            if (_package.status == PackageStatusCanSale) {
                [self.submitButton setTitle:[NSString stringWithFormat:@"%@元  立即购买", [PriceUtil toValidPriceString:[_package validPrice]]] forState:UIControlStateNormal];
                [self.submitButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateNormal];
                self.submitButton.enabled = YES;
            } else if (_package.status == PackageStatusSaleOut) {
                [self.submitButton setTitle:@"已售完" forState:UIControlStateNormal];
                [self.submitButton setBackgroundImage:[SportImage grayButtonImage] forState:UIControlStateNormal];
            } else if (_package.status == PackageStatusWaitSale){
                
                int diff = [_package.startDate timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970];
                [self.submitButton setTitle:[NSString stringWithFormat:@"%d秒后  开始抢购", diff] forState:UIControlStateDisabled];
                [self.submitButton setBackgroundImage:[SportImage blueButtonImage] forState:UIControlStateDisabled];
                self.submitButton.enabled = NO;
            }
        } else {
            if (_package.totalCount > 0) {
                [self.submitButton setTitle:[NSString stringWithFormat:@"%@元  立即购买", [PriceUtil toValidPriceString:[_package validPrice]]] forState:UIControlStateNormal];
                [self.submitButton setBackgroundImage:[SportImage orangeButtonImage] forState:UIControlStateNormal];
                self.submitButton.enabled = YES;
            } else {
                [self.submitButton setTitle:@"已售完" forState:UIControlStateNormal];
                [self.submitButton setBackgroundImage:[SportImage grayButtonImage] forState:UIControlStateNormal];
            }
        }
    } else {
        self.bottomHolderView.hidden = YES;
    }
}

- (IBAction)clickSubmitButton:(id)sender {
    if (_package.totalCount > 0) {
        if (![UserManager isLogin]) {
            FastLoginController *controller = [[FastLoginController alloc] init] ;
            [self.navigationController pushViewController:controller animated:YES];
            return;
        }
        
        SingleBookingController *controller = [[SingleBookingController alloc] initWithGoods:_package businessName:_package.businessName isSpecialSale:_isSpecialSale] ;
        [self.navigationController pushViewController:controller animated:YES];
    }else{
        [SportPopupView popupWithMessage:@"该商品已售完，请选购其他商品"];
    }
}

@end