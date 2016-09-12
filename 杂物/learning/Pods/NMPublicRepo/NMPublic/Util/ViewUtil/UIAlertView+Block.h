//
//  UIAlertView+Block.h
//  Pods
//
//  Created by 江彦聪 on 16/6/19.
//
//

#import <UIKit/UIKit.h>

@interface UIAlertView (Block)
typedef void(^CompleteBlock) (NSInteger buttonIndex);
-  (void)showAlertViewWithCompleteBlock:(CompleteBlock)block;
@end
