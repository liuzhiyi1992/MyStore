//
//  SelectCourtProductView.h
//  Sport
//
//  Created by qiuhaodong on 16/6/14.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import <UIKit/UIKit.h>

@class Product;

@protocol SelectCourtProductViewDelegate<NSObject>
@required
- (void)didClickProduct:(Product *)product;
@end


@class DayBookingInfo;
@class ProductView;

@interface SelectCourtProductView : UIScrollView

+ (UIColor *)canOrderColor;
+ (UIColor *)orderedColor;
+ (UIColor *)myOrderColor;

+ (CGSize)oneProductViewSize;

+ (instancetype)showViewInSuperView:(UIView *)superView
                     dayBookingInfo:(DayBookingInfo *)dayBookingInfo
                           timeList:(NSArray *)timeList
                        singleSpace:(CGFloat)singleSpace
                         isCardUser:(BOOL)isCardUser
               clickProductDelegate:(id<SelectCourtProductViewDelegate>)clickProductDelegate;

- (void)autoScrollToCurrentTime:(NSDate *)selectedDate;

- (void)selectedWithProductId:(NSString *)productId animated:(BOOL)animated;

- (void)disSelectedWithProductId:(NSString *)productId;


@end
