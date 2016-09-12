//
//  SportWebController.h
//  Sport
//
//  Created by haodong  on 13-8-31.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SportController.h"
#import "NJKWebViewProgress.h"
#import "ShareView.h"

@interface SportWebController : SportController<UIWebViewDelegate, NJKWebViewProgressDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *myWebView;

@property (weak, nonatomic) IBOutlet UIView *bottomHolderView;
@property (weak, nonatomic) IBOutlet UIButton *webViewBackButton;
@property (weak, nonatomic) IBOutlet UIButton *webViewRefreshButton;
@property (weak, nonatomic) IBOutlet UIButton *webViewForwardButton;

@property (weak, nonatomic) IBOutlet UIImageView *lineImageView;

- (id)initWithUrlString:(NSString *)urlString title:(NSString *)title;

- (id)initWithUrlString:(NSString *)urlString title:(NSString *)title channelList:(NSArray *)channelList;

- (void)reloadWebView;

@end
