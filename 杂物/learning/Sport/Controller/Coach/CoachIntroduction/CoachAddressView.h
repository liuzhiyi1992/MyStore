//
//  CoachAddressView.h
//  Sport
//
//  Created by qiuhaodong on 15/7/22.
//  Copyright (c) 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@class Coach;

@interface CoachAddressView : UIView

+ (CoachAddressView *)createViewWithCoach:(Coach *)coach;

@end
