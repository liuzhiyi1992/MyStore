//
//  SportWebView.h
//  Sport
//
//  Created by 江彦聪 on 15/6/15.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SportWebViewDelegate <NSObject>
@optional
-(void)didClickBuyNowButton;
-(void)didFinishLoadWebView;
-(void)didFailedLoadWebView;

@end

@interface SportWebView : UIView<UIWebViewDelegate>
+ (SportWebView *)createViewWithUrl:(NSString *)urlString title:(NSString *)title;
-(void)show;

@property (assign,nonatomic) id<SportWebViewDelegate> delegate;

@end
