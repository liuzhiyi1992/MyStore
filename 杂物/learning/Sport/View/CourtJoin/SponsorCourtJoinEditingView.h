//
//  SponsorCourtJoinEditingView.h
//  Sport
//
//  Created by lzy on 16/6/7.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const NOTIFICATION_NAME_COURT_JOIN_SUCCESS;
extern NSString * const NOTIFICATION_NAME_COURT_JOIN_IMPROVE_PERSONAL_INFO;
extern NSString * const TEXTVIEW_TEXT_DEFAULT;

@class Order;
@interface SponsorCourtJoinEditingView : UIView
@property (strong, nonatomic) Order *order;
+ (SponsorCourtJoinEditingView *)showWithOrder:(Order *)order;
@end
