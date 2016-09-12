//
//  InputPasswordView.h
//  Sport
//
//  Created by haodong  on 15/4/15.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserService.h"

@protocol InputPasswordViewDelegate <NSObject>
@optional
- (id)didFinishVerifyPayPassword:(NSString *)payPassword status:(NSString *)status;
- (void)didFinishSetPayPassword:(NSString *)payPassword status:(NSString *)status;
- (void)didFinishResetPayPassword:(NSString *)payPassword status:(NSString *)status;
- (void)didFinishModifyPayPassword:(NSString *)payPassword status:(NSString *)status;
- (void)didHideInputPasswordView;
@end

typedef enum{
    InputPasswordTypeVerify = 0,    //验证密码
    InputPasswordTypeSet = 1,       //设置密码
    InputPasswordTypeReset = 2,     //重置密码（忘记密码）
    InputPasswordTypeModify = 3     //修改密码
} InputPasswordType;

@interface InputPasswordView : UIView<UITextFieldDelegate, UIAlertViewDelegate, UserServiceDelegate>

+ (BOOL)popUpViewWithType:(InputPasswordType)type
                 delegate:(id<InputPasswordViewDelegate>)delegate
                  smsCode:(NSString *)smsCode;

@end
