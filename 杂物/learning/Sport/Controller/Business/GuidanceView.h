//
//  GuidanceView.h
//  Sport
//
//  Created by 冯俊霖 on 15/10/16.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GuidanceViewDelegate <NSObject>
@optional
- (void)didClickGuidanceButton;
@end

@interface GuidanceView : UIView
@property (assign, nonatomic) id<GuidanceViewDelegate> delegate;

+ (GuidanceView *)createGuidanceView;

@end
