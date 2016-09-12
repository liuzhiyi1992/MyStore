//
//  PayHelpController.m
//  Sport
//
//  Created by haodong  on 14-6-25.
//  Copyright (c) 2014年 haodong . All rights reserved.
//

#import "PayHelpController.h"
#import "UIUtils.h"
#import "UIView+Utils.h"
#import "SportProgressView.h"
#import "SportPopupView.h"
#import "BaseConfigManager.h"

@interface PayHelpController ()
@property (copy, nonatomic) NSString *phone;
@property (copy, nonatomic) NSString *urlString;
@end

@implementation PayHelpController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"支付帮助";
    [self.myWebView updateHeight:[UIScreen mainScreen].bounds.size.height - 20 - 44 - _bottomHolderView.frame.size.height];
    [self.bottomHolderView updateOriginY:_myWebView.frame.size.height];
    
    self.phone = [ConfigData customerServicePhone];
    [self.phoneButton setTitle:_phone forState:UIControlStateNormal];
    
    [self loadWebViewRequest];
}

- (void)loadWebViewRequest
{
    self.urlString = [[BaseConfigManager defaultManager] payHelpUrl];
    NSURL *url = [NSURL URLWithString:_urlString];
    if (url != nil) {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.myWebView loadRequest:request];
        [SportProgressView showWithStatus:DDTF(@"kLoading")];
    }
    else{
        [SportPopupView popupWithMessage:DDTF(@"无法打开网页")];
    }
}

- (IBAction)clickPhoneButton:(id)sender {
    if ([_phone length] > 0) {
        BOOL result = [UIUtils makePromptCall:_phone];
        
        if (result == NO) {
            [SportPopupView popupWithMessage:@"此设备不支持打电话"];
        }
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SportProgressView dismiss];
    [self removeNoDataView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [SportProgressView dismiss];
    
    CGRect frame = self.myWebView.frame;
    [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:@"网络错误"];
}

- (void)didClickNoDataViewRefreshButton
{
    [self loadWebViewRequest];
}

@end
