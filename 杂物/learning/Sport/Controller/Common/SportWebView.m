//
//  SportWebView.m
//  Sport
//
//  Created by 江彦聪 on 15/6/15.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportWebView.h"
#import "SportPopupView.h"

@interface SportWebView()

@property (weak, nonatomic) IBOutlet UIWebView *myWebView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (copy, nonatomic) NSString *urlString;

@end

@implementation SportWebView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (SportWebView *)createViewWithUrl:(NSString *)urlString title:(NSString *)title
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SportWebView" owner:self options:nil];
    
    if ([topLevelObjects count] <= 0){
        return nil;
    }
    
    SportWebView *view = (SportWebView *)[topLevelObjects objectAtIndex:0];
    
    view.urlString = urlString;
    view.titleLabel.text = title;
    view.frame = [UIScreen mainScreen].bounds;
    view.myWebView.delegate = view;
    return view;
}

-(void)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    NSURL *url = [NSURL URLWithString:_urlString];
    if (![_urlString isEqualToString:@""] && url != nil) {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        [self.myWebView loadRequest:request];
        self.myWebView.scalesPageToFit= YES;
        self.myWebView.contentMode = UIViewContentModeScaleAspectFit;
        //self.myWebView.scrollView.contentSize
        //[SportProgressView showWithStatus:DDTF(@"kLoading")];
    }
    else{
        [SportPopupView popupWithMessage:DDTF(@"无法打开网页")];
    }
}

- (IBAction)clickBuyNowButton:(id)sender {
    [MobClickUtils event:umeng_event_month_introduce_add];
    
    if([_delegate respondsToSelector:@selector(didClickBuyNowButton)])
    {
        [_delegate didClickBuyNowButton];
    }
    
    [self removeFromSuperview];
}

- (IBAction)clickCancelButton:(id)sender {
    [MobClickUtils event:umeng_event_month_introduce_refuse];
    
    [self removeFromSuperview];
}

- (IBAction)clickBackgournd:(id)sender {
    [self removeFromSuperview];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self zoomToFit];
    if ([_delegate respondsToSelector:@selector(didFinishLoadWebView)]) {
        [_delegate didFinishLoadWebView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([_delegate respondsToSelector:@selector(didFailedLoadWebView)]) {
        [_delegate didFailedLoadWebView];
    }
}

-(void)zoomToFit
{
    
    if ([self.myWebView respondsToSelector:@selector(scrollView)])
    {
        UIScrollView *scroll=[self.myWebView scrollView];
        
        float zoom=self.myWebView.bounds.size.width/scroll.contentSize.width;
        [scroll setZoomScale:zoom animated:YES];
    }
}


@end
