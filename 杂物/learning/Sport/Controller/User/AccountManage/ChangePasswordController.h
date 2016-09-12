//
//  ChangePasswordController.h
//  Sport
//
//  Created by haodong  on 13-9-14.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import "SportController.h"
#import "UserService.h"

@interface ChangePasswordController : SportController <UserServiceDelegate, UIAlertViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *againPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@end

