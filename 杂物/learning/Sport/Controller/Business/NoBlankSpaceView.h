//
//  NoBlankSpaceView.h
//  Sport
//
//  Created by 冯俊霖 on 15/10/17.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NoBlankSpaceViewDelegate <NSObject>
@optional
- (void)didClickResetTimeButton;
@end

@interface NoBlankSpaceView : UIView
@property (assign, nonatomic) id<NoBlankSpaceViewDelegate> delegate;

+ (NoBlankSpaceView *)createNoBlankSpaceView;
@end
