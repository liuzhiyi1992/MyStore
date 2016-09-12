//
//  SelectCourtTimeView.m
//  Sport
//
//  Created by qiuhaodong on 16/6/13.
//  Copyright © 2016年 haodong . All rights reserved.
//

#import "SelectCourtTimeView.h"
#import "Product.h"

@interface SelectCourtTimeView()
@property (strong, nonatomic) NSArray *timeList;
@end

@implementation SelectCourtTimeView

#define SELECT_COURT_TIME_VIEW_TAG 2016061302
+ (instancetype)showViewInSuperView:(UIView *)superView
                           timeList:(NSArray *)timeList
                       singleHeight:(CGFloat)singleHeight
                        singleSpace:(CGFloat)singleSpace
{
    SelectCourtTimeView *view = [superView viewWithTag:SELECT_COURT_TIME_VIEW_TAG];
    if (!view) {
        view = [[SelectCourtTimeView alloc] initWithFrame:superView.bounds];
        view.showsHorizontalScrollIndicator = NO;
        view.showsVerticalScrollIndicator = NO;
        view.tag = SELECT_COURT_TIME_VIEW_TAG;
        view.scrollEnabled = NO;
        [superView addSubview:view];
    }
    
    [view updateWithTimeList:timeList singleHeight:singleHeight singleSpace:singleSpace];
    return view;
}

#define WIDTH_TIME_LABEL 32
#define TAG_BASE_TIME   100
#define TAG_BASE_TIME_LINE  200
//更新时间轴
- (void)updateWithTimeList:(NSArray *)timeList
              singleHeight:(CGFloat)singleHeight
               singleSpace:(CGFloat)singleSpace
{
    self.timeList = timeList;
    
    NSArray *subViewList = [self subviews];
    for (UIView *subView in subViewList) {
        if ([subView isKindOfClass:[UILabel class]] || subView.tag >= TAG_BASE_TIME_LINE) {
            [subView removeFromSuperview];
        }
    }
    
    if ([timeList count] <= 0) {
        return;
    }
    
    UIColor *textColor = [SportColor content1Color];
    CGFloat y= 0;
    int index = 0;
    for (;index <= [timeList count]; index ++)
    {
        NSString *time = nil;
        if (index < [timeList count]) {
            time = [timeList objectAtIndex:index];
        } else {
            NSString *str = [timeList lastObject];
            NSArray *valueList = [str componentsSeparatedByString:@":"];
            if ([valueList count] >= 2) {
                NSString *first = [@([[valueList objectAtIndex:0] intValue] + 1) stringValue];
                NSString *second = [valueList objectAtIndex:1];
                time = [NSString stringWithFormat:@"%@:%@", first, second];
            }
        }
        
        y  = singleSpace + (singleSpace + singleHeight) * index;
        UILabel *label  = [[UILabel alloc] initWithFrame:CGRectMake(0, y,  WIDTH_TIME_LABEL, singleHeight)];
        label.tag = TAG_BASE_TIME + index;
        label.font = [UIFont systemFontOfSize:12];
        label.adjustsFontSizeToFitWidth = YES;
        label.textColor = textColor;
        label.textAlignment = NSTextAlignmentRight;
        label.text = time;
        label.backgroundColor = [UIColor clearColor];
        [self addSubview:label];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - 4, y + 0.5 * singleHeight , 4, 1)];
        lineView.tag = TAG_BASE_TIME_LINE + index;
        lineView.backgroundColor = textColor;
        [self addSubview:lineView];
    }
    self.contentSize = CGSizeMake(self.contentSize.width, y + singleHeight + singleSpace);
}

//改变时间的颜色
- (void)changeColorWithSelectedProductList:(NSArray *)selectedProductList
{
    UIColor *defaultColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1];
    UIColor *selectedColor = [SportColor defaultColor];
    
    int index = 0;
    for (;index <= [self.timeList count]; index ++)
    {
        UILabel *label = (UILabel *)[self viewWithTag:TAG_BASE_TIME + index];
        if (label == nil) {
            continue;
        }
        
        NSString *time = label.text;
        
        BOOL isFound = NO;
        for (Product *one in selectedProductList) {
            if ([one.startTime isEqualToString:time]
                || [[NSString stringWithFormat:@"%d:%@", one.startTimeHour + 1, one.startTimeMinuteString] isEqualToString:time]) {
                isFound = YES;
                break;
            }
        }
        
        UIView *lineView = [self viewWithTag:TAG_BASE_TIME_LINE + index];
        if (isFound) {
            if (CGColorEqualToColor(label.textColor.CGColor, selectedColor.CGColor) == NO) {
                label.textColor = selectedColor;
            }
            if (CGColorEqualToColor(lineView.backgroundColor.CGColor, selectedColor.CGColor) == NO) {
                lineView.backgroundColor = selectedColor;
            }
        } else {
            if (CGColorEqualToColor(label.textColor.CGColor, selectedColor.CGColor)) {
                label.textColor = defaultColor;
            }
            if (CGColorEqualToColor(lineView.backgroundColor.CGColor, selectedColor.CGColor)) {
                lineView.backgroundColor = defaultColor;
            }
        }
    }
}


@end
