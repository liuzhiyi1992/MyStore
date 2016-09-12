//
//  SetPasswordController.h
//  Sport
//
//  Created by haodong  on 15/2/3.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportController.h"
#import "UserService.h"

@protocol SetPasswordControllerDelegate <NSObject>

-(void)didClickSetPasswordBackButton;

@end

@interface SetPasswordController : SportController<UserServiceDelegate,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *againPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *okButton;

@property (weak, nonatomic) IBOutlet UIImageView *firstBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *secondBackgroundImageView;

@property (assign, nonatomic) id<SetPasswordControllerDelegate> delegate;

@end
