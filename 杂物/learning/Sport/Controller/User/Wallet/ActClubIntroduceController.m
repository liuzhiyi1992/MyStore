//
//  ActClubIntroduceController.m
//  Sport
//
//  Created by 冯俊霖 on 15/8/11.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "ActClubIntroduceController.h"
#import "MonthCardRechargeController.h"
#import "SportPopupView.h"
#import "SportProgressView.h"
#import "BaseConfigManager.h"
#import "OrderService.h"

@interface ActClubIntroduceController ()<UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIButton *buyButton;
@property (assign, nonatomic) int clubStatus;
@end
 
@implementation ActClubIntroduceController

- (instancetype)initWithClubStatus:(int)status {
    self = [super init];
    if (self) {
        self.clubStatus = status;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"动Club介绍";
    self.webView.delegate = self;
    [self loadWebView];
    [self initView];
    
}

- (void)initView{
    switch (self.clubStatus) {
        case CLUB_STATUS_UNPAID:
        case CLUB_STATUS_EXPIRE:
            [self.buyButton setTitle:@"立即加入动Club" forState:UIControlStateNormal];
            break;
        case CLUB_STATUS_PAID_VALID:
        case CLUB_STATUS_PAID_INVALID: {
            [self.buyButton setTitle:@"动Club会员续费" forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
    
    
    [self.buyButton setBackgroundImage:[SportColor createImageWithColor:[SportColor defaultOrangeColor]] forState:UIControlStateNormal];
    self.buyButton.layer.masksToBounds = YES;
    self.buyButton.layer.cornerRadius = 5.0f;
}

- (void)loadWebView
{
    NSString *urlString = [[BaseConfigManager defaultManager] moncardIntroduceUrl];
    NSURL *url = [NSURL URLWithString:urlString];
    if (url != nil) {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
        [SportProgressView showWithStatus:@"正在加载"];
    }
    else{
        [self addNetErrorView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickBuyButton:(UIButton *)sender {
    [MobClickUtils event:umeng_event_click_club_introduce_buy_club_button];
    MonthCardRechargeController *vc = [[MonthCardRechargeController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - webViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)web{
    [SportProgressView dismiss];
    [self removeNoDataView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [SportProgressView dismiss];
    [self addNetErrorView];
}

- (void)addNetErrorView{
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 20 - 44);
    [self showNoDataViewWithType:NoDataTypeNetworkError frame:frame tips:@"网络错误"];
}

- (void)didClickNoDataViewRefreshButton{
    [self loadWebView];
}
@end
