//
//  CourtJoinBriefEditingView.h
//  Sport
//
//  Created by lzy on 16/6/20.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

NSString * const COURTJOIN_DESC_LABEL_DEFAULT_CONTENT;

@class Order;
@protocol CourtJoinBriefEditingViewDelegate <NSObject>
- (void)briefEditingViewDidSubmitWithDesc:(NSString *)desc;
@end

@interface CourtJoinBriefEditingView : UIView
@property (assign, nonatomic) id<CourtJoinBriefEditingViewDelegate> delegate;
+ (CourtJoinBriefEditingView *)createView:(id<CourtJoinBriefEditingViewDelegate>)delegate order:(Order *)order courtJoinDesc:(NSString *)courtJoinDesc;
@end
