//
//  MainHomeSignInView.h
//  Sport
//
//  Created by lzy on 16/6/20.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const NOTIFICATION_NAME_DID_UPDATE_SIGN_IN_DATA;

@class SignIn;
@interface MainHomeSignInView : UIView
@property (strong, nonatomic) IBOutlet UIView *view;
@property (strong, nonatomic) SignIn *signIn;
@end
