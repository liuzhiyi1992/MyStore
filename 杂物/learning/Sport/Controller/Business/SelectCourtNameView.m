//
//  SelectCourtNameView.m
//  Sport
//
//  Created by qiuhaodong on 16/6/14.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "SelectCourtNameView.h"
#import "DayBookingInfo.h"
#import "Court.h"
#import "Product.h"

@interface SelectCourtNameView()
@property (strong, nonatomic) DayBookingInfo *dayBookingInfo;
@end

@implementation SelectCourtNameView

#define SELECT_COURT_NAME_VIEW_TAG 2016061401
+ (instancetype)showViewInSuperView:(UIView *)superView
                     dayBookingInfo:(DayBookingInfo *)dayBookingInfo
                        singleWidth:(CGFloat)singleWidth
                        singleSpace:(CGFloat)singleSpace
{
    SelectCourtNameView *view = [superView viewWithTag:SELECT_COURT_NAME_VIEW_TAG];
    if (!view) {
        view = [[SelectCourtNameView alloc] initWithFrame:superView.bounds];
        view.showsHorizontalScrollIndicator = NO;
        view.showsVerticalScrollIndicator = NO;
        view.tag = SELECT_COURT_NAME_VIEW_TAG;
        view.scrollEnabled = NO;
        [superView addSubview:view];
    }
    
    [view updateWithDayBookingInfo:dayBookingInfo singleWidth:singleWidth singleSpace:singleSpace];
    return view;
}

#define TAG_BASE_COURT  300
- (void)updateWithDayBookingInfo:(DayBookingInfo *)dayBookingInfo singleWidth:(CGFloat)singleWidth singleSpace:(CGFloat)singleSpace
{
    self.dayBookingInfo = dayBookingInfo;
    
    NSArray *subViewList = [self subviews];
    for (UIView *subView in subViewList) {
        if ([subView isKindOfClass:[UILabel class]]) {
            [subView removeFromSuperview];
        }
    }
    
    UIColor *textColor = [SportColor content1Color];
    CGFloat x = 0;
    int index = 0;
    for (Court *court in dayBookingInfo.courtList) {
        x  = singleSpace + (singleSpace + singleWidth) * index;
        UILabel *label  = [[UILabel alloc] initWithFrame:CGRectMake(x, 5, singleWidth, self.frame.size.height - 5)] ;
        label.tag = TAG_BASE_COURT + index;
        label.font = [UIFont systemFontOfSize:12];
        label.adjustsFontSizeToFitWidth = YES;
        label.textColor = textColor;
        label.textAlignment = NSTextAlignmentCenter;
        NSMutableString *name = [NSMutableString stringWithFormat:@"%@", court.name];
        if ([court.positionName length] > 0) {
            [name appendFormat:@"\n(%@)", court.positionName];
        }
        label.text = name;
        label.numberOfLines = 0;
        label.backgroundColor = [UIColor clearColor];
        [self addSubview:label];
        index ++;
    }
    self.contentSize = CGSizeMake(x + singleWidth + singleSpace, self.contentSize.height);
}

- (void)changeColorWithSelectedProductList:(NSArray *)selectedProductList
{
    //改变场号的颜色
    UIColor *defaultColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1];
    UIColor *selectedColor = [SportColor defaultColor];
    DayBookingInfo *dayBookingInfo = self.dayBookingInfo;
    int index = 0;
    for (Court *court in dayBookingInfo.courtList) {
        BOOL isFound = NO;
        for (Product *one in court.productList) {
            for (Product *selectProduct in selectedProductList) {
                if ([one.productId isEqualToString:selectProduct.productId]) {
                    isFound = YES;
                    break;
                }
            }
            
            if (isFound) {
                break;
            }
        }
        
        UILabel *label = (UILabel *)[self viewWithTag:TAG_BASE_COURT + index];
        if (isFound) {
            if (CGColorEqualToColor(label.textColor.CGColor, selectedColor.CGColor) == NO) {
                label.textColor = selectedColor;
            }
        } else {
            if (CGColorEqualToColor(label.textColor.CGColor, selectedColor.CGColor)) {
                label.textColor = defaultColor;
            }
        }
        index ++;
    }
}

@end
