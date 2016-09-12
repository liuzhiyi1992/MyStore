//
//  OrderDetailCourtJoinParticipatorView.h
//  Sport
//
//  Created by lzy on 16/6/17.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@class CourtJoinUser;
@interface OrderDetailCourtJoinParticipatorView : UIView

+ (OrderDetailCourtJoinParticipatorView *)createViewWithCourtJoinUser:(CourtJoinUser *)courtJoinUser;
@end
