//
//  BasicInfoView.h
//  Coach
//
//  Created by quyundong on 15/9/14.
//  Copyright (c) 2015年 ningmi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Coach.h"

@interface BasicInfoView : UIView

+ (BasicInfoView *)createBasicInfoView;

- (void)updateWithUser:(Coach *)user;

@end
