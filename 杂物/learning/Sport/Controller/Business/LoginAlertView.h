//
//  LoginAlertView.h
//  Sport
//
//  Created by xiaoyang on 16/7/28.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LoginAlertViewDelegate <NSObject>
@optional
- (void)didClickLoginButton;
- (void)didClickDirectRecommendButton;
@end

@interface LoginAlertView : UIView
@property (assign, nonatomic) id<LoginAlertViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *contentHolderView;
@property (weak, nonatomic) IBOutlet UIButton *recommendButton;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;

+ (LoginAlertView *)createLoginAlertView;

- (void)show;

@end
