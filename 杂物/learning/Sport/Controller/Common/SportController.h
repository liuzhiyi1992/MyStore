//
//  SportController.h
//  Sport
//
//  Created by haodong  on 13-6-4.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+Sport.h"
#import "NoDataView.h"
#import "UIViewController+SportNavigationItem.h"
#import "UIView+SportBackground.h"
#import "UITableView+Utils.h"

@interface SportController : UIViewController <NoDataViewDelegate>

@property (strong, nonatomic) UILabel *noDataTipsLabel;
@property (strong, nonatomic) NoDataView *noDataView;


- (void)showNoDataViewWithType:(NoDataType)type
                         frame:(CGRect)frame
                          tips:(NSString *)tips;

- (void)showNoDataViewWithType:(NoDataType)type
                          tips:(NSString *)tips;
- (void)removeNoDataView;

- (BOOL)handleGestureNavigate;
- (void)registerForKeyboardNotifications;
- (void)deregsiterKeyboardNotification;

- (UIToolbar *)getNumberToolbar;

- (BOOL)isLoginAndShowLoginIfNot;
-(void) showUserDetailControllerWithUserId:(NSString *)userId;
- (BOOL)previousControllerIsCertainController:(NSString *)controllerClassName;
@end
