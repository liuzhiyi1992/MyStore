//
//  PayDelayView.h
//  Sport
//
//  Created by qiuhaodong on 15/6/14.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"

@protocol PayDelayViewDelegate <NSObject>
@optional
- (void)didClickPayDelayViewRefreshButton;
@end

@interface PayDelayView : UIView
@property (assign, nonatomic) id<PayDelayViewDelegate> delegate;
+ (PayDelayView *)createViewWithOrder:(Order *)order
                             delegate:(id<PayDelayViewDelegate>)delegate;

@end
