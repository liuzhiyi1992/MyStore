//
//  CourtJoinOrderInfoView.h
//  Sport
//
//  Created by lzy on 16/6/16.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@class Order;

@protocol OrderDetailCourtJoinInfoViewDelegate <NSObject>
@optional
- (void)orderDetailCourtJoinInfoViewDidChangeHeight:(CGFloat)height;
@end

@interface OrderDetailCourtJoinInfoView : UIView
@property (assign, nonatomic) BOOL isRevealAllParticipator;
@property (assign, nonatomic) id<OrderDetailCourtJoinInfoViewDelegate> delegate;
+ (OrderDetailCourtJoinInfoView *)createViewWithOrder:(Order *)order delegate:(id<OrderDetailCourtJoinInfoViewDelegate>)delegate;
@end