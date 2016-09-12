//
//  PaySuccessWithRedPacketView.h
//  Sport
//
//  Created by 冯俊霖 on 15/10/9.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PaySuccessWithRedPacketViewDelegate <NSObject>

- (void)didClickShareButton;

@end

@interface PaySuccessWithRedPacketView : UIView
@property (assign, nonatomic)id<PaySuccessWithRedPacketViewDelegate>delegate;

+ (PaySuccessWithRedPacketView *)createPaySuccessWithRedPacketView;

@end
