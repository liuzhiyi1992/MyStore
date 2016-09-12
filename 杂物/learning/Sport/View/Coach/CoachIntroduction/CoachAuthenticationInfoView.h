//
//  CoachAuthenticationInfoView.h
//  Sport
//
//  Created by liuzhiyi on 15/10/9.
//  Copyright © 2015年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoachAuthenticationInfoView : UIView

+ (CoachAuthenticationInfoView *)createCoachAuthenticationInfoViewWithDateList:(NSArray *)dateList;

- (void)show;

- (void)dismiss;

@end

