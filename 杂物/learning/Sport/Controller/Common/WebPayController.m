//
//  WebPayController.m
//  Sport
//
//  Created by haodong  on 15/4/1.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "WebPayController.h"
#import "BaseConfigManager.h"

@interface WebPayController ()
@property (assign, nonatomic) BOOL isFinishPay;

@property (copy, nonatomic) NSString *alipaySuccessKeywork;
@property (copy, nonatomic) NSString *qydSuccessKeywork;
@property (copy, nonatomic) NSString *qydFailKeywork;
@end

@implementation WebPayController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    BaseConfigManager *manager = [BaseConfigManager defaultManager];
    
    if ([[manager alipayKeyword] length] > 0) {
        self.alipaySuccessKeywork = [manager alipayKeyword];
    } else {
        self.alipaySuccessKeywork = @"付款成功";
    }
    
    if ([[manager wapPaySuccessTitle] length] > 0) {
        self.qydSuccessKeywork = [manager wapPaySuccessTitle];
    } else {
        self.qydSuccessKeywork = @"趣运动支付成功";
    }
    
    if ([[manager wapPayFailTitle] length] > 0) {
        self.qydFailKeywork = [manager wapPayFailTitle];
    } else {
        self.qydFailKeywork = @"趣运动支付失败";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initLeftButtonView {
    //重写了父类方法，在支付页面不需要有两个按钮，避免用户操作错误
    HDLog(@"重写了initLeftButtonView");
}

- (void)clickBackButton:(id)sender
{
    if ([_delegate respondsToSelector:@selector(didClickWebPayControllerBackButton:)]) {
        [_delegate didClickWebPayControllerBackButton:_isFinishPay];
    }
    
    [super clickBackButton:sender];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [super webViewDidFinishLoad:webView];
    
    NSString *body = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerText"];
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([body rangeOfString:_alipaySuccessKeywork].location != NSNotFound) {
            self.isFinishPay = YES;
        }
        
        if ([title rangeOfString:_qydSuccessKeywork].location != NSNotFound ) {
            self.isFinishPay = YES;
        }
        
        if ([title rangeOfString:_qydFailKeywork].location != NSNotFound ) {
            self.isFinishPay = NO;
        }
    });
}

@end
