//
//  SelectCourtNameView.h
//  Sport
//
//  Created by qiuhaodong on 16/6/14.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@class DayBookingInfo;

@interface SelectCourtNameView : UIScrollView

+ (instancetype)showViewInSuperView:(UIView *)superView
                     dayBookingInfo:(DayBookingInfo *)dayBookingInfo
                        singleWidth:(CGFloat)singleWidth
                        singleSpace:(CGFloat)singleSpace;

- (void)changeColorWithSelectedProductList:(NSArray *)selectedProductList;

@end
