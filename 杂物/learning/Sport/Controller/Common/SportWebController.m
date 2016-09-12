//
//  SportWebController.m
//  Sport
//
//  Created by haodong  on 13-8-31.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SportWebController.h"
#import "SportProgressView.h"
#import "SportPopupView.h"
#import "SportNavigationController.h"
#import "UIView+Utils.h"
#import "XQueryComponents.h"
#import "GoSportUrlAnalysis.h"
#import "SDWebImageManager.h"
#import "SDWebImageDownloader.h"
#import "UIImage+normalized.h"
#import "NJKWebViewProgressView.h"
#import "CollectAndShareButtonView.h"
//#import "CourtPoolDetailController.h"
#import "UserManager.h"
#import "NSString+Utils.h"




@interface SportWebController ()

@property (strong, nonatomic) NJKWebViewProgressView *progressView;
@property (strong, nonatomic) NJKWebViewProgress *progressProxy;

@property (copy, nonatomic) NSString *urlString;
@property (strong, nonatomic) ShareContent *shareContent;
@property (strong, nonatomic) CollectAndShareButtonView *leftTopView;

@property (strong, nonatomic) CollectAndShareButtonView *rightTopView;

@property (strong, nonatomic) NSArray *assignChannelList;//指定分享方式数组

- (void)initLeftButtonView;

@end

@implementation SportWebController

- (void)reloadWebView {
    [self.myWebView reload];
}

- (void)viewDidUnload {
    [self setMyWebView:nil];
    [self setWebViewBackButton:nil];
    [self setWebViewRefreshButton:nil];
    [self setWebViewForwardButton:nil];
    [self setBottomHolderView:nil];
    [super viewDidUnload];
}

- (id)initWithUrlString:(NSString *)urlString title:(NSString *)title
{
    return [self initWithUrlString:urlString title:title channelList:nil];
}
 
- (id)initWithUrlString:(NSString *)urlString title:(NSString *)title channelList:(NSArray *)channelList {
    self = [super initWithNibName:@"SportWebController" bundle:[NSBundle mainBundle]];
    if (self) {
        self.urlString = urlString;
        self.title = title;
        self.assignChannelList = channelList;
    }
    return self;
}

-(void) checkCanLogin {
    NSRange loginRange = [self.urlString rangeOfString:@"applogin=1"];
    if (loginRange.length == 0) {
        return;
    }
    
    NSMutableString *urlString = [[NSMutableString alloc] init];
    
    [urlString appendString:self.urlString];
    NSString *loginEncode = @"";
    User *user = [[UserManager defaultManager] readCurrentUser];
    if ([user.userId length] > 0) {
        //需要encode loginEncode
        loginEncode= [[UserManager readLoginEncode] encodedURLParameterString];
    }
    
    [urlString replaceCharactersInRange:loginRange withString:[NSString stringWithFormat:@"login_encode=%@",loginEncode]];
    
    self.urlString = urlString;
}

- (void)checkCanShare
{
    NSURL *url = [NSURL URLWithString:_urlString];
    if (url) {
        NSMutableDictionary *dic = [url queryComponents];
        NSString *isShare = [dic valueForKey:@"is_share"];
        NSString *shareInfo = [dic valueForKey:@"share_info"];
        
        BOOL isInsurance = ([url.lastPathComponent rangeOfString:@"insurance"].length > 0);

        //可以分享
        if ([isShare isEqualToString:@"1"] && shareInfo) {
            if (_rightTopView == nil) {
                self.rightTopView = [CollectAndShareButtonView createShareButtonView];
                self.rightTopView.rightButton.hidden = YES;
                
                UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightTopView];
                self.navigationItem.rightBarButtonItem = buttonItem;
            }
            
            self.rightTopView.rightButton.hidden = NO;
            [self.rightTopView.rightButton addTarget:self
                                              action:@selector(clickShareButton:)
                                    forControlEvents:UIControlEventTouchUpInside];
            
            //如果是保险，则分享content内容只是从description中获取
            GoSportUrlFormatType type = isInsurance?GoSportUrlFormatTypeSeperate:GoSportUrlFormatTypeCommon;
            
            self.shareContent = [GoSportUrlAnalysis shareContentWithUrlQuery:shareInfo formatType:type];
        }
    }
}

- (void)initProgressView
{
    self.progressProxy = [[NJKWebViewProgress alloc] init] ;
    self.myWebView.delegate = _progressProxy;
    self.progressProxy.webViewProxyDelegate = self;
    self.progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 3.f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    self.progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    self.progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}

- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:_progressView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_progressView removeFromSuperview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLeftButtonView];
    
    [self initProgressView];
    
    //在shouldStartLoadWithRequest调用
    //[self checkCanShare];
    [self checkCanLogin];
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    [self.myWebView updateHeight:screenHeight - 64];
    [self.lineImageView setImage:[SportImage lineImage]];

    [self loadWebViewRequest];
    
    [self.webViewBackButton setImage:[SportImage webviewGoBackButtonOnImage] forState:UIControlStateNormal];
    [self.webViewBackButton setImage:[SportImage webviewGoBackButtonOffImage] forState:UIControlStateDisabled];
    
    [self.webViewRefreshButton setImage:[SportImage webviewRefreshButtonOnImage] forState:UIControlStateNormal];
    [self.webViewRefreshButton setImage:[SportImage webviewRefreshButtonOffImage] forState:UIControlStateDisabled];
    
    [self.webViewForwardButton setImage:[SportImage webviewGoForwardButtonOnImage] forState:UIControlStateNormal];
    [self.webViewForwardButton setImage:[SportImage webviewGoForwardButtonOffImage] forState:UIControlStateDisabled];
    
    [self updateButtonsState];
    
    self.bottomHolderView.hidden = YES;
}


-(BOOL)isValidHost:(NSString *)host {
    NSArray *allowedHostList = @[@"qydw.net",@"quyundong.com",@"qydtest.com"];
    for (NSString *allowedHost in allowedHostList) {
        if ([host rangeOfString:allowedHost].length > 0) {
            return YES;
        }
    }
    
    return NO;
}

- (void)setCookieWithHost:(NSString *)host{
    
    if (![self isValidHost:host]) {
        return;
    }
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:@"app_flag" forKey:NSHTTPCookieName];
    [cookieProperties setObject:@"2" forKey:NSHTTPCookieValue];
    [cookieProperties setObject:host forKey:NSHTTPCookieDomain];
    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
    
    NSHTTPCookie *cookieuser = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookieuser];
}

- (void)initLeftButtonView{
    //创建左上角的关闭和返回按钮
    if (_leftTopView == nil) {
        self.leftTopView = [CollectAndShareButtonView createCollectAndShareButtonView];
        [self.leftTopView.leftButton addTarget:self
                                            action:@selector(clickGoBackButton:)
                                  forControlEvents:UIControlEventTouchUpInside];
        [self.leftTopView.rightButton addTarget:self
                                          action:@selector(clickPopButton:)
                                forControlEvents:UIControlEventTouchUpInside];
        [self.leftTopView.leftButton setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
        [self.leftTopView.rightButton setImage:[UIImage imageNamed:@"WebGoBackButton"] forState:UIControlStateNormal];
        
        [self.leftTopView.leftButton updateOriginX:-25];
        [self.leftTopView.rightButton updateOriginX:10];
        
        //首页不显示
        self.leftTopView.rightButton.hidden = YES;
        
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftTopView];
        self.navigationItem.leftBarButtonItem = buttonItem;
    }
}

- (IBAction)clickGoBackButton:(id)sender {
    if ([self isFirstWebPage]) {
        [self popMyself];
    } else {
        [_myWebView goBack];
    }
}

- (IBAction)clickPopButton:(id)sender {
    [self popMyself];
}

- (void)popMyself
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadWebViewRequest
{
    NSURL *url = [NSURL URLWithString:_urlString];
    if (![_urlString isEqualToString:@""] && url != nil) {
        NSURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [self setCookieWithHost:[request.URL host]];
        [self.myWebView loadRequest:request];
    }
    else{
        [SportPopupView popupWithMessage:DDTF(@"无法打开网页")];
    }
}

- (void)updateButtonsState
{
    self.webViewBackButton.enabled = [_myWebView canGoBack];
    self.webViewForwardButton.enabled = [_myWebView canGoForward];
}

- (BOOL)isFirstWebPage
{
    if (!_myWebView.canGoBack) {
        return YES;
    } else {
        return NO;
    }
}

- (IBAction)clickWebViewBackButton:(id)sender {
    [_myWebView goBack];
}

- (IBAction)clickWebViewRefreshButton:(id)sender {
    //如果第一次进来就load失败调用reload会失效，要调用loadRequest
    if ([self isFirstWebPage]) {
        [self loadWebViewRequest];
    } else {
        [_myWebView reload];
    }
}

- (IBAction)clickWebViewForwardButton:(id)sender {
    [_myWebView goForward];
}

- (void)clickShareButton:(id)sender
{
    
    if (_assignChannelList.count <= 0) {
        //defaultChannelList
        self.assignChannelList = [NSArray arrayWithObjects:@(ShareChannelWeChatTimeline),@(ShareChannelWeChatSession), @(ShareChannelSina), @(ShareChannelCopy), nil];
    }
    
    
    [ShareView popUpViewWithContent:_shareContent
                        channelList:_assignChannelList
                     viewController:self
                           delegate:nil];
}

#pragma mark -
#pragma UIWebViewDelegate methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
//    HDLog(@"absoluteString:%@", [request.URL absoluteString]);
//    HDLog(@"relativeString:%@", [request.URL relativeString]);
//    HDLog(@"scheme:%@", [request.URL scheme]);
//    HDLog(@"resourceSpecifier:%@", [request.URL resourceSpecifier]);
//    HDLog(@"host:%@", [request.URL host]);
//    HDLog(@"port:%@", [request.URL port]);
//    HDLog(@"user:%@", [request.URL user]);
//    HDLog(@"password:%@", [request.URL password]);
//    HDLog(@"path:%@", [request.URL path]);
//    HDLog(@"fragment:%@", [request.URL fragment]);
//    HDLog(@"parameterString:%@", [request.URL parameterString]);
//    HDLog(@"query:%@", [request.URL query]);
//    HDLog(@"relativePath:%@", [request.URL relativePath]);

    self.urlString = request.URL.absoluteString;
    [self checkCanShare];
    
    if ([GoSportUrlAnalysis isGoSportScheme:request.URL]) {
        [GoSportUrlAnalysis pushControllerWithUrl:request.URL NavigationController:self.navigationController];
        return NO;
    } else {
        return YES;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self updateButtonsState];
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if ([self isFirstWebPage]) {
        self.leftTopView.rightButton.hidden = YES;
    } else {
        self.leftTopView.rightButton.hidden = NO;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self updateButtonsState];
    
    // webView加载失败提示
    [SportPopupView popupWithMessage:DDTF(@"无法打开网页")];
}

@end
