//
//  SelectCourtDateListView.h
//  Sport
//
//  Created by qiuhaodong on 16/6/13.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectCourtDateListView : UIScrollView

+ (void)showViewInSuperView:(UIView *)superView
                   dateList:(NSArray *)dateList
               selectedDate:(NSDate *)selectedDate
    didClickDateViewHandler:(void(^)(NSDate * date))didClickDateViewHandler;

@end
