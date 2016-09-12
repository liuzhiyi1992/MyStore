//
//  SignInSuccessView.h
//  Sport
//
//  Created by lzy on 16/6/12.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>


extern NSString * const NOTIFICATION_NAME_SIGN_IN_POP_SHARE_VIEW;

@protocol SignInSuccessViewDelegate <NSObject>
- (void)signInSuccessViewWillPushRecordsViewController;
@end

@interface SignInSuccessView : UIScrollView
+ (SignInSuccessView *)createViewWithDataDict:(NSDictionary *)dataDict delegate:(id<SignInSuccessViewDelegate>)delegate;
@property (assign, nonatomic) id<SignInSuccessViewDelegate> mydelegate;
@end
