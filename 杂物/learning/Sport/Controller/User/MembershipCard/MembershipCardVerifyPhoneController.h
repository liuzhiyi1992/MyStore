//
//  MembershipCardVerifyPhoneController.h
//  Sport
//
//  Created by 江彦聪 on 15/4/17.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import "SportController.h"
#import "UserService.h"
#import "MembershipCard.h"
#import "MembershipCardService.h"
#import "InputPasswordView.h"
#import "SetPasswordController.h"

@interface MembershipCardVerifyPhoneController : SportController<UITextFieldDelegate, UserServiceDelegate,UIAlertViewDelegate,MembershipCardServiceDelegate,InputPasswordViewDelegate,SetPasswordControllerDelegate>

-(id) initWithType:(VerifyPhoneType)type;
-(id)initWithType:(VerifyPhoneType)type
             card:(MembershipCard *)card
   isBindNewPhone:(BOOL)isBindNewPhone;

@end
