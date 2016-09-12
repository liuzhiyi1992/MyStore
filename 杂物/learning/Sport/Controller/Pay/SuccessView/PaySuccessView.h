//
//  PaySuccessView.h
//  Sport
//
//  Created by qiuhaodong on 15/6/12.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

extern const char KEY_SELECTED_PAY_METHOD;

@class Order, SponsorCourtJoinView;

@protocol PaySuccessViewDelegate<NSObject>
-(void)PaySuccessViewBackToHome;
-(void)shareOrderInfoWith:(Order *)order;
- (void)pushOrderDetailController;

@end


@interface PaySuccessView : UIScrollView

@property (strong, nonatomic) SponsorCourtJoinView *sponsorCourtJoinView;
+ (PaySuccessView *)createViewWithOrder:(Order *)order;
- (void)hideSponsorCourtJoinView;
- (void)appearSponsorCourtJoinView;
@property (weak, nonatomic) id<PaySuccessViewDelegate> paydelegate;
@end
