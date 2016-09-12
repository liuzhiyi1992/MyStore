//
//  SponsorCourtJoinView.h
//  Sport
//
//  Created by lzy on 16/6/7.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const NOTIFICATION_NAME_POP_SHARE_VIEW;
extern NSString * const NOTIFICATION_NAME_DID_CLICK_CJ_REGULATION_BUTTON;

@class Order;
typedef NS_ENUM(NSInteger, SponsorType) {
    SponsorTypePaySucceed = 0,
    SponsorTypeOrderDetail = 1,
};

@interface SponsorCourtJoinView : UIView
@property (strong, nonatomic) Order *order;
+ (SponsorCourtJoinView *)createViewWithOrder:(Order *)order sponsorType:(SponsorType)sponsorType;
@end
