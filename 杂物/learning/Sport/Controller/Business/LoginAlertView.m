//
//  LoginAlertView.m
//  Sport
//
//  Created by xiaoyang on 16/7/28.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "LoginAlertView.h"

@implementation LoginAlertView

+ (LoginAlertView *)createLoginAlertView{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"LoginAlertView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    LoginAlertView *view = [topLevelObjects objectAtIndex:0];
    
    view.frame = [UIScreen mainScreen].bounds;
    view.contentHolderView.layer.cornerRadius = 5;
    view.contentHolderView.layer.masksToBounds = YES;
    
    view.loginButton.layer.cornerRadius = 15;
    view.loginButton.layer.masksToBounds = YES;
    
    view.recommendButton.layer.cornerRadius = 15;
    view.recommendButton.layer.masksToBounds = YES;
    [view.recommendButton.layer setBorderWidth:0.5];
    view.recommendButton.layer.borderColor=[UIColor hexColor:@"5b73f2"].CGColor;
    
    return view;
}

- (void)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

- (IBAction)clickLoginButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickLoginButton)]) {
        [_delegate didClickLoginButton];
    }
}

- (IBAction)clickDirectRecommendButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickDirectRecommendButton)]) {
        [_delegate didClickDirectRecommendButton];
    }
}

- (IBAction)clickBackgroundButton:(id)sender {
    
    [self removeFromSuperview];
}

@end
