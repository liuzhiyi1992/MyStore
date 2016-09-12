//
//  SportNavigationController.h
//  Sport
//
//  Created by haodong  on 13-9-22.
//  Copyright (c) 2013年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SportNavigationController : UINavigationController<UINavigationControllerDelegate, UIGestureRecognizerDelegate>
- (void) pushNewControllerAndClearStackToParent:(UIViewController*)newController animated:(BOOL)animated;
@end
